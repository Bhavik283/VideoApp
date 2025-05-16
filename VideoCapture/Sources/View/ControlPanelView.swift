//
//  ControlPanelView.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 15/05/25.
//

import SwiftUI

struct ControlPanelView: View {
    @State var time: String = "00:00:00"
    @State var isRecording: Bool = false

    @ObservedObject var devices: AVViewModel
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject var settings: AVSettingViewModel
    @ObservedObject var cameras: IPCameraViewModel

    var body: some View {
        HStack {
            Text(time)
                .padding(.trailing, 20)
            HStack {
                Button {
                    isRecording.toggle()
                } label: {
                    Image(systemName: isRecording ? "square.fill" : "record.circle.fill")
                        .resizable()
                        .foregroundStyle(Color.red)
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)
            }
            .frame(width: 60)
            Button {
                InspectorWindowManager.shared.showInspector(with: InspectorView(devices: devices, viewModel: viewModel, settings: settings, cameras: cameras))
            } label: {
                Image(systemName: "gear")
                    .resizable()
                    .foregroundStyle(Color.white)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .padding(.leading, 20)
        }
        .padding(20)
        .background(Color.gray)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .onChange(of: isRecording) { _, newValue in
            if newValue {
                viewModel.startAVRecording(devices: devices)
            } else {
                viewModel.stopAVRecording()
            }
        }
    }
}
