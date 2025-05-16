//
//  MainViewModel.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 16/05/25.
//

import AVFoundation
import Foundation
import AppKit

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
    @Published var selectedSettingsID: UUID?
    @Published var useIPFeed: Bool = false

    private var avProcess: Process?

    init(activeCamera: AVCaptureDevice? = nil, activeMicrophone: AVCaptureDevice? = nil, selectedSettings: AVSettings? = nil) {
        self.activeCamera = activeCamera
        self.selectedCameraID = activeCamera?.uniqueID ?? ""
        self.activeMicrophone = activeMicrophone
        self.selectedMicID = activeMicrophone?.uniqueID ?? ""
        self.selectedSettings = selectedSettings
        self.selectedSettingsID = selectedSettings?.id
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
    private func deviceIndex(for device: AVCaptureDevice?, in list: [AVCaptureDevice]) -> Int? {
        guard let id = device?.uniqueID else { return nil }
        return list.firstIndex(where: { $0.uniqueID == id })
    }

    func startAVRecording(devices: AVViewModel) {
        guard let ffmpegPath = Bundle.main.path(forResource: "ffmpeg", ofType: nil) else {
            print("FFmpeg not found in bundle")
            return
        }

        guard
            let camIndex = deviceIndex(for: activeCamera, in: devices.videoDevices),
            let micIndex = deviceIndex(for: activeMicrophone, in: devices.audioDevices)
        else {
            print("Device indexes not found")
            return
        }

        // Prompt for output file
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.movie]
        panel.nameFieldStringValue = "recording.mov"
        panel.title = "Save Recording"

        panel.begin { [weak self] response in
            guard response == .OK, let url = panel.url else { return }

            let framerate = self?.frameRate ?? 30
            let size = self?.selectedSettings?.video.frameSize ?? "1280x720"

            let input = "\(camIndex):\(micIndex)"
            let args = [
                "-f", "avfoundation",
                "-framerate", "\(framerate)",
                "-video_size", size,
                "-i", input,
                "-preset", "ultrafast",
                url.path
            ]

            let task = Process()
            task.launchPath = ffmpegPath
            task.arguments = args
            task.standardOutput = nil
            task.standardError = nil

            self?.avProcess = task
            task.launch()
        }
    }

    func stopAVRecording() {
        avProcess?.terminate()
        avProcess = nil
    }
}
