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
                    viewModel.activeIPCameras.append(ipCamera)
                } else {
                    viewModel.activeIPCameras.removeAll { $0.id == ipCamera.id }
                }
            }
        )
    }

    var body: some View {
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
                        viewModel.activeIPCameras = []
                        viewModel.selectedSettingsID = settings.AVSettingData.first?.id ?? viewModel.nilUUID
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
                        Text("No Presets").tag(viewModel.nilUUID as UUID)
                    }
                    ForEach(settings.AVSettingData) { setting in
                        Text(setting.name).tag(setting.id as UUID)
                    }
                }
                .onChange(of: viewModel.selectedSettingsID) { _, newID in
                    if newID == viewModel.nilUUID {
                        viewModel.selectedSettings = nil
                    } else if let selected = settings.AVSettingData.first(where: { $0.id == newID }) {
                        viewModel.selectedSettings = selected
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
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
