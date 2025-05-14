//
//  AVSettings.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 13/05/25.
//


import Foundation
import AVFoundation

// MARK: - Video Parameters Model
struct VideoSettings: Codable {
    var codec: VideoCodec // Use AVVideoCodecType
    var frameSize: CGSize
    var scalingMode: VideoScalingMode // Use AVLayerVideoGravity for scaling
    var bitRate: Int
    var keyFrameInterval: Int // Interval between key frames
    var profile: String? // e.g., "HEVC Main Profile"
}

// MARK: - Audio Parameters Model
struct AudioSettings: Codable {
    var codec: AudioCodec // e.g. kAudioFormatMPEG4AAC, kAudioFormatLinearPCM
    var sampleRate: Double   // Hz (e.g., 44100.0)
    var bitRate: Int         // bits per second
    var channels: Int        // e.g., 1 for mono, 2 for stereo

    // Only applicable when codec is Linear PCM
    var isBigEndian: Bool?
    var isFloat: Bool?
    var isNonInterleaved: Bool?
}

struct AVSettings: Codable {
    let name: String
    let video: VideoSettings
    let audio: AudioSettings
}
