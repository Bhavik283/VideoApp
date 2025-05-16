//
//  VideoCaptureApp.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 13/05/25.
//

import SwiftUI

@main
struct VideoCaptureApp: App {
    @ObservedObject var devices: AVViewModel
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject var settings: AVSettingViewModel
    @ObservedObject var cameras: IPCameraViewModel
    
    init() {
        self.devices = AVViewModel()
        self.settings = AVSettingViewModel()
        self.cameras = IPCameraViewModel()
        self.viewModel = MainViewModel()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(devices: devices, viewModel: viewModel, settings: settings, cameras: cameras)
        }
    }
}
