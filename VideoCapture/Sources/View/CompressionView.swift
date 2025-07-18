//
//  CompressionView.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 13/05/25.
//

import SwiftUI

struct CompressionView: View {
    @State var isShowingPresets: Bool = true
    @State var isShowingVideo: Bool = true
    @State var isShowingAudio: Bool = true

    @ObservedObject var settings: AVSettingViewModel

    var isDisabled: Bool {
        if let active = settings.activeAVSetting, let index = settings.AVSettingData.firstIndex(of: active) {
            return index < 3
        }
        return false
    }

    var body: some View {
        VStack {
            CollapseButton(title: "Presets", isExpanded: $isShowingPresets)
            if isShowingPresets {
                EditableListView(
                    items: $settings.AVSettingData,
                    constantCount: 3,
                    getName: { $0.name },
                    setName: { original, newName in
                        var copy = original
                        copy.name = newName
                        settings.updateName(id: original.id, to: newName)
                        return copy
                    },
                    onAdd: {
                        settings.createNewAVSettings()
                    },
                    onRemove: { index in
                        settings.removeSettings(at: index)
                    },
                    onSelect: { index in
                        settings.setActiveValue(at: index)
                    }
                )
            }
            CollapseButton(title: "Video", isExpanded: $isShowingVideo)
            let disabled = isDisabled
            if isShowingVideo {
                VideoSettingView(videoCodec: $settings.videoCodec, scaling: $settings.scalingMode, frameSize: $settings.frameSize, frameSize1: $settings.frameSize1, frameSize2: $settings.frameSize2, bitRate: $settings.videoBitRate, keyFrames: $settings.keyFrameInterval, profile: $settings.profile)
                    .disabled(disabled)
            }
            CollapseButton(title: "Audio", isExpanded: $isShowingAudio)
            if isShowingAudio {
                AudioSettingView(audioCodec: $settings.audioCodec, sampleRate: $settings.sampleRate, bitRateAudio: $settings.bitRate, bitRateMode: $settings.bitRateMode, channelCount: $settings.channels, channelType: $settings.channelType)
                    .disabled(disabled)
            }
            Spacer()
        }
        .onAppear {
            settings.activeAVSetting = settings.AVSettingData.first
        }
    }
}

struct VideoSettingView: View {
    @Binding var videoCodec: VideoCodec
    @Binding var scaling: VideoScalingMode
    @Binding var frameSize: FrameSize
    @Binding var frameSize1: String
    @Binding var frameSize2: String
    @Binding var bitRate: String
    @Binding var keyFrames: String
    @Binding var profile: ProfileLevel

    var body: some View {
        VStack(spacing: 5) {
            LabelView(label: "Codec") {
                Picker("Codec", selection: $videoCodec) {
                    ForEach(VideoCodec.allCases, id: \.self) {
                        Text($0.displayName)
                    }
                }
            }
            LabelView(label: "Frame Size") {
                FrameSizeView(width: $frameSize1, height: $frameSize2, frameSize: $frameSize)
            }
            LabelView(label: "Scaling") {
                Picker("Scaling", selection: $scaling) {
                    ForEach(VideoScalingMode.allCases, id: \.self) {
                        Text($0.displayName)
                    }
                }
            }
            LabelView(label: "Bit Rate") {
                BitRateView(bitRate: $bitRate)
            }
            LabelView(label: "Key Frames") {
                NumericInputField(title: "", text: $keyFrames)
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
        VStack(spacing: 5) {
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
    @Binding var width: String
    @Binding var height: String
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
    @Binding var bitRate: String

    var body: some View {
        HStack {
            NumericInputField(title: "", text: $bitRate)
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
