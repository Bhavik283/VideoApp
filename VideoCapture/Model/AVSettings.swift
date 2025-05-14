//
//  AVSettings.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 13/05/25.
//

import Foundation

// MARK: - Video Parameters Model
struct VideoSettings: Codable {
    var codec: VideoCodec
    var frameSize: String?
    var scalingMode: VideoScalingMode?
    var bitRate: Int
    var keyFrameInterval: Int
    var profile: ProfileLevel?
}

// MARK: - Audio Parameters Model
struct AudioSettings: Codable {
    var codec: AudioCodec
    var sampleRate: SampleRate
    var bitRate: AudioBitrate
    var bitRateMode: BiteRateMode
    var channels: ChannelCount
    var channelType: ChannelType

    // Only applicable when codec is Linear PCM
    var isBigEndian: Bool?
    var isFloat: Bool?
}

struct AVSettings: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var video: VideoSettings
    var audio: AudioSettings
}
