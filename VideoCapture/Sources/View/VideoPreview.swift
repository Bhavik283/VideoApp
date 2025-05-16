//
//  VideoPreview.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 16/05/25.
//

import AVFoundation
import SwiftUI

struct VideoPreview: NSViewRepresentable {
    @ObservedObject var viewModel: MainViewModel

    class Coordinator {
        var session = AVCaptureSession()
        var previewLayer = AVCaptureVideoPreviewLayer()
    }

    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        coordinator.previewLayer = AVCaptureVideoPreviewLayer(session: coordinator.session)
        coordinator.previewLayer.videoGravity = .resizeAspectFill
        return coordinator
    }

    func makeNSView(context: Context) -> NSView {
        let nsView = NSView()
        nsView.wantsLayer = true
        context.coordinator.previewLayer.frame = nsView.bounds
        context.coordinator.previewLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        nsView.layer?.addSublayer(context.coordinator.previewLayer)

        updateSession(session: context.coordinator.session)
        context.coordinator.session.startRunning()

        return nsView
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        updateSession(session: context.coordinator.session)
    }

    private func updateSession(session: AVCaptureSession) {
        session.beginConfiguration()
        session.inputs.forEach { session.removeInput($0) }

        if let camera = viewModel.activeCamera, let videoInput = try? AVCaptureDeviceInput(device: camera), session.canAddInput(videoInput) {
            session.addInput(videoInput)

            let format = camera.activeFormat
            for range in format.videoSupportedFrameRateRanges {
                if range.maxFrameRate >= Double(viewModel.frameRate) {
                    try? camera.lockForConfiguration()
                    camera.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: viewModel.frameRate)
                    camera.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: viewModel.frameRate)
                    camera.unlockForConfiguration()
                    break
                }
            }
        }

        if let mic = viewModel.activeMicrophone, let audioInput = try? AVCaptureDeviceInput(device: mic), session.canAddInput(audioInput) {
            session.addInput(audioInput)
        }

        session.commitConfiguration()
    }
}
