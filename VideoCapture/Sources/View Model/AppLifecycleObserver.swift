//
//  AppLifecycleObserver.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 18/05/25.
//

import AppKit

class AppLifecycleObserver {
    var onWillSleep: (() -> Void)?
    var onDidWake: (() -> Void)?
    var onAppTerminate: (() -> Void)?

    init() {
        let center = NSWorkspace.shared.notificationCenter
        center.addObserver(self, selector: #selector(handleSleep), name: NSWorkspace.willSleepNotification, object: nil)
        center.addObserver(self, selector: #selector(handleWake), name: NSWorkspace.didWakeNotification, object: nil)
        center.addObserver(self, selector: #selector(handleTerminate), name: NSApplication.willTerminateNotification, object: nil)
    }

    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    @objc private func handleSleep() {
        onWillSleep?()
    }

    @objc private func handleWake() {
        onDidWake?()
    }

    @objc private func handleTerminate() {
        onAppTerminate?()
    }
}
