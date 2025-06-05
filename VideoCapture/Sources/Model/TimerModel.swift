//
//  TimerModel.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 17/05/25.
//

import Combine
import SwiftUI

class TimerModel: ObservableObject {
    @Published var timeText: String = "00:00:00"
    @Published var isRecording: Bool = false

    var hrValue: String = "00"
    var minValue: String = "00"
    var secValue: String = "00"
    var hasAudio: Bool = false

    private var cancellable: AnyCancellable?
    private var counterSeconds: Int = 0

    init() {
        updateTimeText()
    }

    // Start the timer (increment counter every second)
    func start() {
        if !isRecording {
            isRecording = true
        }
        cancellable?.cancel()
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.counterSeconds += 1
                self?.updateTimeText()
            }
    }

    func stop() {
        if isRecording {
            isRecording = false
        }
        cancellable?.cancel()
        cancellable = nil
    }

    func reset() {
        counterSeconds = 0
        updateTimeText()
    }

    private func updateTimeText() {
        let h = counterSeconds / 3600
        let m = (counterSeconds % 3600) / 60
        let s = counterSeconds % 60
        timeText = String(format: "%02d:%02d:%02d", h, m, s)
    }

    // MARK: - Bindings for hr/min/sec as String

    var hrBinding: Binding<String> {
        Binding<String>(
            get: { [weak self] in self?.hrValue ?? "00" },
            set: { [weak self] newValue in
                self?.hrValue = newValue
            }
        )
    }

    var minBinding: Binding<String> {
        Binding<String>(
            get: { [weak self] in self?.minValue ?? "00" },
            set: { [weak self] newValue in
                self?.minValue = newValue
            }
        )
    }

    var secBinding: Binding<String> {
        Binding<String>(
            get: { [weak self] in self?.secValue ?? "00" },
            set: { [weak self] newValue in
                self?.secValue = newValue
            }
        )
    }
}
