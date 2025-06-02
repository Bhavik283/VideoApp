//
//  Utils.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 17/05/25.
//

import AppKit
import Foundation
import UniformTypeIdentifiers

func pickSDPFile(completion: @escaping (URL?) -> Void) {
    let panel = NSOpenPanel()
    if let sdpType = UTType(filenameExtension: "sdp") {
        panel.allowedContentTypes = [sdpType]
    } else {
        panel.allowedFileTypes = ["sdp"]
    }
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = false
    panel.title = "Select an SDP File"

    panel.begin { result in
        completion(result == .OK ? panel.url : nil)
    }
}

func showFailureAlert(message: String, completeMessage: String? = nil) {
    DispatchQueue.main.async {
        let alert = NSAlert()
        alert.messageText = "Operation Failed"
        alert.alertStyle = .warning
        alert.informativeText = message
        alert.addButton(withTitle: "OK")

        if let completeMessage {
            let scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: 400, height: 150))
            scrollView.hasVerticalScroller = true
            scrollView.borderType = .bezelBorder

            let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: 400, height: 150))
            textView.string = completeMessage
            textView.isEditable = false
            textView.isSelectable = true
            textView.drawsBackground = false
            textView.textColor = .labelColor

            scrollView.documentView = textView
            alert.accessoryView = scrollView
        }

        alert.runModal()
    }
}

func currentTimestampString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
    return formatter.string(from: Date())
}

func showRecordingSavePanel(completion: @escaping (URL?) -> Void) {
    let timestamp = currentTimestampString()
    let defaultFileName = "Recording_\(timestamp).mp4"

    let savePanel = NSSavePanel()
    savePanel.allowedContentTypes = [.movie]
    savePanel.canCreateDirectories = true
    savePanel.nameFieldStringValue = defaultFileName
    savePanel.title = "Save Recording"

    savePanel.begin { response in
        completion(response == .OK ? savePanel.url : nil)
    }
}

func audioFilterForChannelType(_ type: ChannelType, channelCount: String) -> String? {
    switch type {
    case .stereoLR:
        switch channelCount {
        case "2":
            // Simple stereo: map left and right directly
            return "pan=stereo|c0=c0|c1=c1"

        case "4":
            // Quad audio: mix front and back channels into stereo left/right
            // Left = Front Left + Back Left (c0 + c2)
            // Right = Front Right + Back Right (c1 + c3)
            return "pan=stereo|c0=0.5*c0+0.5*c2|c1=0.5*c1+0.5*c3"

        case "6":
            // 5.1 audio downmix to stereo
            // Left = Front Left + Back Left + 0.7 * Center
            // Right = Front Right + Back Right + 0.7 * Center
            let centerWeight = 0.35 // 0.7 * 0.5
            return "pan=stereo|c0=0.5*c0+0.5*c4+\(centerWeight)*c2|c1=0.5*c1+0.5*c5+\(centerWeight)*c2"

        case "8":
            // 7.1 audio downmix to stereo
            // Left = Front Left + Back Left + Side Left + 0.7 * Center
            // Right = Front Right + Back Right + Side Right + 0.7 * Center
            let channelWeight = 0.3
            let centerWeight = 0.21 // 0.7 * 0.3
            return "pan=stereo|c0=\(channelWeight)*c0+\(channelWeight)*c4+\(channelWeight)*c6+\(centerWeight)*c2|c1=\(channelWeight)*c1+\(channelWeight)*c5+\(channelWeight)*c7+\(centerWeight)*c2"

        default:
            // Unsupported channel count for stereoLR mapping
            return nil
        }

    case .default:
        // No downmix filter needed or unsupported channel type
        return nil
    }
}

func applySettings(cameraIndex: String, microphoneIndex: String, setting: AVSettings?) -> [String] {
    var arguments: [String] = []
    guard let setting else { return arguments }

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
        arguments.append(codec.value)

        if let profile = codec.profile {
            arguments.append("-profile:a")
            arguments.append(profile)
        }

        // For Linear PCM codec (pcm_s16le)
        if codec == .linearPCM {
            arguments.append("-f")

            let isFloat = setting.audio.isFloat ?? false
            let isBigEndian = setting.audio.isBigEndian ?? false

            if isFloat {
                arguments.append(isBigEndian ? "pcm_f32be" : "pcm_f32le")
            } else {
                arguments.append(isBigEndian ? "s16be" : "s16le")
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

func applySettings(setting: AVSettings?, hasAudio: Bool) -> [String] {
    var arguments: [String] = []
    guard let setting else { return arguments }

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

    // Audio Settings
    if hasAudio {
        // Audio Codec
        let codec = setting.audio.codec
        arguments.append("-acodec")
        arguments.append(codec.value)

        if let profile = codec.profile {
            arguments.append("-profile:a")
            arguments.append(profile)
        }

        // For Linear PCM codec (pcm_s16le)
        if codec == .linearPCM {
            arguments.append("-f")

            let isFloat = setting.audio.isFloat ?? false
            let isBigEndian = setting.audio.isBigEndian ?? false

            if isFloat {
                arguments.append(isBigEndian ? "pcm_f32be" : "pcm_f32le")
            } else {
                arguments.append(isBigEndian ? "s16be" : "s16le")
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

func shell(command: String) -> String? {
    let commonBrewPaths = [
        "/opt/homebrew/bin", // Apple Silicon
        "/usr/local/bin" // Intel
    ]

    for brewPath in commonBrewPaths {
        let task = Process()
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        var environment = ProcessInfo.processInfo.environment
        let existingPath = environment["PATH"] ?? ""
        environment["PATH"] = "\(brewPath):\(existingPath)"
        task.environment = environment

        task.arguments = ["-c", command]
        task.launchPath = "/bin/zsh"
        task.standardInput = nil

        do {
            try task.run()
            task.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8), !output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return output.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            print("Shell error with PATH=\(brewPath): \(error)")
        }
    }

    return nil
}
