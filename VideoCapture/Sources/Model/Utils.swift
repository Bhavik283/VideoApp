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

func showFailureAlert(message: String) {
    let alert = NSAlert()
    alert.messageText = "Operation Failed"
    alert.informativeText = message
    alert.alertStyle = .warning
    alert.addButton(withTitle: "OK")
    alert.runModal()
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
