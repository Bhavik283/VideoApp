//
//  SourcesView.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 13/05/25.
//

import SwiftUI

struct SourcesView: View {
    @ObservedObject var devices: AVViewModel
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject var settings: AVSettingViewModel
    @ObservedObject var cameras: IPCameraViewModel

    func toggleBinding(ipCamera: IPCamera) -> Binding<Bool> {
        Binding(
            get: { viewModel.activeIPCameras.contains(ipCamera) },
            set: { isOn in
                if isOn {
                    WindowManager.shared.bringToFront(true)
                    viewModel.startIPCameraWindow(ipCamera: ipCamera)
                } else {
                    viewModel.closeFFplayWindow(id: ipCamera.id)
                }
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Video Source").font(.headline)
                
                VStack(alignment: .leading) {
                    List {
                        Picker("Camera", selection: $viewModel.selectedCameraID) {
                            ForEach(devices.videoDevices, id: \.uniqueID) { camera in
                                Text(camera.localizedName).tag(camera.uniqueID)
                            }
                            Text("IP Feeds").tag("IP_FEED")
                        }
                        .pickerStyle(.radioGroup)
                        .labelsHidden()
                        .listRowSeparator(.hidden)
                        .onChange(of: viewModel.selectedCameraID) { _, newID in
                            viewModel.useIPFeed = newID == "IP_FEED"
                            viewModel.activeCamera = devices.videoDevices.first(where: { $0.uniqueID == newID })
                            if viewModel.selectedSettingsID == viewModel.nilUUID && newID != "IP_FEED" {
                                viewModel.selectedSettingsID = settings.AVSettingData.first?.id ?? HD720.id
                            }
                            if newID != "IP_FEED" {
                                viewModel.closeAllFFplayWindows()
                                viewModel.openWindow?()
                            } else {
                                viewModel.closeWindow?()
                            }
                            viewModel.activeIPCameras = []
                            WindowManager.shared.bringToFront(newID == "IP_FEED")
                        }
                        VStack(alignment: .leading) {
                            ForEach(cameras.cameraList) { ipCamera in
                                Toggle(ipCamera.name, isOn: toggleBinding(ipCamera: ipCamera))
                            }
                        }
                        .padding(.leading)
                        .disabled(!viewModel.useIPFeed)
                        .listRowSeparator(.hidden)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 200)
                }
                .overlay(Rectangle().stroke(lineWidth: 1))
                
                if !viewModel.useIPFeed {
                    LabelView(label: "Audio Input") {
                        Picker("Microphone", selection: $viewModel.selectedMicID) {
                            ForEach(devices.audioDevices, id: \.uniqueID) { mic in
                                Text(mic.localizedName).tag(mic.uniqueID)
                            }
                        }
                        .onChange(of: viewModel.selectedMicID) { _, newID in
                            viewModel.activeMicrophone = devices.audioDevices.first(where: { $0.uniqueID == newID })
                        }
                    }
                }
                
                LabelView(label: "Settings") {
                    Picker("Settings", selection: $viewModel.selectedSettingsID) {
                        if viewModel.useIPFeed {
                            Text("From Source").tag(viewModel.nilUUID as UUID)
                        }
                        ForEach(settings.AVSettingData) { setting in
                            Text(setting.name).tag(setting.id as UUID)
                        }
                    }
                }
                
                LabelView(label: "Frame Rate") {
                    Picker("Frame Rate", selection: $viewModel.frameRate) {
                        ForEach(frameRates, id: \.self) { rate in
                            Text("\(rate) fps").tag(Int32(rate))
                        }
                    }
                }
                .disabled(viewModel.useIPFeed)
                Spacer()
            }
            .disabled(viewModel.isAVRecording)
            if viewModel.isAVRecording {
                Text("⚠️ Changing sources during a recording can corrupt the video.")
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
