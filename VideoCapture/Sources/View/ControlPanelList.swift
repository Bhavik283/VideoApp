//
//  ControlPanelList.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 18/05/25.
//

import SwiftUI

struct ControlPanelList: View {
    @ObservedObject var devices: AVViewModel
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject var settings: AVSettingViewModel
    @ObservedObject var cameras: IPCameraViewModel

    @State var isRecordingAll: Bool = false

    var body: some View {
        VStack {
            ScrollView {
                ForEach(viewModel.activeIPCameras) { camera in
                    if let timer = viewModel.timers[camera.id] {
                        Section {
                            IPControlPanelView(isRecordingAll: $isRecordingAll, viewModel: viewModel, settings: settings, timer: timer, camera: camera)
                        } header: {
                            HStack {
                                Text(camera.name)
                                    .font(.title2)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 3)
                        }
                        Divider().padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                    }
                }
            }
        }
        .frame(width: 400)
        .toolbar {
            ToolbarItem {
                Button("", systemImage: isRecordingAll ? "square.fill" : "record.circle.fill") {
                    isRecordingAll.toggle()
                }
            }
            ToolbarItem {
                Button("", systemImage: "gear") {
                    WindowManager.shared.showInspector(with: InspectorView(devices: devices, viewModel: viewModel, settings: settings, cameras: cameras))
                }
            }
        }
        .navigationTitle("IP Camera Control")
        .onChange(of: isRecordingAll) { _, _ in
            if isRecordingAll {
                viewModel.startAllRecordings(settings: settings)
            } else {
                for camera in viewModel.activeIPCameras {
                    if let timer = viewModel.timers[camera.id] {
                        timer.isRecording = false
                    }
                }
            }
        }
    }
}

struct IPControlPanelView: View {
    @State var showingTimerField: Bool = false
    @Binding var isRecordingAll: Bool

    @ObservedObject var viewModel: MainViewModel
    @ObservedObject var settings: AVSettingViewModel
    @ObservedObject private var timer: TimerModel

    let camera: IPCamera
    let id: UUID

    init(isRecordingAll: Binding<Bool>, viewModel: MainViewModel, settings: AVSettingViewModel, timer: TimerModel, camera: IPCamera) {
        self._isRecordingAll = isRecordingAll
        self.id = camera.id
        self.timer = timer
        self.viewModel = viewModel
        self.settings = settings
        self.camera = camera
    }

    var body: some View {
        HStack {
            Text(timer.timeText)
            IconButton(icon: "arrow.clockwise", color: Color.white) {
                timer.reset()
            }
            .disabled(timer.isRecording)
            Spacer()
            HStack {
                IconButton(
                    icon: timer.isRecording ? "square.fill" : "record.circle.fill",
                    color: Color.red,
                    action: {
                        timer.isRecording.toggle()
                    }
                )
            }
            Spacer()
            if showingTimerField {
                TimerTextField(hr: timer.hrBinding, min: timer.minBinding, sec: timer.secBinding)
                    .disabled(timer.isRecording)
                    .padding(.trailing, 10)
            }
            IconButton(icon: "clock.fill", color: Color.white) {
                showingTimerField.toggle()
            }
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .background(Color.gray)
        .onChange(of: timer.isRecording) { _, newValue in
            if newValue && !isRecordingAll {
                viewModel.startIPRecording(id: id, settings: settings, camera: camera)
            } else if !newValue {
                viewModel.closeFFplayWindow(id: id)
            }
        }
    }
}
