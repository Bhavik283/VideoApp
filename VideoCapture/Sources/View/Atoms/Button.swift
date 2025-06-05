//
//  Button.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 13/05/25.
//

import SwiftUI

struct AddRemoveButton: View {
    @Binding var selectedIndex: Int?
    @Binding var editingIndex: Int?
    var onAdd: () -> Void
    var onRemove: () -> Void

    var body: some View {
        HStack {
            BorderedButton(icon: "plus") {
                onAdd()
            }

            BorderedButton(icon: "minus") {
                onRemove()
            }
            Spacer()
        }
    }
}

struct BorderedButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .frame(width: 20, height: 20)
        }
        .buttonStyle(.borderless)
        .foregroundStyle(.primary)
        .overlay(Rectangle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
    }
}

struct CollapseButton: View {
    let title: String
    @Binding var isExpanded: Bool

    var body: some View {
        Button {
            withAnimation {
                isExpanded.toggle()
            }
        } label: {
            HStack {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.white)
                    .padding(.leading, 10)
                Text(title)
                    .foregroundStyle(Color.white)
                Spacer()
            }
            .background(Color.gray.opacity(0.75))
        }
        .buttonStyle(.plain)
    }
}

struct IconButton: View {
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: icon)
                .resizable()
                .foregroundStyle(color)
                .frame(width: 20, height: 20)
        }
        .buttonStyle(.plain)
    }
}

struct StatusButton: View {
    @Binding var status: Bool?
    let action: () -> Void

    var body: some View {
        Button {
            status = nil
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(colorForCameraStatus(status))
                    .frame(width: 15, height: 15)
            }
        }
        .buttonStyle(.plain)
    }

    func colorForCameraStatus(_ status: Bool?) -> Color {
        switch status {
        case true: .green
        case false: .red
        default: .gray
        }
    }
}
