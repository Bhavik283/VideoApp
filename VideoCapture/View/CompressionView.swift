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

    @State var videoCodec: VideoCodec = .h264
    @State var audioCodec: AudioCodec = .aac
    @State var scaling: VideoScalingMode = .resize

    var body: some View {
        VStack {
            CollapseButton(title: "Presets", isExpanded: $isShowingPresets)
            if isShowingPresets {
                EditableListView()
            }
            CollapseButton(title: "Video", isExpanded: $isShowingVideo)
            if isShowingVideo {
                VideoSettingView(videoCodec: $videoCodec, scaling: $scaling)
            }
            CollapseButton(title: "Audio", isExpanded: $isShowingAudio)
            if isShowingAudio {
                AudioSettingView(audioCodec: $audioCodec)
            }
            Spacer()
        }
    }
}

struct VideoSettingView: View {
    @Binding var videoCodec: VideoCodec
    @Binding var scaling: VideoScalingMode
    
    var body: some View {
        VStack {
            LabelView(label: "Codec") {
                Picker("Codec", selection: $videoCodec) {
                    ForEach(VideoCodec.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
            }
            LabelView(label: "Frame Size") {
                FrameSizeView()
            }
            LabelView(label: "Scaling") {
                Picker("Scaling", selection: $scaling) {
                    ForEach(VideoScalingMode.allCases, id: \.self) {
                        Text($0.rawValue)
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
                TextField("", text: .constant("25"))
                    .textFieldStyle(.roundedBorder)
            }
        }
    }
}

struct AudioSettingView: View {
    @Binding var audioCodec: AudioCodec
    
    var body: some View {
        VStack {
            LabelView(label: "Codec") {
                Picker("Codec", selection: $audioCodec) {
                    ForEach(AudioCodec.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
            }
            LabelView(label: "Sample Rate") {
                NumericInputField(title: "", text: .constant(""))
            }
            LabelView(label: "Bit Rate") {
                BitRateView()
            }
            LabelView(label: "Channels") {
                NumericInputField(title: "", text: .constant("2"))
            }
        }
    }
}

struct FrameSizeView: View {
    @State var width: String = ""
    @State var height: String = ""

    var body: some View {
        HStack {
            NumericInputField(title: "", text: $width)
            Text("x")
            NumericInputField(title: "", text: $height)
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
