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

    var body: some View {
        Text("ControlPanelList")
    }
}

struct IPControlPanelView: View {
    @State var showingTimerField: Bool = false

    @ObservedObject var viewModel: MainViewModel
    @ObservedObject var settings: AVSettingViewModel
    @ObservedObject private var timer: TimerModel
    let camera: IPCamera

    let id: UUID

    init(id: UUID, viewModel: MainViewModel, settings: AVSettingViewModel, timer: TimerModel, camera: IPCamera) {
        self.id = id
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
            .padding(.trailing, 20)
            HStack {
                IconButton(
                    icon: timer.isRecording ? "square.fill" : "record.circle.fill",
                    color: Color.red,
                    action: {
                        timer.isRecording.toggle()
                    }
                )
            }
            .frame(width: 40)
            if showingTimerField {
                TimerTextField(hr: timer.hrBinding, min: timer.minBinding, sec: timer.secBinding)
                    .disabled(timer.isRecording)
            }
            IconButton(icon: "clock.fill", color: Color.white) {
                showingTimerField.toggle()
            }
        }
        .padding(20)
        .background(Color.gray)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .onChange(of: timer.isRecording) { _, newValue in
            if newValue {
                viewModel.startIPRecording(id: id, settings: settings, camera: camera)
            } else {
                viewModel.stopIPRecording(id: id)
            }
        }
    }
}
