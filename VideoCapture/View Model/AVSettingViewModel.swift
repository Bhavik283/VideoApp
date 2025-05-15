//
//  AVSettingViewModel.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 15/05/25.
//

import SwiftUI

class AVSettingViewModel: ObservableObject {
    @Published var activeAVSetting: AVSettings? {
        didSet {
            syncStateWithActiveSetting()
        }
    }

    @Published var AVSettingData: [AVSettings] = [] {
        didSet {
            StorageViewModel.shared.saveAVSettings(AVSettingData)
        }
    }

    private var isSyncing: Bool = false

    // Video
    @Published var videoCodec: VideoCodec = .h264 { didSet { if !isSyncing { updateActiveVideo() } } }
    @Published var frameSize1: String = "" { didSet { if !isSyncing { updateActiveVideo() } } }
    @Published var frameSize2: String = "" { didSet { if !isSyncing { updateActiveVideo() } } }
    @Published var frameSize: FrameSize = .camera { didSet { if !isSyncing { updateActiveVideo() } } }
    @Published var scalingMode: VideoScalingMode = .none { didSet { if !isSyncing { updateActiveVideo() } } }
    @Published var videoBitRate: String = "3000" { didSet { if !isSyncing { updateActiveVideo() } } }
    @Published var keyFrameInterval: String = "2" { didSet { if !isSyncing { updateActiveVideo() } } }
    @Published var profile: ProfileLevel = .none { didSet { if !isSyncing { updateActiveVideo() } } }

    // Audio
    @Published var audioCodec: AudioCodec = .mpeg_4HighEfficiencyAAC { didSet { if !isSyncing { updateActiveAudio() } } }
    @Published var sampleRate: SampleRate = .khz48000 { didSet { if !isSyncing { updateActiveAudio() } } }
    @Published var bitRate: AudioBitrate = .kbs128 { didSet { if !isSyncing { updateActiveAudio() } } }
    @Published var bitRateMode: BiteRateMode = .perChannel { didSet { if !isSyncing { updateActiveAudio() } } }
    @Published var channels: ChannelCount = ._2 { didSet { if !isSyncing { updateActiveAudio() } } }
    @Published var channelType: ChannelType = .default { didSet { if !isSyncing { updateActiveAudio() } } }
    @Published var isBigEndian: Bool? = nil { didSet { if !isSyncing { updateActiveAudio() } } }
    @Published var isFloat: Bool? = nil { didSet { if !isSyncing { updateActiveAudio() } } }

    init() {
        let constantSettings = [HD720, HD1080, K4]
        let loadedSettings = StorageViewModel.shared.loadAVSettings()
        AVSettingData = loadedSettings.isEmpty ? constantSettings : loadedSettings
    }

    // MARK: - Helpers

    private func syncStateWithActiveSetting() {
        guard let setting = activeAVSetting else { return }
        isSyncing = true

        // Video
        videoCodec = setting.video.codec
        scalingMode = setting.video.scalingMode ?? .none
        videoBitRate = setting.video.bitRate
        keyFrameInterval = setting.video.keyFrameInterval
        profile = setting.video.profile ?? .none
        if let fSize = FrameSize(rawValue: setting.video.frameSize ?? "") {
            frameSize = fSize
            frameSize1 = ""
            frameSize2 = ""
        } else if let sizes = setting.video.frameSize?.components(separatedBy: "x"), sizes.count == 2 {
            frameSize1 = sizes[0]
            frameSize2 = sizes[1]
            frameSize = .custom
        } else {
            frameSize = .camera
            frameSize1 = ""
            frameSize2 = ""
        }

        // Audio
        audioCodec = setting.audio.codec
        sampleRate = setting.audio.sampleRate
        bitRate = setting.audio.bitRate
        bitRateMode = setting.audio.bitRateMode
        channels = setting.audio.channels
        channelType = setting.audio.channelType
        isBigEndian = setting.audio.isBigEndian
        isFloat = setting.audio.isFloat

        isSyncing = false
    }

    private func getFrameSize() -> String? {
        if frameSize == .custom, let width = Int(frameSize1), let height = Int(frameSize2) {
            return "\(width)x\(height)"
        } else if frameSize != .camera {
            return frameSize.rawValue
        }
        return nil
    }

    private func updateActiveVideo() {
        guard !isSyncing, var setting = activeAVSetting else { return }
        setting.video = VideoSettings(
            codec: videoCodec,
            frameSize: getFrameSize(),
            scalingMode: scalingMode,
            bitRate: videoBitRate,
            keyFrameInterval: keyFrameInterval,
            profile: profile
        )
        if activeAVSetting != setting {
            activeAVSetting = setting
            if let index = AVSettingData.firstIndex(where: { $0.id == setting.id }) {
                AVSettingData[index] = setting
            }
        }
    }

    private func updateActiveAudio() {
        guard !isSyncing, var setting = activeAVSetting else { return }
        setting.audio = AudioSettings(
            codec: audioCodec,
            sampleRate: sampleRate,
            bitRate: bitRate,
            bitRateMode: bitRateMode,
            channels: channels,
            channelType: channelType,
            isBigEndian: audioCodec == .linearPCM ? isBigEndian : nil,
            isFloat: audioCodec == .linearPCM ? isFloat : nil
        )
        if activeAVSetting != setting {
            activeAVSetting = setting
            if let index = AVSettingData.firstIndex(where: { $0.id == setting.id }) {
                AVSettingData[index] = setting
            }
        }
    }

    // MARK: - Add/Remove Settings

    func createNewAVSettings() {
        if let active = activeAVSetting {
            var newSetting = active
            newSetting.id = UUID()
            newSetting.name = "\(active.name) copy"

            AVSettingData.append(newSetting)
            activeAVSetting = newSetting
        } else {
            let newSetting = AVSettings(name: "new item \(AVSettingData.count)")
            AVSettingData.append(newSetting)
            activeAVSetting = newSetting
        }
    }

    func removeSettings(at index: Int) {
        if index >= 3 && index < AVSettingData.count {
            AVSettingData.remove(at: index)

            if !AVSettingData.isEmpty {
                activeAVSetting = AVSettingData.first
            } else {
                activeAVSetting = nil
            }
        }
    }
    
    func setActiveValue(at index: Int?) {
        if index == nil {
            activeAVSetting = nil
        } else if let index, index >= 0 && index < AVSettingData.count {
            activeAVSetting = AVSettingData[index]
        }
    }

    func updateName(id: UUID, to newName: String) {
        guard let index = AVSettingData.firstIndex(where: { $0.id == id }) else { return }
        if index < 3 { return }

        var updated = AVSettingData[index]
        updated.name = newName
        AVSettingData[index] = updated

        if activeAVSetting?.id == updated.id {
            activeAVSetting = updated
        }
    }
}
