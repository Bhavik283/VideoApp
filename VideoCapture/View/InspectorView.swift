//
//  InspectorView.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 15/05/25.
//

import SwiftUI

struct InspectorView: View {
    @StateObject var settings: AVSettingViewModel
    @StateObject var cameras: IPCameraViewModel
    
    init() {
        self._settings = StateObject(wrappedValue: AVSettingViewModel())
        self._cameras = StateObject(wrappedValue: IPCameraViewModel())
    }

    var body: some View {
        VStack {
            TabView {
                SourcesView()
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
        .navigationTitle("Inspector")
    }
}
