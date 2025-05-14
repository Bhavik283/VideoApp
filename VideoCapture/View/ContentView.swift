//
//  ContentView.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 13/05/25.
//

import SwiftUI

struct ContentView: View {
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

#Preview {
    ContentView()
}
