//
//  ControlPanelView.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 15/05/25.
//

import SwiftUI

struct ControlPanelView: View {
    @State var isRecording: Bool = false
    @State var opacity: Double = 0.2
    @State var showingTimerField: Bool = false

    @ObservedObject var devices: AVViewModel
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject var settings: AVSettingViewModel
    @ObservedObject var cameras: IPCameraViewModel

    let id: UUID
    @StateObject private var timer: TimerModel

    init(id: UUID, devices: AVViewModel, viewModel: MainViewModel, settings: AVSettingViewModel, cameras: IPCameraViewModel) {
        self.id = id
        _timer = StateObject(wrappedValue: TimerModel())
        self.devices = devices
        self.viewModel = viewModel
        self.settings = settings
        self.cameras = cameras
    }

    var body: some View {
        HStack {
            Text(timer.timeText)
                .padding(.trailing, 20)
            HStack {
                IconButton(
                    icon: isRecording ? "square.fill" : "record.circle.fill",
                    color: Color.red,
                    action: {
                        isRecording.toggle()
                    }
                )
            }
            .frame(width: 40)
            IconButton(icon: "gear", color: Color.white) {
                InspectorWindowManager.shared.showInspector(with: InspectorView(devices: devices, viewModel: viewModel, settings: settings, cameras: cameras))
            }
            .padding(.leading, 20)
            if showingTimerField {
                TimerTextField(hr: timer.hrBinding, min: timer.minBinding, sec: timer.secBinding)
            }
            IconButton(icon: "clock.fill", color: Color.white) {
                showingTimerField.toggle()
            }
        }
        .padding(20)
        .background(Color.gray)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .opacity(opacity)
        .onChange(of: isRecording) { _, newValue in
            if newValue {
                viewModel.startAVRecording(devices: devices, id: id)
                timer.start()
            } else {
                viewModel.stopAVRecording()
                timer.stop()
            }
        }
        .onAppear {
            if viewModel.timers[id] == nil {
                viewModel.timers[id] = timer
            }
        }
        .onDisappear {
            viewModel.timers[id] = nil
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
