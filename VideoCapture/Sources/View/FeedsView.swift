//
//  FeedsView.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 13/05/25.
//

import SwiftUI

struct FeedsView: View {
    @State var isShowingList: Bool = true
    @State var isShowingFeed: Bool = true

    @ObservedObject var cameras: IPCameraViewModel

    var body: some View {
        VStack {
            CollapseButton(title: "Feed List", isExpanded: $isShowingList)
            if isShowingList {
                EditableListView(
                    items: $cameras.cameraList,
                    constantCount: 0,
                    getName: { $0.name },
                    setName: { original, newName in
                        var copy = original
                        copy.name = newName
                        cameras.updateName(for: original.id, to: newName)
                        return copy
                    },
                    onAdd: {
                        cameras.addNewCamera()
                    },
                    onRemove: { index in
                        cameras.removeCamera(at: index)
                    },
                    onSelect: { index in
                        cameras.setActiveValue(at: index)
                    }
                )
            }
            CollapseButton(title: "Feed", isExpanded: $isShowingFeed)
            if isShowingFeed {
                LabelView(label: "Feed Address") {
                    TextField("Feed Address", text: $cameras.url)
                        .textFieldStyle(.roundedBorder)
                }
                LabelView(label: "Username") {
                    TextField("Username", text: $cameras.username)
                        .textFieldStyle(.roundedBorder)
                }
                LabelView(label: "Password") {
                    SecureField("Password", text: $cameras.password)
                        .textFieldStyle(.roundedBorder)
                }
                LabelView(label: "RTP") {
                    Picker("RTP", selection: $cameras.rtp) {
                        ForEach(RTP.allCases, id: \.self) {
                            Text($0.displayName)
                        }
                    }
                }
                LabelView(label: "SDP") {
                    SDPView(path: $cameras.sdpFile)
                }
                Toggle(isOn: $cameras.deinterfaceFeed) {
                    Text("DeInteraface Feed")
                }
            }
            Spacer()
        }
    }
}

struct SDPView: View {
    @Binding var path: String

    var body: some View {
        HStack {
            TextField("SDP", text: $path)
                .textFieldStyle(.roundedBorder)
            Button("Choose") {
                pickSDPFile { url in
                    path = url?.path ?? ""
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
