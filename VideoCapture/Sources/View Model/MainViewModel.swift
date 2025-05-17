//
//  MainViewModel.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 16/05/25.
//

import AppKit
import AVFoundation
import Foundation

final class MainViewModel: ObservableObject {
    @Published var activeCamera: AVCaptureDevice?
    @Published var activeMicrophone: AVCaptureDevice?
    @Published var activeIPCameras: [IPCamera] = []
    @Published var selectedSettings: AVSettings?

    @Published var frameRate: Int32 = 30
    @Published var hr: String = ""
    @Published var min: String = ""
    @Published var sec: String = ""

    @Published var selectedCameraID: String
    @Published var selectedMicID: String
    @Published var selectedSettingsID: UUID
    @Published var useIPFeed: Bool = false

    private var avProcess: Process?
    let nilUUID = UUID()

    init(activeCamera: AVCaptureDevice? = nil, activeMicrophone: AVCaptureDevice? = nil, selectedSettings: AVSettings? = nil) {
        self.activeCamera = activeCamera
        self.selectedCameraID = activeCamera?.uniqueID ?? ""
        self.activeMicrophone = activeMicrophone
        self.selectedMicID = activeMicrophone?.uniqueID ?? ""
        self.selectedSettings = selectedSettings
        self.selectedSettingsID = selectedSettings?.id ?? nilUUID
    }

    func makeTime() -> String? {
        guard !hr.isEmpty || !min.isEmpty || !sec.isEmpty else { return nil }
        let hour = hr.isEmpty ? "00" : hr
        let minutes = min.isEmpty ? "00" : min
        let seconds = sec.isEmpty ? "00" : sec
        return "\(hour):\(minutes):\(seconds)"
    }

    func resetPreviewState() {
        activeCamera = nil
        activeMicrophone = nil
        activeIPCameras = []
        selectedSettings = nil
        hr = ""
        min = ""
        sec = ""
    }
}

extension MainViewModel {
    func startAVRecording(devices: AVViewModel) {
        stopAVRecording()
        guard let ffmpegPath = Bundle.main.path(forResource: "ffmpeg", ofType: nil) else {
            showFailureAlert(message: "FFmpeg not found")
            return
        }

        guard let camIndex = devices.indexForVideoDevice(activeCamera) else {
            showFailureAlert(message: "Selected Camera not found")
            return
        }

        let micIndex = devices.indexForAudioDevice(activeMicrophone).map { "\($0)" } ?? ""

        showRecordingSavePanel { [weak self] url in
            guard let self, let url else { return }

            let framerate = self.frameRate

            let input = micIndex.isEmpty ? "\(camIndex)" : "\(camIndex):\(micIndex)"


            var args = [
                "-f", "avfoundation",
                "-fflags", "nobuffer",
                "-flags", "low_delay",
                "-framerate", "\(framerate)"
            ]
            
            // Video Frame Size
            if let frameSize = selectedSettings?.video.frameSize, !frameSize.isEmpty {
                args.append("-video_size")
                args.append(frameSize)
            }

            args.append("-i")
            args.append(input)

            let settingArgument = self.applySettings(cameraIndex: "\(camIndex)", microphoneIndex: micIndex)
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

                guard !errorLines.isEmpty else { return }

                DispatchQueue.main.async {
                    self?.stopAVRecording()
                    showFailureAlert(message: "FFmpeg failed to save or start the recording, please check the console for more information.")
                }
            }

            self.avProcess = task
            task.launch()
        }
    }

    func stopAVRecording() {
        avProcess?.terminate()
        avProcess = nil
    }

    func applySettings(cameraIndex: String, microphoneIndex: String) -> [String] {
        var arguments: [String] = []
        guard let setting = selectedSettings else { return arguments }

        // Video Settings
        if !cameraIndex.isEmpty {
            // Video Codec
            let codec = setting.video.codec
            arguments.append("-vcodec")
            arguments.append(codec.value)

            // Video Scaling Mode
            if let scale = setting.video.scalingMode?.rawValue, !scale.isEmpty {
                arguments.append("-vf")
                arguments.append(scale)
            }

            // Video Bit Rate
            let bitRate = setting.video.bitRate
            if !bitRate.isEmpty, Int(bitRate) != nil {
                arguments.append("-b:v")
                arguments.append("\(bitRate)k")
            }

            // Video Key Frame Interval
            let keyInterval = setting.video.keyFrameInterval
            if !keyInterval.isEmpty, Int(keyInterval) != nil {
                arguments.append("-g")
                arguments.append(keyInterval)
            }

            // Video Profile (only for h264 or h265)
            if let profile = setting.video.profile, profile != .none {
                if codec == .h264 || codec == .h265 {
                    arguments.append("-profile:v")
                    arguments.append(profile.value)
                    arguments.append("-level")
                    arguments.append(profile.levelValue)
                }
            }
        }

        // Audio Settings
        if !microphoneIndex.isEmpty {
            // Audio Codec
            let codec = setting.audio.codec
            arguments.append("-acodec")
            arguments.append(codec.rawValue)

            // For Linear PCM codec (pcm_s16le)
            if codec == .linearPCM {
                arguments.append("-f")
                arguments.append("s16le") // 16-bit signed little-endian

                if let isBigEndian = setting.audio.isBigEndian, isBigEndian {
                    arguments.append("-format_flags")
                    arguments.append("+bigendian")
                }

                if let isFloat = setting.audio.isFloat, isFloat {
                    arguments.append("-format_flags")
                    arguments.append("+float")
                }
            }

            // Audio Sample Rate
            let sampleRate = setting.audio.sampleRate.rawValue
            arguments.append("-ar")
            arguments.append(sampleRate)

            // Audio Bit Rate
            let bitRate = setting.audio.bitRate.rawValue
            arguments.append("-b:a")
            arguments.append(bitRate)

            // Special handling for AAC codecs
            if codec == .mpeg_4HighEfficiencyAAC {
                switch setting.audio.bitRateMode {
                case .perChannel:
                    // Constant Bitrate mode - no extra flag needed, bitrate already set
                    break
                case .allChannels:
                    arguments.append("-vbr")
                    arguments.append("4") // Common VBR quality level for libfdk_aac
                }
            } else if codec == .mpeg_4LowComplexAAC {
                arguments.append("-strict")
                arguments.append("-2") // Enable experimental AAC encoder
            }

            // Audio Channel Count
            let channelCount = setting.audio.channels.rawValue
            arguments.append("-ac")
            arguments.append(channelCount)

            // Audio Channel Type - pan filter for stereo downmixing
            if let panFilter = audioFilterForChannelType(setting.audio.channelType, channelCount: channelCount) {
                arguments.append("-af")
                arguments.append(panFilter)
            }
        }

        return arguments
    }
}
