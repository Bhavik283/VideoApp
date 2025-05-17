//
//  Utils.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 17/05/25.
//

import Foundation
import AppKit
import UniformTypeIdentifiers

func pickSDPFile(completion: @escaping (URL?) -> Void) {
    let panel = NSOpenPanel()
    if let sdpType = UTType(filenameExtension: "sdp") {
        panel.allowedContentTypes = [sdpType]
    } else {
        panel.allowedFileTypes = ["sdp"]
    }
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = false
    panel.title = "Select an SDP File"

    panel.begin { result in
        completion(result == .OK ? panel.url : nil)
    }
}
