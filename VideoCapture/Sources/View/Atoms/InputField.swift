//
//  InputField.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 13/05/25.
//

import SwiftUI

struct InputField: View {
    @Binding var isFocused: Bool
    @Binding var text: String
    @FocusState private var internalFocus: Bool
    var onCommit: (() -> Void)?

    init(isFocused: Binding<Bool>, text: Binding<String>) {
        self._text = text
        self._isFocused = isFocused
    }

    var body: some View {
        TextField("", text: $text, onEditingChanged: { edit in
            if !edit {
                onCommit?()
            }
        })
        .focused($internalFocus)
        .textFieldStyle(.plain)
        .onAppear {
            internalFocus = isFocused
        }
        .onChange(of: internalFocus) { _, newValue in
            isFocused = newValue
        }
    }
}

struct NumericInputField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        TextField(title, text: $text)
            .onChange(of: text) { _, newValue in
                let filtered = newValue.filter(\.isWholeNumber)
                if filtered != newValue {
                    text = filtered
                }
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .labelsHidden()
    }
}

struct TimerTextField: View {
    @Binding var hr: String
    @Binding var min: String
    @Binding var sec: String

    var body: some View {
        HStack(spacing: 2) {
            TimeTextField(title: "HH", text: $hr)
                .frame(width: 45)
            Text(":")
            TimeTextField(title: "MM", text: $min)
                .frame(width: 45)
            Text(":")
            TimeTextField(title: "SS", text: $sec)
                .frame(width: 45)
        }
    }
}

struct TimeTextField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        TextField(title, text: $text)
            .onChange(of: text) { _, newValue in
                let filtered = newValue.filter { $0.isWholeNumber }

                if filtered.count > 2 {
                    text = String(filtered.prefix(2))
                } else if filtered != newValue {
                    text = filtered
                }
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .multilineTextAlignment(.center)
            .labelsHidden()
    }
}
