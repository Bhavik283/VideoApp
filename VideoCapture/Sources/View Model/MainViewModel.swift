//
//  MainViewModel.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 16/05/25.
//

import AppKit
import AVFoundation
import Combine
import SwiftUI

final class MainViewModel: ObservableObject {
    @Published var activeCamera: AVCaptureDevice?
    @Published var activeMicrophone: AVCaptureDevice?
    @Published var activeIPCameras: [IPCamera] = [] { didSet { syncTimersWithCameras() } }

    @Published var frameRate: Int32 = 30

    @Published var selectedCameraID: String
    @Published var selectedMicID: String
    @Published var selectedSettingsID: UUID
    @Published var useIPFeed: Bool = false
    @Published var timers: [UUID: TimerModel] = [:]

    @ObservedObject var avTimer: TimerModel
    @Published var isAVRecording: Bool = false

    var ffmpegPath: String?
    var ffplayPath: String?
    var ffprobePath: String?
    var openWindow: (() -> Void)? = nil
    var closeWindow: (() -> Void)? = nil

    private var avProcess: Process?
    private var ipProcesses: [UUID: Process] = [:]
    private var ffplayProcesses: [UUID: Process] = [:]
    let nilUUID = UUID()
    var session = AVCaptureSession()
    private var lifecycleObserver = AppLifecycleObserver()
    private var cancellables = Set<AnyCancellable>()

    init(activeCamera: AVCaptureDevice? = nil, activeMicrophone: AVCaptureDevice? = nil, selectedSettingsID: UUID? = nil) {
        self.activeCamera = activeCamera
        selectedCameraID = activeCamera?.uniqueID ?? ""
        self.activeMicrophone = activeMicrophone
        selectedMicID = activeMicrophone?.uniqueID ?? ""
        self.selectedSettingsID = selectedSettingsID ?? nilUUID
        avTimer = TimerModel()

        lifecycleObserver.onWillSleep = { [weak self] in
            self?.handleSystemSleep()
        }
        lifecycleObserver.onDidWake = { [weak self] in
            self?.handleSystemWake()
        }
        lifecycleObserver.onAppTerminate = { [weak self] in
            self?.stopAllRecordings()
        }
        observeDeviceDisconnection()
        ffmpegPath = shell(command: "which ffmpeg")
        ffplayPath = shell(command: "which ffplay")
        ffprobePath = shell(command: "which ffprobe")
    }

    func makeTime(id: UUID) -> String? {
        guard let timer = timers[id] else { return nil }
        guard !timer.hrValue.isEmpty || !timer.minValue.isEmpty || !timer.secValue.isEmpty else { return nil }
        if Int(timer.hrValue) == 0 && Int(timer.minValue) == 0 && Int(timer.secValue) == 0 {
            return nil
        }
        let hour = timer.hrValue.isEmpty ? "00" : timer.hrValue
        let minutes = timer.minValue.isEmpty ? "00" : timer.minValue
        let seconds = timer.secValue.isEmpty ? "00" : timer.secValue
        return "\(hour):\(minutes):\(seconds)"
    }

    func makeTime() -> String? {
        let timer = avTimer
        guard !timer.hrValue.isEmpty || !timer.minValue.isEmpty || !timer.secValue.isEmpty else { return nil }
        if Int(timer.hrValue) == 0 && Int(timer.minValue) == 0 && Int(timer.secValue) == 0 {
            return nil
        }
        let hour = timer.hrValue.isEmpty ? "00" : timer.hrValue
        let minutes = timer.minValue.isEmpty ? "00" : timer.minValue
        let seconds = timer.secValue.isEmpty ? "00" : timer.secValue
        return "\(hour):\(minutes):\(seconds)"
    }

    func resetPreviewState() {
        activeCamera = nil
        activeMicrophone = nil
        activeIPCameras = []
        selectedSettingsID = nilUUID
    }

    private func handleSystemSleep() {
        stopAllRecordings()
    }

    private func handleSystemWake() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.session.startRunning()
        }
    }

    private func observeDeviceDisconnection() {
        NotificationCenter.default.publisher(for: AVCaptureDevice.wasDisconnectedNotification)
            .sink { [weak self] notification in
                guard let device = notification.object as? AVCaptureDevice else { return }
                self?.handleDeviceDisconnected(device)
            }
            .store(in: &cancellables)
    }

    private func handleDeviceDisconnected(_ device: AVCaptureDevice) {
        if device.uniqueID == activeCamera?.uniqueID || device.uniqueID == activeMicrophone?.uniqueID {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.stopAVRecording()
                showFailureAlert(message: "\(device.localizedName) disconnected. Recording stopped.")
            }
        }
    }

    private func syncTimersWithCameras() {
        for camera in activeIPCameras {
            if timers[camera.id] == nil {
                timers[camera.id] = TimerModel()
            }
        }

        let activeIDs = Set(activeIPCameras.map { $0.id })
        for timerID in timers.keys {
            if !activeIDs.contains(timerID) {
                timers.removeValue(forKey: timerID)
            }
        }
    }
}

extension MainViewModel {
    func startAVRecording(devices: AVViewModel, settings: AVSettingViewModel) {
        avTimer.reset()
        guard let ffmpegPath = ffmpegPath ?? Bundle.main.path(forResource: "ffmpeg", ofType: nil) else {
            avTimer.isRecording = false
            showFailureAlert(message: "FFmpeg not found")
            return
        }

        guard let camIndex = devices.indexForVideoDevice(activeCamera) else {
            avTimer.isRecording = false
            showFailureAlert(message: "Selected Camera not found")
            return
        }

        let micIndex = devices.indexForAudioDevice(activeMicrophone).map { "\($0)" } ?? ""

        showRecordingSavePanel { [weak self] url in
            guard let self, let url else {
                self?.avTimer.isRecording = false
                return
            }

            let framerate = self.frameRate
            let audioFiltersAV = "adeclick,afftdn=nt=w"

            let input = micIndex.isEmpty ? "\(camIndex)" : "\(camIndex):\(micIndex)"
            let supportedRanges = activeCamera?.activeFormat.videoSupportedFrameRateRanges

            let supportedFramerate: Int32 = {
                guard let ranges = supportedRanges, let first = ranges.first else { return 30 }

                let maxRate = first.maxFrameRate

                if maxRate >= 60 { return 60 } // Common for newer devices
                else if maxRate >= 30 { return 30 } // Most common
                else if maxRate >= 24 { return 24 } // Cinema standard
                else if maxRate >= 15 { return 15 } // Minimum reasonable rate
                else { return Int32(floor(maxRate)) }
            }()

            var args = [
                "-f", "avfoundation",
                "-fflags", "nobuffer",
                "-flags", "low_delay",
                "-framerate", "\(supportedFramerate)"
            ]

            let selectedSettings = settings.AVSettingData.first(where: { $0.id == self.selectedSettingsID })
            // Video Frame Size
            if let frameSize = selectedSettings?.video.frameSize, !frameSize.isEmpty {
                args.append("-video_size")
                args.append(frameSize)
            }

            args.append("-i")
            args.append(input)

            if let time = makeTime() {
                args.append("-t")
                args.append(time)
            }

            let settingArgument = applySettings(cameraIndex: "\(camIndex)", microphoneIndex: micIndex, setting: selectedSettings)
            args.append(contentsOf: settingArgument)

            args += [
                "-vf", "fps=\(framerate)",
                "-af", audioFiltersAV,
                "-preset", "ultrafast"
            ]
            args.append(url.path)
            print(args)

            let task = Process()
            task.launchPath = ffmpegPath
            task.arguments = args

            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe
            task.terminationHandler = { [weak self] _ in
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                guard let output = String(data: data, encoding: .utf8) else { return }
                print(output)

                let errorLines = output
                    .components(separatedBy: .newlines)
                    .filter { $0.lowercased().contains("error") }

                DispatchQueue.main.async {
                    self?.stopAVRecording()
                    if !errorLines.isEmpty {
                        showFailureAlert(message: "FFmpeg failed to save or start the recording.", completeMessage: output)
                    }
                }
            }

            self.avProcess = task
            task.launch()
            self.avTimer.start()
            isAVRecording = true
        }
    }

    func stopAVRecording() {
        avTimer.stop()
        avProcess?.terminate()
        avProcess = nil
        if isAVRecording {
            isAVRecording = false
        }
    }

    func stopAllRecordingsForBackground() {
        stopAVRecording()
        session.stopRunning()
    }

    func stopAllRecordings() {
        stopAVRecording()

        for id in Set(ipProcesses.keys).union(ffplayProcesses.keys) {
            closeFFplayWindow(id: id)
        }

        timers.removeAll()
        ipProcesses.removeAll()
        ffplayProcesses.removeAll()
        session.stopRunning()
    }
}

extension MainViewModel {
    func openIPFFplayWindow(camera: IPCamera, id: UUID) {
        guard let ffplayPath = ffplayPath ?? Bundle.main.path(forResource: "ffplay", ofType: nil) else {
            showFailureAlert(message: "ffplay not found in bundle.")
            return
        }

        let process = Process()
        process.launchPath = ffplayPath

        // RTSP Transport
        let isRTSP = camera.url.lowercased().hasPrefix("rtsp")
        let transport: String = {
            switch camera.rtp {
            case .rtp: "tcp"
            case .mpegOverRtp, .mpegOverUdp: "udp"
            }
        }()

        // Auth Injection
        var url = camera.url
        if !camera.username.isEmpty, !camera.password.isEmpty {
            url = url.replacingOccurrences(of: "://", with: "://\(camera.username):\(camera.password)@")
        }

        // Arguments
        var args = [
            "-window_title", camera.name,
            "-fflags", "+flush_packets",
            "-flags", "low_delay"
        ]

        args += ["-x", "640", "-y", "360"]

        if isTesting {
            args.append(contentsOf: ["-f", "lavfi"])
        }

        if isRTSP {
            args += ["-rtsp_transport", transport]
        }

        if camera.deinterfaceFeed {
            args += ["-vf", "yadif"]
        }

        // Keep the window open; let the user close manually
        // args += ["-autoexit"]

        if let sdp = camera.sdpFile, !sdp.isEmpty {
            args += ["-protocol_whitelist", "file,rtp,udp", "-i", sdp]
        } else {
            args += ["-i", url]
        }
        print(args)

        process.arguments = args

        // Debug pipe
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        // On termination, stop timer + cleanup
        process.terminationHandler = { [weak self] _ in
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""

            let knownFailureIndicators = ["invalid data", "no such file", "connection refused", "not found", "failed: host is down"]
            let lowercasedOutput = output.lowercased()

            let matchedIndicator = knownFailureIndicators.first(where: {
                lowercasedOutput.contains($0)
            })
            print(output)

            DispatchQueue.main.async {
                self?.closeFFplayWindow(id: id)

                if let reason = matchedIndicator {
                    showFailureAlert(message: "FFplay failed: \(reason.capitalized).", completeMessage: output)
                }
            }
        }

        pipe.fileHandleForReading.readabilityHandler = { handle in
            _ = handle.availableData
        }

        process.launch()
        NSApp.activate(ignoringOtherApps: true)
        ffplayProcesses[id] = process
    }

    func startIPRecording(id: UUID, settings: AVSettingViewModel, camera: IPCamera) {
        timers[id]?.reset()
        showRecordingSavePanel { [weak self] url in
            self?.startIPCameraRecording(url: url?.path, id: id, settings: settings, camera: camera)
        }
    }

    func startIPCameraRecording(url: String?, id: UUID, settings: AVSettingViewModel, camera: IPCamera) {
        guard let ffmpegPath = ffmpegPath ?? Bundle.main.path(forResource: "ffmpeg", ofType: nil) else {
            showFailureAlert(message: "FFmpeg not found")
            timers[id]?.isRecording = false
            return
        }

        guard let url else {
            timers[id]?.isRecording = false
            return
        }

        var streamURL = camera.url
        if !camera.username.isEmpty, !camera.password.isEmpty {
            streamURL = streamURL.replacingOccurrences(of: "://", with: "://\(camera.username):\(camera.password)@")
        }

        let hasAudio = timers[id]?.hasAudio ?? false
        let audioFiltersIP = "adeclick,afftdn=nt=w"

        // Determine transport type
        let isRTSP = camera.url.lowercased().hasPrefix("rtsp")
        let transport: String = {
            switch camera.rtp {
            case .rtp: "tcp"
            case .mpegOverRtp, .mpegOverUdp: "udp"
            }
        }()
        // Begin building FFmpeg arguments
        var args: [String] = [
            "-fflags", "nobuffer",
            "-flags", "low_delay"
        ]

        if isTesting {
            args.append(contentsOf: ["-f", "lavfi"])
        }

        if isRTSP {
            args += ["-rtsp_transport", transport]
        }

        if let sdp = camera.sdpFile, !sdp.isEmpty {
            args += ["-protocol_whitelist", "file,rtp,udp", "-i", sdp]
        } else {
            args += ["-i", streamURL]
        }

        let selectedSettings = settings.AVSettingData.first(where: { $0.id == self.selectedSettingsID })
        // Video Frame Size
        if let frameSize = selectedSettings?.video.frameSize, !frameSize.isEmpty {
            args.append("-video_size")
            args.append(frameSize)
        }

        args += applySettings(setting: selectedSettings, hasAudio: hasAudio)

        if let time = makeTime(id: id) {
            args.append("-t")
            args.append(time)
        }
        if hasAudio {
            args.append("-af")
            args.append(audioFiltersIP)
        }

        args += ["-preset", "ultrafast", url]
        print(args)

        let task = Process()
        task.launchPath = ffmpegPath
        task.arguments = args

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.terminationHandler = { [weak self] _ in
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            guard let output = String(data: data, encoding: .utf8) else { return }
            print(output)

            let errorLines = output
                .components(separatedBy: .newlines)
                .filter { $0.lowercased().contains("error") }

            DispatchQueue.main.async {
                self?.stopIPRecording(id: id)
                if !errorLines.isEmpty {
                    showFailureAlert(message: "FFmpeg failed to save or start the recording.", completeMessage: output)
                }
            }
        }

        ipProcesses[id] = task
        task.launch()
        timers[id]?.start()
    }

    func startIPCameraWindow(ipCamera: IPCamera) {
        activeIPCameras.append(ipCamera)
        let id = ipCamera.id
        checkAudioStream(for: ipCamera) { [weak self] hasAudio in
            guard let self = self else { return }
            self.timers[id]?.hasAudio = hasAudio
            self.openIPFFplayWindow(camera: ipCamera, id: id)
        }
    }

    func startAllRecordings(settings: AVSettingViewModel) {
        showRecordingSavePanel { [weak self] url in
            guard let self, let url else { return }

            let baseURL = url.deletingPathExtension()
            let ext = url.pathExtension

            for camera in activeIPCameras {
                if let timer = timers[camera.id] {
                    timer.isRecording = true
                    timers[camera.id]?.reset()

                    let cameraFileName = baseURL.lastPathComponent + "_\(camera.name)"
                    let cameraURL = baseURL.deletingLastPathComponent().appendingPathComponent(cameraFileName).appendingPathExtension(ext)

                    startIPCameraRecording(url: cameraURL.path, id: camera.id, settings: settings, camera: camera)
                }
            }
        }
    }

    func stopIPRecording(id: UUID) {
        timers[id]?.stop()
        ipProcesses[id]?.terminate()
        ipProcesses.removeValue(forKey: id)
    }

    func closeFFplayWindow(id: UUID) {
        stopIPRecording(id: id)
        timers.removeValue(forKey: id)
        ffplayProcesses[id]?.terminate()
        ffplayProcesses.removeValue(forKey: id)
        activeIPCameras.removeAll { $0.id == id }
    }

    func closeAllFFplayWindows() {
        ffplayProcesses.keys.forEach(closeFFplayWindow)
    }

    func checkAudioStream(for camera: IPCamera, completion: @escaping (Bool) -> Void) {
        guard let ffprobePath = ffprobePath ?? Bundle.main.path(forResource: "ffprobe", ofType: nil) else {
            print("ffprobe not found")
            completion(false)
            return
        }

        var url = camera.url
        if !camera.username.isEmpty, !camera.password.isEmpty {
            url = url.replacingOccurrences(of: "://", with: "://\(camera.username):\(camera.password)@")
        }

        let process = Process()
        process.launchPath = ffprobePath
        let args = [
            "-v", "error",
            "-timeout", "10000000",
            "-rw_timeout", "10000000",
            "-select_streams", "a",
            "-show_entries", "stream=codec_type",
            "-of", "default=noprint_wrappers=1:nokey=1",
            url
        ]
        print(args)
        process.arguments = args

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        process.terminationHandler = { _ in
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(decoding: data, as: UTF8.self)
            let hasAudio = output.contains("audio")
            print(output)
            print("audio: \(hasAudio)")
            DispatchQueue.main.async {
                completion(hasAudio)
            }
        }

        process.launch()
    }
}
