//
//  CameraDeviceManager.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 14/05/25.
//


import AVFoundation
import SwiftUI
import Combine

class CameraDeviceManager: ObservableObject {
    @Published var availableDevices: [AVCaptureDevice] = []
    @Published var session: AVCaptureSession?

    private var deviceDiscoverySession: AVCaptureDevice.DiscoverySession
    private var cancellables = Set<AnyCancellable>()

    init() {
        deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.external, .builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        updateDevices()

        NotificationCenter.default.publisher(for: AVCaptureDevice.wasConnectedNotification)
            .sink { [weak self] _ in self?.updateDevices() }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: AVCaptureDevice.wasDisconnectedNotification)
            .sink { [weak self] _ in self?.updateDevices() }
            .store(in: &cancellables)
    }

    private func updateDevices() {
        DispatchQueue.main.async {
            self.availableDevices = self.deviceDiscoverySession.devices
        }
    }

    func startSession(with device: AVCaptureDevice) {
        // Stop any existing session before starting a new one
        session?.stopRunning()
        session = AVCaptureSession()

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session?.canAddInput(input) == true {
                session?.addInput(input)

                let previewLayer = AVCaptureVideoPreviewLayer(session: session!)
                previewLayer.videoGravity = .resizeAspectFill

                // Assuming you have a view in the UI to show the video preview
                // (this is handled in `VideoCaptureView` later)
                session?.startRunning()
            }
        } catch {
            print("Error setting up camera session: \(error)")
        }
    }
}

//func configureRecording(with videoSettings: VideoSettings, audioSettings: AudioSettings, outputURL: URL) throws -> AVAssetWriter {
//    // Create asset writer
//    let assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
//    
//    // Configure video settings
//    var videoOutputSettings: [String: Any] = [
//        AVVideoCodecKey: videoSettings.codec.avCodec,
//        AVVideoWidthKey: videoSettings.frameSize.width,
//        AVVideoHeightKey: videoSettings.frameSize.height,
//        AVVideoCompressionPropertiesKey: [
//            AVVideoAverageBitRateKey: videoSettings.bitRate,
//            AVVideoMaxKeyFrameIntervalKey: videoSettings.keyFrameInterval
//        ]
//    ]
//    
//    // Add profile if specified
////    if let profile = videoSettings.profile {
////        (videoOutputSettings[AVVideoCompressionPropertiesKey] as? [String: Any])?[AVVideoProfileLevelKey] = profile
////    }
//    
//    // Create and add video input
//    let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoOutputSettings)
//    videoWriterInput.expectsMediaDataInRealTime = true
//    assetWriter.add(videoWriterInput)
//    
//    // Configure audio settings
//    var audioOutputSettings: [String: Any] = [
//        AVFormatIDKey: audioSettings.codec.formatID,
//        AVSampleRateKey: audioSettings.sampleRate,
//        AVNumberOfChannelsKey: audioSettings.channels,
//        AVEncoderBitRateKey: audioSettings.bitRate
//    ]
//    
//    // Add Linear PCM specific settings if applicable
//    if audioSettings.codec == .linearPCM {
//        if let isBigEndian = audioSettings.isBigEndian {
//            audioOutputSettings[AVLinearPCMIsBigEndianKey] = isBigEndian
//        }
//        if let isFloat = audioSettings.isFloat {
//            audioOutputSettings[AVLinearPCMIsFloatKey] = isFloat
//        }
//        if let isNonInterleaved = audioSettings.isNonInterleaved {
//            audioOutputSettings[AVLinearPCMIsNonInterleaved] = isNonInterleaved
//        }
//    }
//    
//    // Create and add audio input
//    let audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioOutputSettings)
//    audioWriterInput.expectsMediaDataInRealTime = true
//    assetWriter.add(audioWriterInput)
//    
//    return assetWriter
//}
//
//func configureIPCameraCapture(streamURL: URL, videoSettings: VideoSettings, audioSettings: AudioSettings) {
//    // Create asset for the IP camera stream
//    let asset = AVURLAsset(url: streamURL)
//    
//    // Wait for asset to be ready
//    asset.loadValuesAsynchronously(forKeys: ["tracks"]) {
//        var error: NSError? = nil
//        let status = asset.statusOfValue(forKey: "tracks", error: &error)
//        
//        guard status == .loaded else {
//            print("Failed to load tracks: \(error?.localizedDescription ?? "Unknown error")")
//            return
//        }
//        
//        // Setup recording if needed
//        do {
//            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("recording_\(Date().timeIntervalSince1970).mp4")
//            let assetWriter = try configureRecording(
//                with: videoSettings,
//                audioSettings: audioSettings,
//                outputURL: outputURL
//            )
//            
//            // Setup asset reader
//            let assetReader = try AVAssetReader(asset: asset)
//            
//            // Configure video reading
//            let videoTracks = asset.tracks(withMediaType: .video)
//            if let videoTrack = videoTracks.first {
//                let videoReaderOutput = AVAssetReaderTrackOutput(
//                    track: videoTrack,
//                    outputSettings: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
//                )
//                assetReader.add(videoReaderOutput)
//            }
//            
//            // Configure audio reading
//            let audioTracks = asset.tracks(withMediaType: .audio)
//            if let audioTrack = audioTracks.first {
//                let audioReaderOutput = AVAssetReaderTrackOutput(
//                    track: audioTrack,
//                    outputSettings: nil
//                )
//                assetReader.add(audioReaderOutput)
//            }
//            
//            // Start processing
//            assetReader.startReading()
//            assetWriter.startWriting()
//            assetWriter.startSession(atSourceTime: .zero)
//            
//            // Process frames (handled in separate function for brevity)
//            // processFrames(assetReader: assetReader, assetWriter: assetWriter)
//        } catch {
//            print("Failed to configure recording: \(error.localizedDescription)")
//        }
//    }
//}

class FFmpegViewModel: ObservableObject {
    @Published var isRunning: Bool = false
    @Published var output: String = ""
    @Published var errorMessage: String?
    @Published var progress: Double = 0 // Track progress, if available
    
    private var process: Process?
    private var cancellables: Set<AnyCancellable> = []
    
    // Function to run FFmpeg command
    func runFFmpegCommand(command: String) {
        // 1. Check if already running
        if isRunning {
            errorMessage = "FFmpeg is already running."
            return
        }
        
        isRunning = true
        output = "" // Clear previous output
        errorMessage = nil // Clear previous errors
        progress = 0 // Reset progress
        
        // 2. Create Process
        let process = Process()
        self.process = process // Store for cancellation
        process.executableURL = URL(fileURLWithPath: "/usr/local/bin/ffmpeg") // Use the correct path. VERY IMPORTANT
        
        // 3. Construct arguments.  Split the command string.
        let arguments = command.components(separatedBy: " ")
        process.arguments = arguments
        
        // 4. Create pipes for output and error
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        let errorPipe = Pipe()
        process.standardError = errorPipe
        
        // 5.  Use a dispatch group to wait for both output and error to finish
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        dispatchGroup.enter()
        
        // 6. Read output asynchronously
        outputPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            guard let self = self else { return }
            let data = handle.availableData
            if !data.isEmpty {
                if let newOutput = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.output += newOutput
                        self.parseProgress(from: newOutput) // Try to parse progress
                    }
                }
            }
        }
        
        // 7. Read error asynchronously
        errorPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            guard let self = self else { return }
            let data = handle.availableData
            if !data.isEmpty {
                if let newError = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.output += newError // Append errors to the output as well
                        self.errorMessage = self.errorMessage == nil ? newError : self.errorMessage! + "\n" + newError
                    }
                }
            }
        }
        
        // 8. Set completion handler
        process.terminationHandler = { [weak self] process in
            guard let self = self else { return }
            
            // Leave the dispatch groups
            dispatchGroup.leave() // Output finished
            dispatchGroup.leave() // Error finished
            
            DispatchQueue.main.async {
                self.isRunning = false
                if process.terminationStatus != 0 && self.errorMessage == nil {
                    self.errorMessage = "FFmpeg command failed with exit code \(process.terminationStatus)."
                }
                // close handles
                outputPipe.fileHandleForReading.closeFile()
                errorPipe.fileHandleForReading.closeFile()
            }
        }
        
        // 9. Start the process
        do {
            try process.run()
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to start FFmpeg: \(error.localizedDescription)"
                self.isRunning = false
            }
            return
        }
        
        // 10.  Wait for the process to finish using the dispatch group.
        dispatchGroup.notify(queue: .main) {
            // Completion handler.  isRunning is already set to false in terminationHandler.
            //  No need to do it here.
            if self.errorMessage != nil{
                print("FFMPEG ERROR: \(self.errorMessage!)")
            }
            print("FFMPEG process finished")
        }
    }
    
    // Function to stop FFmpeg
    func stopFFmpeg() {
        if isRunning, let process = process {
            process.terminate()
            isRunning = false
            output = ""
            errorMessage = nil
            self.process = nil
        }
    }
    
    // Parse progress from FFmpeg output (example, adjust as needed)
    private func parseProgress(from string: String) {
        // Example: "frame=  100 fps=24.5 q=2.3 size=    1234kB time=00:00:04.12 bitrate=2456.7kbits/s speed=1.01x"
        if let timeRange = string.range(of: "time=") {
            let timeString = String(string[timeRange.upperBound...])
            let components = timeString.components(separatedBy: " ")
            if let timeValueString = components.first,
               let time = parseTime(from: timeValueString) {
                //  Assume total duration is known or estimated.  Replace 10.0 with your actual duration.
                let duration = 10.0 // Example: 10 seconds.  You MUST get this from your video.
                progress = time / duration
            }
        }
    }
    
    // Helper function to parse time string (HH:MM:SS.ms)
    private func parseTime(from string: String) -> Double? {
        let components = string.components(separatedBy: ":")
        guard components.count == 3 else { return nil }
        
        let hours = Double(components[0]) ?? 0
        let minutes = Double(components[1]) ?? 0
        let secondsAndFraction = components[2].components(separatedBy: ".")
        let seconds = Double(secondsAndFraction[0]) ?? 0
        let fraction = Double("0." + secondsAndFraction[1]) ?? 0
        
        return (hours * 3600) + (minutes * 60) + seconds + fraction
    }
    
    deinit {
        // Ensure the process is terminated if the view model is deallocated
        stopFFmpeg()
    }
}

struct FFmpegView: View {
    @StateObject var ffmpegViewModel = FFmpegViewModel()
    @State private var command: String = "-i input.mp4 -c:v libx264 -preset slow -crf 22 output.mp4" // Example
    
    var body: some View {
        VStack {
            TextField("FFmpeg Command", text: $command)
                .padding()
            
            Button(ffmpegViewModel.isRunning ? "Stop FFmpeg" : "Run FFmpeg") {
                if ffmpegViewModel.isRunning {
                    ffmpegViewModel.stopFFmpeg()
                } else {
                    ffmpegViewModel.runFFmpegCommand(command: command)
                }
            }
            .padding()
            .buttonStyle(.borderedProminent)
            
            Text(ffmpegViewModel.output)
                .padding()
                .font(.system(size: 12, design: .monospaced))
                .background(Color.gray.opacity(0.1))
                .frame(height: 200, alignment: .top)
            
            if let errorMessage = ffmpegViewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            }
            
            ProgressView(value: ffmpegViewModel.progress) // Show progress
                .padding()
            
            Spacer()
        }
        .padding()
        .onDisappear {
            ffmpegViewModel.stopFFmpeg() // Stop when the view disappears
        }
    }
}
