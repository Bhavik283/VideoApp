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

    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        coordinator.previewLayer = AVCaptureVideoPreviewLayer(session: viewModel.session)
        coordinator.previewLayer.videoGravity = .resizeAspectFill
        return coordinator
    }

    func makeNSView(context: Context) -> NSView {
        let nsView = NSView()
        nsView.wantsLayer = true
        context.coordinator.previewLayer.frame = nsView.bounds
        context.coordinator.previewLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        nsView.layer?.addSublayer(context.coordinator.previewLayer)

        context.coordinator.scheduleSessionUpdate(viewModel: viewModel) {
            if !viewModel.session.isRunning {
                viewModel.session.startRunning()
            }
        }

        return nsView
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.scheduleSessionUpdate(viewModel: viewModel) {
            if !viewModel.session.isRunning {
                viewModel.session.startRunning()
            }
        }
    }

    class Coordinator {
        var previewLayer = AVCaptureVideoPreviewLayer()
        var updateSessionWorkItem: DispatchWorkItem?
        let sessionQueue = DispatchQueue(label: "video.session.queue")

        func scheduleSessionUpdate(viewModel: MainViewModel, completion: @escaping () -> Void) {
            updateSessionWorkItem?.cancel()

            let camera = viewModel.activeCamera
            let mic = viewModel.activeMicrophone

            updateSessionWorkItem = DispatchWorkItem { [weak self] in
                guard let self else { return }
                self.sessionQueue.async {
                    self.updateSession(session: viewModel.session, camera: camera, mic: mic, viewModel: viewModel)
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }

            if let updateSessionWorkItem {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: updateSessionWorkItem)
            }
        }

        func updateSession(session: AVCaptureSession, camera: AVCaptureDevice?, mic: AVCaptureDevice?, viewModel: MainViewModel) {
            guard !viewModel.isAVRecording else { return }

            session.beginConfiguration()
            session.inputs.forEach { session.removeInput($0) }

            if let camera, let videoInput = try? AVCaptureDeviceInput(device: camera), session.canAddInput(videoInput) {
                session.addInput(videoInput)
                configureCameraFrameRate(camera: camera, viewModel: viewModel)
            }

            if let mic, let audioInput = try? AVCaptureDeviceInput(device: mic), session.canAddInput(audioInput) {
                session.addInput(audioInput)
            }

            session.commitConfiguration()
        }

        func configureCameraFrameRate(camera: AVCaptureDevice, viewModel: MainViewModel) {
            let targetFPS = viewModel.frameRate
            do {
                try camera.lockForConfiguration()
                defer { camera.unlockForConfiguration() }

                let supportedRanges = camera.activeFormat.videoSupportedFrameRateRanges
                let isSupported = supportedRanges.contains { range in
                    Double(targetFPS) >= range.minFrameRate && Double(targetFPS) <= range.maxFrameRate
                }

                if isSupported {
                    let duration = CMTimeMake(value: 1, timescale: targetFPS)
                    camera.activeVideoMinFrameDuration = duration
                    camera.activeVideoMaxFrameDuration = duration
                } else {
                    let defaultFPS = Int32(supportedRanges.first?.minFrameRate ?? 30)
                    let duration = CMTimeMake(value: 1, timescale: defaultFPS)
                    camera.activeVideoMinFrameDuration = duration
                    camera.activeVideoMaxFrameDuration = duration

                    showFailureAlert(message: "Selected frame rate (\(targetFPS) fps) is not supported by the camera. Defaulted to \(defaultFPS) fps.")
                    DispatchQueue.main.async {
                        viewModel.frameRate = defaultFPS
                    }
                }
            } catch {
                showFailureAlert(message: "Failed to configure camera frame rate: \(error.localizedDescription)")
            }
        }
    }
}
