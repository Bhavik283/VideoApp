//
//  InspectorView.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 15/05/25.
//

import SwiftUI

struct InspectorView: View {
    var body: some View {
        VStack {
            TabView {
                SourcesView()
                    .tabItem {
                        Text("Sources")
                    }

                CompressionView()
                    .tabItem {
                        Text("Compression")
                    }

                FeedsView()
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
