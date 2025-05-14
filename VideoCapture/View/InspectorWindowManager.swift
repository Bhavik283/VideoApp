//
//  InspectorWindowManager.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 15/05/25.
//

import SwiftUI
import AppKit

class InspectorWindowManager {
    static let shared = InspectorWindowManager()
    private var window: NSWindow?

    func showInspector<Content: View>(with content: Content) {
        if window == nil {
            let hostingController = NSHostingController(rootView: content)
            let newWindow = NSWindow(contentViewController: hostingController)
            newWindow.title = "Inspector"
            newWindow.setContentSize(NSSize(width: 500, height: 600))
            newWindow.styleMask = [.titled, .closable, .resizable]
            newWindow.isReleasedWhenClosed = false
            newWindow.center()
            newWindow.makeKeyAndOrderFront(nil)
            self.window = newWindow
        } else {
            window?.makeKeyAndOrderFront(nil)
        }
    }
}
