//
//  VideoCaptureApp.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 13/05/25.
//

import SwiftUI

@main
struct VideoCaptureApp: App {
    @ObservedObject var deviceViewModel: AVViewModel
    
    init() {
        self.deviceViewModel = AVViewModel()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
