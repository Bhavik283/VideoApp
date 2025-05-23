//
//  MainViewModel.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 16/05/25.
//

import AppKit
import AVFoundation
import Combine
import Foundation

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

    @Published var avTimer: TimerModel? = nil
    @Published var isAVRecording: Bool = false

    private var avProcess: Process?
    private var ipProcesses: [UUID: Process] = [:]
    private var ffplayProcesses: [UUID: Process] = [:]
    let nilUUID = UUID()
    var session = AVCaptureSession()
    private var lifecycleObserver = AppLifecycleObserver()
    private var cancellables = Set<AnyCancellable>()

    init(activeCamera: AVCaptureDevice? = nil, activeMicrophone: AVCaptureDevice? = nil, selectedSettingsID: UUID? = nil) {
        self.activeCamera = activeCamera
        self.selectedCameraID = activeCamera?.uniqueID ?? ""
        self.activeMicrophone = activeMicrophone
        self.selectedMicID = activeMicrophone?.uniqueID ?? ""
        self.selectedSettingsID = selectedSettingsID ?? nilUUID

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
        guard let timer = avTimer else { return nil }
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
        if device.uniqueID == activeCamera?.uniqueID || device.uniqueID == activeMicrophone?.uniqueID, avTimer != nil {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if avTimer != nil {
                    self.stopAVRecording()
                    showFailureAlert(message: "\(device.localizedName) disconnected. Recording stopped.")
                }
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
        avTimer?.reset()
        guard let ffmpegPath = Bundle.main.path(forResource: "ffmpeg", ofType: nil) else {
            avTimer?.isRecording = false
            showFailureAlert(message: "FFmpeg not found")
            return
        }

        guard let camIndex = devices.indexForVideoDevice(activeCamera) else {
            avTimer?.isRecording = false
            showFailureAlert(message: "Selected Camera not found")
            return
        }

        let micIndex = devices.indexForAudioDevice(activeMicrophone).map { "\($0)" } ?? ""

        showRecordingSavePanel { [weak self] url in
            guard let self, let url else {
                self?.avTimer?.isRecording = false
                return
            }

            let framerate = self.frameRate

            let input = micIndex.isEmpty ? "\(camIndex)" : "\(camIndex):\(micIndex)"

            var args = [
                "-f", "avfoundation",
                "-fflags", "nobuffer",
                "-flags", "low_delay",
                "-framerate", "\(framerate)"
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

            args.append("-preset")
            args.append("ultrafast")
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
            self.avTimer?.start()
            isAVRecording = true
        }
    }

    func stopAVRecording() {
        avTimer?.stop()
        avProcess?.terminate()
        avProcess = nil
        if isAVRecording {
            isAVRecording = false
        }
    }

    func stopAllRecordingsForBackground() {
        avTimer = nil
        stopAVRecording()
        session.stopRunning()
    }

    func stopAllRecordings() {
        stopAVRecording()
        avTimer = nil

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
        guard let ffplayPath = Bundle.main.path(forResource: "ffplay", ofType: nil) else {
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
            "-fflags", "nobuffer",
            "-flags", "low_delay"
        ]

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
        process.terminationHandler = { [weak self] process in
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
                } else if process.terminationStatus != 0 {
                    showFailureAlert(message: "FFplay exited with status \(process.terminationStatus).", completeMessage: output)
                }
            }
        }

        process.launch()
        ffplayProcesses[id] = process
    }

    func startIPRecording(id: UUID, settings: AVSettingViewModel, camera: IPCamera) {
        timers[id]?.reset()
        guard let ffmpegPath = Bundle.main.path(forResource: "ffmpeg", ofType: nil) else {
            showFailureAlert(message: "FFmpeg not found")
            timers[id]?.isRecording = false
            return
        }

        showRecordingSavePanel { [weak self] url in
            guard let self, let url else {
                self?.timers[id]?.isRecording = false
                return
            }

            var streamURL = camera.url
            if !camera.username.isEmpty, !camera.password.isEmpty {
                streamURL = streamURL.replacingOccurrences(of: "://", with: "://\(camera.username):\(camera.password)@")
            }

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

            args += applySettings(setting: selectedSettings, hasAudio: timers[id]?.hasAudio ?? false)

            if let time = makeTime(id: id) {
                args.append("-t")
                args.append(time)
            }

            args += ["-preset", "ultrafast", url.path]
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

            self.ipProcesses[id] = task
            task.launch()
            self.timers[id]?.start()
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

    func checkAudioStream(for camera: IPCamera, completion: @escaping (Bool) -> Void) {
        guard let ffprobePath = Bundle.main.path(forResource: "ffprobe", ofType: nil) else {
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
