//
//  ControlPanelView.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 15/05/25.
//

import SwiftUI

struct ControlPanelView: View {
    @State var showingTimerField: Bool = false
    @State var opacity: Double = 0.2

    @ObservedObject var devices: AVViewModel
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject var settings: AVSettingViewModel
    @ObservedObject var cameras: IPCameraViewModel

    @StateObject private var timer: TimerModel

    init(devices: AVViewModel, viewModel: MainViewModel, settings: AVSettingViewModel, cameras: IPCameraViewModel) {
        _timer = StateObject(wrappedValue: TimerModel())
        self.devices = devices
        self.viewModel = viewModel
        self.settings = settings
        self.cameras = cameras
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
            IconButton(icon: "gear", color: Color.white) {
                InspectorWindowManager.shared.showInspector(with: InspectorView(devices: devices, viewModel: viewModel, settings: settings, cameras: cameras))
            }
            .padding(.leading, 20)
            .padding(.trailing, 10)
            if showingTimerField {
                TimerTextField(hr: timer.hrBinding, min: timer.minBinding, sec: timer.secBinding)
                    .disabled(timer.isRecording)
            }
            IconButton(icon: "clock.fill", color: Color.white) {
                showingTimerField.toggle()
            }
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .background(Color.gray)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .opacity(opacity)
        .onChange(of: timer.isRecording) { _, newValue in
            if newValue {
                viewModel.startAVRecording(devices: devices, settings: settings)
            } else {
                viewModel.stopAVRecording()
            }
        }
        .onAppear {
            if viewModel.avTimer !== timer {
                viewModel.avTimer = timer
            }
        }
        .onDisappear {
            timer.stop()
        }
        .onHover { hover in
            if hover {
                opacity = 1.0
            } else {
                opacity = 0.2
            }
        }
    }
}
