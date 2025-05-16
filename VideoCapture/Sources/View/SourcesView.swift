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

    @State private var selectedCameraID: String = ""
    @State private var selectedMicID: String = ""
    @State private var selectedSettingsID: UUID?
    @State private var useIPFeed: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Video Source").font(.headline)

            VStack(alignment: .leading) {
                List {
                    Picker("Camera", selection: $selectedCameraID) {
                        ForEach(devices.videoDevices, id: \.uniqueID) { camera in
                            Text(camera.localizedName).tag(camera.uniqueID)
                        }
                        Text("IP Feeds").tag("IP_FEED")
                    }
                    .pickerStyle(.radioGroup)
                    .labelsHidden()
                    .listRowSeparator(.hidden)
                    .onAppear {
                        if let defaultCamera = devices.videoDevices.first {
                            selectedCameraID = defaultCamera.uniqueID
                            viewModel.activeCamera = defaultCamera
                        }
                        if let defaultMic = devices.audioDevices.first {
                            selectedMicID = defaultMic.uniqueID
                            viewModel.activeMicrophone = defaultMic
                        }
                        selectedSettingsID = settings.AVSettingData.first?.id
                        viewModel.selectedSettings = settings.AVSettingData.first
                    }
                    .onChange(of: selectedCameraID) { _, newID in
                        useIPFeed = newID == "IP_FEED"
                        viewModel.activeCamera = devices.videoDevices.first(where: { $0.uniqueID == newID })
                        viewModel.activeIPCameras = []
                    }
                    VStack(alignment: .leading) {
                        ForEach(cameras.cameraList) { ipCamera in
                            Toggle(ipCamera.name, isOn: Binding(
                                get: { viewModel.activeIPCameras.contains(ipCamera) },
                                set: { isOn in
                                    if isOn {
                                        viewModel.activeIPCameras.append(ipCamera)
                                    } else {
                                        viewModel.activeIPCameras.removeAll { $0.id == ipCamera.id }
                                    }
                                }
                            ))
                        }
                    }
                    .padding(.leading)
                    .disabled(!useIPFeed)
                    .listRowSeparator(.hidden)
                }
                .frame(maxWidth: .infinity, maxHeight: 200)
            }
            .overlay(Rectangle().stroke(lineWidth: 1))

            if !useIPFeed {
                LabelView(label: "Audio Input") {
                    Picker("Microphone", selection: $selectedMicID) {
                        ForEach(devices.audioDevices, id: \.uniqueID) { mic in
                            Text(mic.localizedName).tag(mic.uniqueID)
                        }
                    }
                    .onChange(of: selectedMicID) { _, newID in
                        viewModel.activeMicrophone = devices.audioDevices.first(where: { $0.uniqueID == newID })
                    }
                }
            }

            LabelView(label: "Settings") {
                Picker("Settings", selection: $selectedSettingsID) {
                    ForEach(settings.AVSettingData) { setting in
                        Text(setting.name).tag(setting.id as UUID?)
                    }
                }
                .onChange(of: selectedSettingsID) { _, newID in
                    if let id = newID, let selected = settings.AVSettingData.first(where: { $0.id == id }) {
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
