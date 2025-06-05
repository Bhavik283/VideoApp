//
//  WindowManager.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 15/05/25.
//

import AppKit
import SwiftUI

class WindowManager {
    static let shared = WindowManager()
    private var windowInspector: NSWindow?
    private var windowControlList: NSWindow?

    func showInspector<Content: View>(with content: Content) {
        if windowInspector == nil {
            let hostingController = NSHostingController(rootView: content)
            let newWindow = NSWindow(contentViewController: hostingController)
            newWindow.title = "Inspector"
            newWindow.setContentSize(NSSize(width: 500, height: 600))
            newWindow.styleMask = [.titled, .closable, .resizable]
            newWindow.isReleasedWhenClosed = false
            newWindow.center()
            newWindow.makeKeyAndOrderFront(nil)
            windowInspector = newWindow
        } else {
            windowInspector?.makeKeyAndOrderFront(nil)
        }
    }

    func bringToFront(_ showController: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.windowInspector?.makeKeyAndOrderFront(nil)
            if showController {
                self?.windowControlList?.makeKeyAndOrderFront(nil)
            }
        }
    }

    func showController<Content: View>(with content: Content) {
        if windowControlList == nil {
            let hostingController = NSHostingController(rootView: content)
            let newWindow = NSWindow(contentViewController: hostingController)
            newWindow.title = "IP Camera Control Panel"
            newWindow.setContentSize(NSSize(width: 300, height: 600))
            newWindow.styleMask = [.titled, .closable, .resizable]
            newWindow.isReleasedWhenClosed = false
            newWindow.center()
            newWindow.makeKeyAndOrderFront(nil)
            windowControlList = newWindow
        } else {
            windowControlList?.makeKeyAndOrderFront(nil)
        }
    }
}
