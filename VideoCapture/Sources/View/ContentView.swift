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
    
    @State private var id = UUID()

    var body: some View {
        ZStack(alignment: .bottom) {
            VideoPreview(viewModel: viewModel)
            ControlPanelView(
                id: id,
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
