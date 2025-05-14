//
//  AVEnums.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 13/05/25.
//

import AVFoundation
import Foundation

// MARK: - Video Enums

enum VideoCodec: String, Codable, CaseIterable {
    case h264 = "libx264"
    case proRes422
    case proRes4444
    case none = "copy"

    var displayName: String {
        switch self {
        case .h264: "H264"
        case .proRes422: "Apple Pro Res 422"
        case .proRes4444: "Apple Pro Res 4444"
        case .none: "No Compression"
        }
    }

    var value: String {
        switch self {
        case .h264, .none: rawValue
        case .proRes422, .proRes4444: "prores_ks"
        }
    }
}

enum FrameSize: String, Codable, CaseIterable {
    case camera
    case _160x120 = "160x120"
    case _176x144QCIF = "176x144"
    case _192x192 = "192x192"
    case _320x240QVGA = "320x240"
    case _352x288CIF = "352x288"
    case _480x480 = "480x480"
    case _640x480VGA = "640x480"
    case _768x576SD = "768x576"
    case _960x540 = "960x540"
    case _1280x720HD = "1280x720"
    case _1920x1080HD = "1920x1080"
    case NTSC720X480 = "720x480"
    case NTSC720x486 = "720x486"
    case PAL720x576 = "720x576"
    case HD1440x1080 = "1440x1080"
    case custom

    var displayName: String {
        switch self {
        case .camera: "Camera Dimensions"
        case ._160x120: "160 x 120"
        case ._176x144QCIF: "176 x 144 QCIF"
        case ._192x192: "192 x 192"
        case ._320x240QVGA: "320 x 240 QVGA"
        case ._352x288CIF: "352 x 288 CIF"
        case ._480x480: "480 x 480"
        case ._640x480VGA: "640 x 480 VGA"
        case ._768x576SD: "768 x 576 SD"
        case ._960x540: "960 x 540"
        case ._1280x720HD: "1280 x 720 HD"
        case ._1920x1080HD: "1920 x 1080 HD"
        case .NTSC720X480: "NTSC 720 x 480"
        case .NTSC720x486: "NTSC 720 x 486"
        case .PAL720x576: "PAL 720 x 576"
        case .HD1440x1080: "HD 1440 x 1080"
        case .custom: "Custom Dimensions"
        }
    }

    var value: String {
        switch self {
        case .camera, .custom: ""
        default: rawValue
        }
    }
}

enum VideoScalingMode: String, Codable, CaseIterable {
    case resize = "force"
    case resizeAspect = "pad"
    case resizeAspectFill = "crop"
    case none = ""

    var displayName: String {
        switch self {
        case .resize: "Scale to size. Lose Aspect Ratio"
        case .resizeAspect: "Keep Aspect Ratio. Add black bars"
        case .resizeAspectFill: "Keep Aspect Ratio. Crop picture"
        case .none: "No Value"
        }
    }
}

enum ProfileLevel: String, Codable, CaseIterable {
    case none = ""
    case baselineLevel3_0
    case baselineLevel3_1
    case baselineLevel4_1
    case mainProfileLevel3_0
    case mainProfileLevel3_1
    case mainProfileLevel3_2
    case mainProfileLevel4_1

    var displayName: String {
        switch self {
        case .none: return "No Value"
        case .baselineLevel3_0: return "Baseline Level 3.0"
        case .baselineLevel3_1: return "Baseline Level 3.1"
        case .baselineLevel4_1: return "Baseline Level 4.1"
        case .mainProfileLevel3_0: return "Main Profile Level 3.0"
        case .mainProfileLevel3_1: return "Main Profile Level 3.1"
        case .mainProfileLevel3_2: return "Main Profile Level 3.2"
        case .mainProfileLevel4_1: return "Main Profile Level 4.1"
        }
    }

    var value: String {
        switch self {
        case .none: rawValue
        case .baselineLevel3_0, .baselineLevel3_1, .baselineLevel4_1: "baseline"
        case .mainProfileLevel3_0, .mainProfileLevel3_1, .mainProfileLevel3_2, .mainProfileLevel4_1: "main"
        }
    }

    var levelValue: String {
        switch self {
        case .none: ""
        case .baselineLevel3_0, .mainProfileLevel3_0: "3.0"
        case .baselineLevel3_1, .mainProfileLevel3_1: "3.1"
        case .mainProfileLevel3_2: "3.2"
        case .baselineLevel4_1, .mainProfileLevel4_1: "4.1"
        }
    }
}

// MARK: - Audio Enums

enum AudioCodec: String, Codable, CaseIterable {
    case linearPCM = "pcm_s16le"
    case ima4_1adpcm = "adpcm_ima_qt"
    case mpeg_4LowComplexAAC = "aac"
    case uLaw2_1 = "pcm_mulaw"
    case aLaw2_1 = "pcm_alaw"
    case appleLossless = "alac"
    case mpeg_4HighEfficiencyAAC = "libfdk_aac"
    case mpeg_4AACLowDelay = "aac_ld"
    case mpeg_4AACEnchancedLowDelay = "aac_eld"
    case mpeg_4AACEnchancedLowDelayWithSBR = "aac_eld_sbr"
    case mpeg_4HighEfficiencyAACVersion2 = "he_aac_v2"
    case iLBCnarrowBandSpeech = "ilbc"

    var displayName: String {
        switch self {
        case .linearPCM: "Linear PCM"
        case .ima4_1adpcm: "IMA 4:1 ADPCM"
        case .mpeg_4LowComplexAAC: "MPEG-4 Low Complexity AAC"
        case .uLaw2_1: "uLaw 2:1"
        case .aLaw2_1: "aLaw 2:1"
        case .appleLossless: "Apple Lossless (ALAC)"
        case .mpeg_4HighEfficiencyAAC: "MPEG-4 High Efficiency AAC"
        case .mpeg_4AACLowDelay: "MPEG-4 AAC Low Delay"
        case .mpeg_4AACEnchancedLowDelay: "MPEG-4 Enhanced Low Delay AAC"
        case .mpeg_4AACEnchancedLowDelayWithSBR: "MPEG-4 ELD with SBR"
        case .mpeg_4HighEfficiencyAACVersion2: "High Efficiency AAC v2"
        case .iLBCnarrowBandSpeech: "iLBC Narrow Band Speech"
        }
    }
}

enum AudioBitrate: String, Codable, CaseIterable {
    case kbs10 = "10k"
    case kbs12 = "12k"
    case kbs16 = "16k"
    case kbs20 = "20k"
    case kbs24 = "24k"
    case kbs28 = "28k"
    case kbs32 = "32k"
    case kbs40 = "40k"
    case kbs48 = "48k"
    case kbs56 = "56k"
    case kbs64 = "64k"
    case kbs80 = "80k"
    case kbs96 = "96k"
    case kbs112 = "112k"
    case kbs128 = "128k"
    case kbs160 = "160k"
    case kbs192 = "192k"
    case kbs224 = "224k"
    case kbs256 = "256k"
    case kbs320 = "320k"
    case kbs448 = "448k"
    case kbs640 = "640k"
    case kbs1120 = "1120k"

    var displayName: String {
        switch self {
        case .kbs10: "10.000 kbits/sec"
        case .kbs12: "12.000 kbits/sec"
        case .kbs16: "16.000 kbits/sec"
        case .kbs20: "20.000 kbits/sec"
        case .kbs24: "24.000 kbits/sec"
        case .kbs28: "28.000 kbits/sec"
        case .kbs32: "32.000 kbits/sec"
        case .kbs40: "40.000 kbits/sec"
        case .kbs48: "48.000 kbits/sec"
        case .kbs56: "56.000 kbits/sec"
        case .kbs64: "64.000 kbits/sec"
        case .kbs80: "80.000 kbits/sec"
        case .kbs96: "96.000 kbits/sec"
        case .kbs112: "112.000 kbits/sec"
        case .kbs128: "128.000 kbits/sec"
        case .kbs160: "160.000 kbits/sec"
        case .kbs192: "192.000 kbits/sec"
        case .kbs224: "224.000 kbits/sec"
        case .kbs256: "256.000 kbits/sec"
        case .kbs320: "320.000 kbits/sec"
        case .kbs448: "448.000 kbits/sec"
        case .kbs640: "640.000 kbits/sec"
        case .kbs1120: "1120.000 kbits/sec"
        }
    }
}

enum SampleRate: String, Codable, CaseIterable {
    case khz16000 = "16000"
    case khz22050 = "22050"
    case khz24000 = "24000"
    case khz32000 = "32000"
    case khz44100 = "44100"
    case khz48000 = "48000"
    case khz88200 = "88200"
    case khz96000 = "96000"

    var displayName: String {
        switch self {
        case .khz16000: "16,000 kHz"
        case .khz22050: "22,050 kHz"
        case .khz24000: "24,000 kHz"
        case .khz32000: "32,000 kHz"
        case .khz44100: "44,100 kHz"
        case .khz48000: "48,000 kHz"
        case .khz88200: "88,200 kHz"
        case .khz96000: "96,000 kHz"
        }
    }
}

enum BiteRateMode: String, Codable, CaseIterable {
    case perChannel = "per_channel"
    case allChannels = "all_channels"

    var displayName: String {
        switch self {
        case .perChannel: "Per Channel"
        case .allChannels: "All Channels"
        }
    }
}

enum ChannelCount: String, Codable, CaseIterable {
    case _1 = "1"
    case _2 = "2"
    case _4 = "4"
    case _6 = "6"
    case _8 = "8"

    var displayName: String {
        switch self {
        case ._1: "1 channel"
        case ._2: "2 channels"
        case ._4: "4 channels"
        case ._6: "6 channels"
        case ._8: "8 channels"
        }
    }
}

enum ChannelType: String, Codable, CaseIterable {
    case `default` = ""
    case stereoLR = "stereo"

    var displayName: String {
        switch self {
        case .default: "Default"
        case .stereoLR: "Stereo (LR)"
        }
    }
}
