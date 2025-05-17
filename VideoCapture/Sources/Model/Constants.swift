//
//  Constants.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 15/05/25.
//

let HD720 = AVSettings(
    name: "HD720",
    video: VideoSettings(
        codec: .h264,
        frameSize: FrameSize._1280x720HD.rawValue,
        scalingMode: nil,
        bitRate: "5000",
        keyFrameInterval: "25",
        profile: nil
    ),
    audio: AudioSettings(
        codec: .mpeg_4HighEfficiencyAAC,
        sampleRate: .khz48000,
        bitRate: .kbs128,
        bitRateMode: .perChannel,
        channels: ._2,
        channelType: .default
    ),
    allChanges: false
)

let HD1080 = AVSettings(
    name: "HD1080",
    video: VideoSettings(
        codec: .h264,
        frameSize: FrameSize._1920x1080HD.rawValue,
        scalingMode: nil,
        bitRate: "8000",
        keyFrameInterval: "25",
        profile: nil
    ),
    audio: AudioSettings(
        codec: .mpeg_4HighEfficiencyAAC,
        sampleRate: .khz48000,
        bitRate: .kbs128,
        bitRateMode: .perChannel,
        channels: ._2,
        channelType: .default
    ),
    allChanges: false
)

let K4 = AVSettings(
    name: "4K",
    video: VideoSettings(
        codec: .h264,
        frameSize: "3840x2160",
        scalingMode: nil,
        bitRate: "35000",
        keyFrameInterval: "25",
        profile: nil
    ),
    audio: AudioSettings(
        codec: .mpeg_4HighEfficiencyAAC,
        sampleRate: .khz48000,
        bitRate: .kbs128,
        bitRateMode: .perChannel,
        channels: ._2,
        channelType: .default
    ),
    allChanges: false
)

let frameRates: [Int32] = Array(15 ... 60)
