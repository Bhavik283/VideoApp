//
//  ContentView.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 13/05/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black
                .frame(width: 600, height: 500)
            ControlPanelView()
                .padding(.bottom, 100)
        }
        .navigationTitle("Capture")
    }
}

#Preview {
    ContentView()
}
