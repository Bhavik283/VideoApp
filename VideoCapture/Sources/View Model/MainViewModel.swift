//
//  MainViewModel.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 16/05/25.
//

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
