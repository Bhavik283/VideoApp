//
//  CustomView.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 13/05/25.
//

import SwiftUI

struct LabelView<T: View>: View {
    let label: String
    let content: () -> T

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .frame(width: 100, alignment: .trailing)
            content()
                .labelsHidden()
        }
        .padding(.horizontal)
        .padding(.vertical, 0)
    }
}
