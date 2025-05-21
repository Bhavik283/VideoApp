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
        coordinator.previewLayer.videoGravity = .resizeAspect
        return coordinator
    }

    func makeNSView(context: Context) -> NSView {
        let nsView = NSView()
        nsView.wantsLayer = true
        context.coordinator.previewLayer.frame = nsView.bounds
        context.coordinator.previewLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        nsView.layer?.addSublayer(context.coordinator.previewLayer)

        context.coordinator.updateSession(session: viewModel.session, viewModel: viewModel)
        viewModel.session.startRunning()

        return nsView
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.updateSession(session: viewModel.session, viewModel: viewModel)
    }

    class Coordinator {
        var previewLayer = AVCaptureVideoPreviewLayer()
        var updateSessionWorkItem: DispatchWorkItem?
        
        func scheduleSessionUpdate(viewModel: MainViewModel) {
            updateSessionWorkItem?.cancel()
            updateSessionWorkItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                self.updateSession(session: viewModel.session, viewModel: viewModel)
            }

            if let updateSessionWorkItem {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: updateSessionWorkItem)
            }
        }
        
        func updateSession(session: AVCaptureSession, viewModel: MainViewModel) {
            session.beginConfiguration()
            session.inputs.forEach { session.removeInput($0) }
            
            if let camera = viewModel.activeCamera, let videoInput = try? AVCaptureDeviceInput(device: camera), session.canAddInput(videoInput) {
                session.addInput(videoInput)
                
                configureCameraFrameRate(camera: camera, targetFPS: viewModel.frameRate)
            }
            
            if let mic = viewModel.activeMicrophone, let audioInput = try? AVCaptureDeviceInput(device: mic), session.canAddInput(audioInput) {
                session.addInput(audioInput)
            }
            
            session.commitConfiguration()
        }
        
        func configureCameraFrameRate(camera: AVCaptureDevice, targetFPS: Int32) {
            do {
                try camera.lockForConfiguration()
                
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
                }
                
                camera.unlockForConfiguration()
            } catch {
                camera.unlockForConfiguration()
                showFailureAlert(message: "Failed to configure camera frame rate: \(error.localizedDescription)")
            }
        }
    }
}
