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
    @State var rtpSelection: String = "UDP"
    
    let rpts: [String] = ["UDP", "TCP"]

    var body: some View {
        VStack {
            CollapseButton(title: "Feed List", isExpanded: $isShowingList)
            if isShowingList {
                EditableListView()
            }
            CollapseButton(title: "Feed", isExpanded: $isShowingFeed)
            if isShowingFeed {
                Form {
                    TextField("Feed Address", text: .constant(""))
                        .textFieldStyle(.roundedBorder)
                    TextField("Username", text: .constant(""))
                        .textFieldStyle(.roundedBorder)
                    SecureField("Password", text: .constant(""))
                        .textFieldStyle(.roundedBorder)
                    Picker("RTP", selection: $rtpSelection) {
                        ForEach(rpts, id: \.self) {
                            Text($0)
                        }
                    }
                }
                .padding()
            }
            Spacer()
        }
    }
}
