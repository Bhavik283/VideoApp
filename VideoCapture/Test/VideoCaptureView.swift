//
//  VideoCaptureView.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 14/05/25.
//


import AVFoundation
import SwiftUI

// MARK: - SwiftUI Capture View

struct VideoCaptureView: NSViewRepresentable {
    var session: AVCaptureSession

    func makeNSView(context: Context) -> CaptureView {
        let view = CaptureView()
        view.configure(with: session)
        return view
    }

    func updateNSView(_ nsView: CaptureView, context: Context) {
        nsView.configure(with: session)
    }
}

class CaptureView: NSView {
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
    }

    func configure(with session: AVCaptureSession) {
        // If already set to this session, skip
        if previewLayer?.session == session {
            return
        }

        previewLayer?.removeFromSuperlayer()

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        self.layer = CALayer()
        self.layer?.addSublayer(layer)
        previewLayer = layer

        needsLayout = true
    }

    override func layout() {
        super.layout()
        previewLayer?.frame = bounds
    }
}