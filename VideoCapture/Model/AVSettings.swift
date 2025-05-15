//
//  AVSettings.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 13/05/25.
//

import Foundation

// MARK: - Video Parameters Model

struct VideoSettings: Codable, Hashable {
    var codec: VideoCodec
    var frameSize: String?
    var scalingMode: VideoScalingMode?
    var bitRate: String
    var keyFrameInterval: String
    var profile: ProfileLevel?

    init(codec: VideoCodec = .h264, frameSize: String? = nil, scalingMode: VideoScalingMode? = nil, bitRate: String = "9000", keyFrameInterval: String = "25", profile: ProfileLevel? = nil) {
        self.codec = codec
        self.frameSize = frameSize
        self.scalingMode = scalingMode
        self.bitRate = bitRate
        self.keyFrameInterval = keyFrameInterval
        self.profile = profile
    }
}

// MARK: - Audio Parameters Model

struct AudioSettings: Codable, Hashable {
    var codec: AudioCodec
    var sampleRate: SampleRate
    var bitRate: AudioBitrate
    var bitRateMode: BiteRateMode
    var channels: ChannelCount
    var channelType: ChannelType

    // Only applicable when codec is Linear PCM
    var isBigEndian: Bool?
    var isFloat: Bool?

    init(codec: AudioCodec = .mpeg_4HighEfficiencyAAC, sampleRate: SampleRate = .khz48000, bitRate: AudioBitrate = .kbs128, bitRateMode: BiteRateMode = .perChannel, channels: ChannelCount = ._2, channelType: ChannelType = .default, isBigEndian: Bool? = nil, isFloat: Bool? = nil) {
        self.codec = codec
        self.sampleRate = sampleRate
        self.bitRate = bitRate
        self.bitRateMode = bitRateMode
        self.channels = channels
        self.channelType = channelType
        self.isBigEndian = isBigEndian
        self.isFloat = isFloat
    }
}

struct AVSettings: Codable, Identifiable, Hashable {
    var id: UUID = .init()
    var name: String
    var video: VideoSettings
    var audio: AudioSettings
    var allChanges: Bool

    init(name: String, video: VideoSettings = VideoSettings(), audio: AudioSettings = AudioSettings(), allChanges: Bool = true) {
        self.name = name
        self.video = video
        self.audio = audio
        self.allChanges = allChanges
    }
}
