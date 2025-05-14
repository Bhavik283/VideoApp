//
//  CompressionView.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 13/05/25.
//

import SwiftUI

struct CompressionView: View {
    @State var isShowingPresets: Bool = false
    @State var isShowingVideo: Bool = false
    @State var isShowingAudio: Bool = false

    // to be replace with view model class
    @State var videoCodec: VideoCodec = .h264
    @State var scaling: VideoScalingMode = .resize
    @State var frameSize: FrameSize = .camera
    @State var profile: ProfileLevel = .none

    @State var audioCodec: AudioCodec = .mpeg_4HighEfficiencyAAC
    @State var sampleRate: SampleRate = .khz48000
    @State var bitRateAudio: AudioBitrate = .kbs128
    @State var bitRateMode: BiteRateMode = .perChannel
    @State var channelCount: ChannelCount = ._2
    @State var channelType: ChannelType = .default

    var body: some View {
        VStack {
            CollapseButton(title: "Presets", isExpanded: $isShowingPresets)
            if isShowingPresets {
                EditableListView()
            }
            CollapseButton(title: "Video", isExpanded: $isShowingVideo)
            if isShowingVideo {
                VideoSettingView(videoCodec: $videoCodec, scaling: $scaling, frameSize: $frameSize, profile: $profile)
            }
            CollapseButton(title: "Audio", isExpanded: $isShowingAudio)
            if isShowingAudio {
                AudioSettingView(audioCodec: $audioCodec, sampleRate: $sampleRate, bitRateAudio: $bitRateAudio, bitRateMode: $bitRateMode, channelCount: $channelCount, channelType: $channelType)
            }
            Spacer()
        }
    }
}

struct VideoSettingView: View {
    @Binding var videoCodec: VideoCodec
    @Binding var scaling: VideoScalingMode
    @Binding var frameSize: FrameSize
    @Binding var profile: ProfileLevel

    var body: some View {
        VStack {
            LabelView(label: "Codec") {
                Picker("Codec", selection: $videoCodec) {
                    ForEach(VideoCodec.allCases, id: \.self) {
                        Text($0.displayName)
                    }
                }
            }
            LabelView(label: "Frame Size") {
                FrameSizeView(frameSize: $frameSize)
            }
            LabelView(label: "Scaling") {
                Picker("Scaling", selection: $scaling) {
                    ForEach(VideoScalingMode.allCases, id: \.self) {
                        Text($0.displayName)
                    }
                }
            }
            LabelView(label: "Bit Rate") {
                BitRateView()
            }
            LabelView(label: "Key Frames") {
                NumericInputField(title: "", text: .constant("25"))
            }
            LabelView(label: "Profile") {
                Picker("Profile", selection: $profile) {
                    ForEach(ProfileLevel.allCases, id: \.self) {
                        Text($0.displayName)
                    }
                }
            }
        }
    }
}

struct AudioSettingView: View {
    @Binding var audioCodec: AudioCodec
    @Binding var sampleRate: SampleRate
    @Binding var bitRateAudio: AudioBitrate
    @Binding var bitRateMode: BiteRateMode
    @Binding var channelCount: ChannelCount
    @Binding var channelType: ChannelType

    var body: some View {
        VStack {
            LabelView(label: "Codec") {
                Picker("Codec", selection: $audioCodec) {
                    ForEach(AudioCodec.allCases, id: \.self) {
                        Text($0.displayName)
                    }
                }
            }
            LabelView(label: "Sample Rate") {
                Picker("Sample Rate", selection: $sampleRate) {
                    ForEach(SampleRate.allCases, id: \.self) {
                        Text($0.displayName)
                    }
                }
            }
            LabelView(label: "Bit Rate") {
                AudioBitrateView(bitRateAudio: $bitRateAudio, bitRateMode: $bitRateMode)
            }
            LabelView(label: "Channels") {
                AudioChannelView(channelCount: $channelCount, channelType: $channelType)
            }
        }
    }
}

struct FrameSizeView: View {
    @State var width: String = ""
    @State var height: String = ""
    @Binding var frameSize: FrameSize

    var body: some View {
        VStack {
            HStack {
                NumericInputField(title: "", text: $width)
                Text("x")
                NumericInputField(title: "", text: $height)
            }
            Picker("Bit Rate", selection: $frameSize) {
                ForEach(FrameSize.allCases, id: \.self) {
                    Text($0.displayName)
                }
            }
        }
    }
}

struct BitRateView: View {
    var body: some View {
        HStack {
            NumericInputField(title: "", text: .constant("1000"))
                .multilineTextAlignment(.trailing)
            Text("kbps")
                .frame(width: 100, alignment: .leading)
        }
    }
}

struct AudioBitrateView: View {
    @Binding var bitRateAudio: AudioBitrate
    @Binding var bitRateMode: BiteRateMode

    var body: some View {
        HStack {
            Picker("Bit Rate", selection: $bitRateAudio) {
                ForEach(AudioBitrate.allCases, id: \.self) {
                    Text($0.displayName)
                }
            }
            Picker("Bit Rate Model", selection: $bitRateMode) {
                ForEach(BiteRateMode.allCases, id: \.self) {
                    Text($0.displayName)
                }
            }
        }
    }
}

struct AudioChannelView: View {
    @Binding var channelCount: ChannelCount
    @Binding var channelType: ChannelType

    var body: some View {
        HStack {
            Picker("Channel Count", selection: $channelCount) {
                ForEach(ChannelCount.allCases, id: \.self) {
                    Text($0.displayName)
                }
            }
            Picker("Channels Type", selection: $channelType) {
                ForEach(ChannelType.allCases, id: \.self) {
                    Text($0.displayName)
                }
            }
        }
    }
}
