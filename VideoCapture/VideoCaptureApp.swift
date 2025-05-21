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

    @StateObject var devices: AVViewModel
    @StateObject var viewModel: MainViewModel
    @StateObject var settings: AVSettingViewModel
    @StateObject var cameras: IPCameraViewModel

    init() {
        let deviceVM = AVViewModel()
        let settingVM = AVSettingViewModel()
        _devices = StateObject(wrappedValue: deviceVM)
        _settings = StateObject(wrappedValue: settingVM)
        _cameras = StateObject(wrappedValue: IPCameraViewModel())
        _viewModel = StateObject(wrappedValue: MainViewModel(activeCamera: deviceVM.videoDevices.first, activeMicrophone: deviceVM.audioDevices.first, selectedSettingsID: settingVM.AVSettingData.first?.id))
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
