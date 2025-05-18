//
//  ContentView.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 13/05/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var devices: AVViewModel
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject var settings: AVSettingViewModel
    @ObservedObject var cameras: IPCameraViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            VideoPreview(viewModel: viewModel)
            ControlPanelView(
                devices: devices,
                viewModel: viewModel,
                settings: settings,
                cameras: cameras
            )
            .padding(.bottom, 100)
        }
        .navigationTitle("Capture")
    }
}
