//
//  StorageViewModel.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 15/05/25.
//

import Foundation

class StorageViewModel {
    static let shared = StorageViewModel()

    init() {}

    // MARK: - Keys

    private let avSettingsKey = "AVSettingsKey"
    private let ipCamerasKey = "IPCameraKey"

    private let defaults = UserDefaults.standard

    // MARK: - AVSettings

    func saveAVSettings(_ settings: [AVSettings]) {
        do {
            let data = try JSONEncoder().encode(settings)
            defaults.set(data, forKey: avSettingsKey)
        } catch {
            print("Failed to encode AVSettings: \(error)")
        }
    }

    func loadAVSettings() -> [AVSettings] {
        guard let data = defaults.data(forKey: avSettingsKey) else { return [] }
        do {
            return try JSONDecoder().decode([AVSettings].self, from: data)
        } catch {
            print("Failed to decode AVSettings: \(error)")
            return []
        }
    }

    // MARK: - IPCameras

    func saveIPCameras(_ cameras: [IPCamera]) {
        do {
            let data = try JSONEncoder().encode(cameras)
            defaults.set(data, forKey: ipCamerasKey)
        } catch {
            print("Failed to encode IPCameras: \(error)")
        }
    }

    func loadIPCameras() -> [IPCamera] {
        guard let data = defaults.data(forKey: ipCamerasKey) else { return [] }
        do {
            return try JSONDecoder().decode([IPCamera].self, from: data)
        } catch {
            print("Failed to decode IPCameras: \(error)")
            return []
        }
    }
}
