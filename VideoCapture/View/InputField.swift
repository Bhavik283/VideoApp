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

    init(isFocused: Binding<Bool>, text: Binding<String>) {
        self._text = text
        self._isFocused = isFocused
    }

    var body: some View {
        TextField("", text: $text)
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
