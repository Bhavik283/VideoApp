//
//  FeedsView.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 13/05/25.
//

import SwiftUI

struct FeedsView: View {
    @State var isShowingList: Bool = false
    @State var isShowingFeed: Bool = false

    @ObservedObject var cameras: IPCameraViewModel

    var body: some View {
        VStack {
            CollapseButton(title: "Feed List", isExpanded: $isShowingList)
            if isShowingList {
                EditableListView()
            }
            CollapseButton(title: "Feed", isExpanded: $isShowingFeed)
            if isShowingFeed {
                Form {
                    TextField("Feed Address", text: $cameras.url)
                        .textFieldStyle(.roundedBorder)
                    TextField("Username", text: $cameras.name)
                        .textFieldStyle(.roundedBorder)
                    SecureField("Password", text: $cameras.password)
                        .textFieldStyle(.roundedBorder)
                    Picker("RTP", selection: $cameras.rtp) {
                        ForEach(RTP.allCases, id: \.self) {
                            Text($0.displayName)
                        }
                    }
                }
                .padding()
            }
            Spacer()
        }
    }
}
