//
//  ControlPanelView.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 15/05/25.
//

import SwiftUI

struct ControlPanelView: View {
    @State var time: String = "00:00:00"
    @State var isRecording: Bool = false

    var body: some View {
        HStack {
            Text(time)
                .padding(.trailing, 20)
            HStack {
                if isRecording {
                    Button {
                        isRecording.toggle()
                    } label: {
                        Image(systemName: "record.circle.fill")
                            .resizable()
                            .foregroundStyle(Color.red)
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.plain)
                } else {
                    Button {
                        isRecording.toggle()
                    } label: {
                        Image(systemName: "square.fill")
                            .resizable()
                            .foregroundStyle(Color.red)
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 10)
                    Button {
                        isRecording.toggle()
                    } label: {
                        Image(systemName: "pause.fill")
                            .resizable()
                            .foregroundStyle(Color.white)
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(width: 60)
            Button {
                InspectorWindowManager.shared.showInspector(with: InspectorView())
            } label: {
                Image(systemName: "gear")
                    .resizable()
                    .foregroundStyle(Color.white)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .padding(.leading, 20)
        }
        .padding(20)
        .background(Color.gray)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
