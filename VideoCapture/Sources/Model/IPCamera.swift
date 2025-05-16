//
//  IPCamera.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 14/05/25.
//

import Foundation

struct IPCamera: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var url: String
    var username: String
    var password: String
    var rtp: RTP
    var sdpFile: String?
    var deinterfaceFeed: Bool

    init(name: String, url: String = "", username: String = "", password: String = "", rtp: RTP = .rtp, sdpFile: String? = nil, deinterfaceFeed: Bool = false) {
        self.name = name
        self.url = url
        self.username = username
        self.password = password
        self.rtp = rtp
        self.sdpFile = sdpFile
        self.deinterfaceFeed = deinterfaceFeed
    }
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
