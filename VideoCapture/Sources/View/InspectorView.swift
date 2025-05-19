//
//  InspectorView.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 15/05/25.
//

import SwiftUI

struct InspectorView: View {
    @ObservedObject var devices: AVViewModel
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject var settings: AVSettingViewModel
    @ObservedObject var cameras: IPCameraViewModel

    var body: some View {
        VStack {
            TabView {
                SourcesView(devices: devices, viewModel: viewModel, settings: settings, cameras: cameras)
                    .tabItem {
                        Text("Sources")
                    }

                CompressionView(settings: settings)
                    .tabItem {
                        Text("Compression")
                    }

                FeedsView(cameras: cameras)
                    .tabItem {
                        Text("Feeds")
                    }
            }
            .tabViewStyle(.grouped)
            .padding(.top, 5)
        }
        .toolbar {
            ToolbarItem {
                Button("", systemImage: "list.bullet.rectangle") {
                    WindowManager.shared.showController(with: ControlPanelList(devices: devices, viewModel: viewModel, settings: settings, cameras: cameras))
                }
            }
        }
        .navigationTitle("Inspector")
    }
}
