//
//  IPCamera.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 14/05/25.
//

import Foundation

struct IPCamera: Codable {
    let url: String
    let username: String
    let password: String
    let rtp: RTP
    let sdpFile: String?
    let deinterfaceFeed: Bool
}

enum RTP: String, Codable, CaseIterable {
    case rtp
    case mpegOverRtp = "mpegts_rtp"
    case mpegOverUdp = "mpegts_udp"

    var displayName: String {
        switch self {
        case .rtp: "RTP"
        case .mpegOverRtp: "MPEG TS over RTP"
        case .mpegOverUdp: "MPEG TS over UDP"
        }
    }
}
