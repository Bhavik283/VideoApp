//
//  AVViewModel.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 15/05/25.
//

import AVFoundation
import Combine
import Foundation

final class AVViewModel: ObservableObject {
    @Published var videoDevices: [AVCaptureDevice] = []
    @Published var audioDevices: [AVCaptureDevice] = []

    private(set) var videoDeviceIndexMap: [String: Int] = [:]
    private(set) var audioDeviceIndexMap: [String: Int] = [:]

    private var observers: [AnyCancellable] = []

    init() {
        fetchDevices()
        observeDeviceChanges()
    }

    private func fetchDevices() {
        // Video
        let video = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .external],
            mediaType: .video,
            position: .unspecified
        )
        videoDevices = video.devices
        videoDeviceIndexMap = Dictionary(uniqueKeysWithValues: video.devices.enumerated().map { ($1.uniqueID, $0) })

        // Audio
        let audio = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.microphone, .external],
            mediaType: .audio,
            position: .unspecified
        )
        audioDevices = audio.devices
        audioDeviceIndexMap = Dictionary(uniqueKeysWithValues: audio.devices.enumerated().map { ($1.uniqueID, $0) })
    }

    private func observeDeviceChanges() {
        let center = NotificationCenter.default

        center.publisher(for: AVCaptureDevice.wasConnectedNotification)
            .sink { [weak self] _ in self?.fetchDevices() }
            .store(in: &observers)

        center.publisher(for: AVCaptureDevice.wasDisconnectedNotification)
            .sink { [weak self] _ in self?.fetchDevices() }
            .store(in: &observers)
    }

    func indexForVideoDevice(_ device: AVCaptureDevice) -> Int? {
        return videoDeviceIndexMap[device.uniqueID]
    }

    func indexForAudioDevice(_ device: AVCaptureDevice) -> Int? {
        return audioDeviceIndexMap[device.uniqueID]
    }
}
