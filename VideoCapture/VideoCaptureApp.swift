//
//  VideoCaptureApp.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 13/05/25.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var mainWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Nothing needed here unless you want to customize early
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    @objc func showMainWindow() {
        if let window = mainWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    @objc func closeMainWindow() {
        mainWindow?.performClose(nil)
    }

    @objc func resizeWindow(_ size: NSSize) {
        updateSize(window: mainWindow, size: size)
        mainWindow?.aspectRatio = size
    }
    
    func updateSize(window: NSWindow?, size: NSSize) {
        guard let currentSize = window?.frame.size else { return }
        let targetRatio = CGFloat(size.width) / CGFloat(size.height)
        var newSize = currentSize
        newSize.height = currentSize.width / targetRatio

        window?.setContentSize(newSize)
    }
}

@main
struct VideoCaptureApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    @StateObject var devices: AVViewModel
    @StateObject var viewModel: MainViewModel
    @StateObject var settings: AVSettingViewModel
    @StateObject var cameras: IPCameraViewModel

    init() {
        let deviceVM = AVViewModel()
        let settingVM = AVSettingViewModel()
        _devices = StateObject(wrappedValue: deviceVM)
        _settings = StateObject(wrappedValue: settingVM)
        _cameras = StateObject(wrappedValue: IPCameraViewModel())
        _viewModel = StateObject(wrappedValue: MainViewModel(activeCamera: deviceVM.videoDevices.first, activeMicrophone: deviceVM.audioDevices.first, selectedSettingsID: settingVM.AVSettingData.first?.id))
    }

    var body: some Scene {
        WindowGroup(id: "Main_Window_For_App") {
            ZStack {
                WindowAccessor { window in
                    if let window, appDelegate.mainWindow == nil {
                        appDelegate.mainWindow = window
                        window.title = "Camera Video Preview"
                        let size = NSSize(width: 1280, height: 720)
                        appDelegate.updateSize(window: window, size: size)
                        window.aspectRatio = size
                    }
                }
                ContentView(devices: devices, viewModel: viewModel, settings: settings, cameras: cameras)
            }
            .onAppear {
                viewModel.openWindow = appDelegate.showMainWindow
                viewModel.closeWindow = appDelegate.closeMainWindow
                viewModel.resizeWindow = appDelegate.resizeWindow
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                viewModel.stopAllRecordingsForBackground()
            }
        }
        .commands {
            CommandGroup(after: .windowArrangement) {
                Button("Open Preview Window") {
                    NSApp.sendAction(#selector(appDelegate.showMainWindow), to: nil, from: nil)
                }
                .keyboardShortcut("1", modifiers: [.command])
            }
        }
    }
}

struct WindowAccessor: NSViewRepresentable {
    let callback: (NSWindow?) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.callback(view.window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
