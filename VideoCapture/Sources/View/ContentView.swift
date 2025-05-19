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

    @State private var dragOffset: CGSize = .zero
    @State private var contentOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                VideoPreview(viewModel: viewModel)

                ControlPanelView(
                    devices: devices,
                    viewModel: viewModel,
                    settings: settings,
                    cameras: cameras
                )
                .offset(contentOffset)
                .padding(.bottom, 100)
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            let newOffset = CGSize(
                                width: dragOffset.width + value.translation.width,
                                height: dragOffset.height + value.translation.height
                            )

                            // Calculate bounds
                            let viewWidth: CGFloat = 300

                            let minX: CGFloat = -geometry.size.width / 2 + viewWidth / 2
                            let maxX: CGFloat = geometry.size.width / 2 - viewWidth / 2
                            let minY: CGFloat = -geometry.size.height / 2 - 200
                            let maxY: CGFloat = 90

                            contentOffset = CGSize(
                                width: min(max(newOffset.width, minX), maxX),
                                height: min(max(newOffset.height, minY), maxY)
                            )
                        }
                        .onEnded { _ in
                            dragOffset = contentOffset
                        }
                )
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .navigationTitle("Capture")
    }
}
