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
        let deviceVM = AVViewModel()
        let settingVM = AVSettingViewModel()
        self.devices = deviceVM
        self.settings = settingVM
        self.cameras = IPCameraViewModel()
        self.viewModel = MainViewModel(activeCamera: deviceVM.videoDevices.first, activeMicrophone: deviceVM.audioDevices.first, selectedSettings: settingVM.AVSettingData.first)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(devices: devices, viewModel: viewModel, settings: settings, cameras: cameras)
        }
    }
}
