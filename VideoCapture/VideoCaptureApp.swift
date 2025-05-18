//
//  VideoCaptureApp.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 13/05/25.
//

import SwiftUI

@main
struct VideoCaptureApp: App {
    @Environment(\.scenePhase) private var scenePhase

    @ObservedObject var devices: AVViewModel
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject var settings: AVSettingViewModel
    @ObservedObject var cameras: IPCameraViewModel

    init() {
        let deviceVM = AVViewModel()
        let settingVM = AVSettingViewModel()
        devices = deviceVM
        settings = settingVM
        cameras = IPCameraViewModel()
        viewModel = MainViewModel(activeCamera: deviceVM.videoDevices.first, activeMicrophone: deviceVM.audioDevices.first, selectedSettingsID: settingVM.AVSettingData.first?.id)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(devices: devices, viewModel: viewModel, settings: settings, cameras: cameras)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                viewModel.stopAllRecordingsForBackground()
            }
        }
    }
}
