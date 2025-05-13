//
//  Enums.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 13/05/25.
//

import AVFoundation
import Foundation

// MARK: - Video Enums

enum VideoCodec: String, Codable, CaseIterable {
    case h264
    case hevc
    case jpeg
    case jpegXL
    case proRes422
    case proRes4444
    case appleProRes4444XQ
    case proRes422HQ
    case proRes422LT
    case proRes422Proxy
    case hevcWithAlpha

    var avCodec: AVVideoCodecType {
        switch self {
        case .h264: .h264
        case .hevc: .hevc
        case .jpeg: .jpeg
        case .jpegXL: .JPEGXL
        case .proRes422: .proRes422
        case .proRes4444: .proRes4444
        case .appleProRes4444XQ: .appleProRes4444XQ
        case .proRes422HQ: .proRes422HQ
        case .proRes422LT: .proRes422LT
        case .proRes422Proxy: .proRes422Proxy
        case .hevcWithAlpha: .hevcWithAlpha
        }
    }
}

enum VideoScalingMode: String, Codable, CaseIterable {
    case resize
    case resizeAspect
    case resizeAspectFill

    var avGravity: AVLayerVideoGravity {
        switch self {
        case .resize: .resize
        case .resizeAspect: .resizeAspect
        case .resizeAspectFill: .resizeAspectFill
        }
    }
}

// MARK: - Audio Enums

enum AudioCodec: String, Codable, CaseIterable {
    case aac
    case linearPCM

    var formatID: AudioFormatID {
        switch self {
        case .aac: return kAudioFormatMPEG4AAC
        case .linearPCM: return kAudioFormatLinearPCM
        }
    }
}
