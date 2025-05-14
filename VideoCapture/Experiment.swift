//
//  Experiment.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 14/05/25.
//

import Foundation

func shell(command: String) -> String? {
    let commonBrewPaths = [
        "/opt/homebrew/bin", // Apple Silicon
        "/usr/local/bin" // Intel
    ]
    
    for brewPath in commonBrewPaths {
        let task = Process()
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        var environment = ProcessInfo.processInfo.environment
        let existingPath = environment["PATH"] ?? ""
        environment["PATH"] = "\(brewPath):\(existingPath)"
        task.environment = environment

        task.arguments = ["-c", command]
        task.launchPath = "/bin/zsh"
        task.standardInput = nil

        do {
            try task.run()
            task.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8), !output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return output
            }
        } catch {
            print("Shell error with PATH=\(brewPath): \(error)")
        }
    }

    return nil
}


// func startFFmpegCapture(outputPath: String, ffmpegPath: String) {
//    let process = Process()
//    process.executableURL = URL(fileURLWithPath: ffmpegPath)
//
//    // Input and output setup
//    process.arguments = [
//        "-f", "avfoundation",           // macOS AVFoundation input
//        "-framerate", "30",             // 30 FPS
//        "-video_size", "1280x720",      // HD Resolution
//        "-i", "0:0",                    // Default camera and mic
//        "-c:v", "libx264",              // Video codec
//        "-preset", "veryfast",          // Encoding speed/quality
//        "-c:a", "aac",                  // Audio codec
//        "-b:a", "128k",                 // Audio bitrate
//        outputPath                      // e.g. "/Users/you/Desktop/output.mp4"
//    ]
//
//    let pipe = Pipe()
//    process.standardError = pipe
//    process.standardOutput = pipe
//
//    do {
//        try process.run()
//        print("FFmpeg capture started.")
//    } catch {
//        print("Failed to start FFmpeg: \(error)")
//    }
// }
//
// func startRecordingWithPreview(outputPath: String, ffmpegPath: String = "/opt/homebrew/bin/ffmpeg", ffplayPath: String = "/opt/homebrew/bin/ffplay") {
//    let cameraInput = "0:" // Default AVFoundation device
//    let micInput = "1:"
//
//    // Build FFmpeg command for recording (macOS AVFoundation)
//    let ffmpegArgs = [
//        "-f", "avfoundation",
//        "-framerate", "30",
//        "-i", "\(cameraInput)\(micInput)",
//        "-vcodec", "libx264",
//        "-preset", "ultrafast",
//        "-pix_fmt", "yuv420p",
//        outputPath
//    ]
//
//    // FFplay for live preview of camera
//    let ffplayArgs = [
//        "-f", "avfoundation",
//        "-framerate", "30",
//        "-i", cameraInput
//    ]
//
//    DispatchQueue.global().async {
//        let ffmpeg = Process()
//        ffmpeg.launchPath = ffmpegPath
//        ffmpeg.arguments = ffmpegArgs
//
//        do {
//            try ffmpeg.run()
//        } catch {
//            print("❌ FFmpeg failed: \(error)")
//        }
//    }
//
//    DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
//        let ffplay = Process()
//        ffplay.launchPath = ffplayPath
//        ffplay.arguments = ffplayArgs
//
//        do {
//            try ffplay.run()
//        } catch {
//            print("❌ FFplay failed: \(error)")
//        }
//    }
// }
//
// import AVFoundation
// import AVKit
//
// struct IPCameraRecorderView: View {
//    @StateObject private var cameraManager = IPCameraManager()
//    @State private var cameraURL = "rtsp://username:password@192.168.1.100:554/stream"
//    @State private var isRecording = false
//    @State private var outputPath = ""
//    @State private var showSettings = false
//
//    var body: some View {
//        VStack {
//            // Camera stream preview
//            if cameraManager.isPreviewSetup {
//                VideoPlayerView(player: cameraManager.previewPlayer)
//                    .frame(minHeight: 300)
//                    .cornerRadius(8)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 8)
//                            .stroke(Color.gray, lineWidth: 1)
//                    )
//            } else {
//                ZStack {
//                    Color.black
//                        .frame(minHeight: 300)
//                        .cornerRadius(8)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 8)
//                                .stroke(Color.gray, lineWidth: 1)
//                        )
//
//                    VStack {
//                        Text("No Preview")
//                            .foregroundColor(.white)
//
//                        Button("Connect Camera") {
//                            cameraManager.startPreview(url: cameraURL)
//                        }
//                        .padding(8)
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(4)
//                    }
//                }
//            }
//
//            // Camera URL input
//            HStack {
//                Text("Camera URL:")
//                TextField("rtsp://username:password@ip:port/stream", text: $cameraURL)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .disabled(cameraManager.isPreviewSetup || isRecording)
//
//                Button(action: {
//                    if cameraManager.isPreviewSetup {
//                        cameraManager.stopPreview()
//                    } else {
//                        cameraManager.startPreview(url: cameraURL)
//                    }
//                }) {
//                    Text(cameraManager.isPreviewSetup ? "Disconnect" : "Connect")
//                }
//                .disabled(isRecording)
//            }
//            .padding(.horizontal)
//
//            // Status indicators
//            HStack {
//                Circle()
//                    .fill(cameraManager.isPreviewSetup ? Color.green : Color.red)
//                    .frame(width: 10, height: 10)
//
//                Text(cameraManager.statusMessage)
//                    .font(.caption)
//
//                Spacer()
//
//                if isRecording {
//                    Circle()
//                        .fill(Color.red)
//                        .frame(width: 10, height: 10)
//                    Text("Recording")
//                        .foregroundColor(.red)
//                        .font(.caption)
//                }
//            }
//            .padding(.horizontal)
//
//            // Recording controls
//            HStack(spacing: 20) {
//                Button(action: {
//                    if isRecording {
//                        stopRecording()
//                    } else {
//                        startRecording()
//                    }
//                }) {
//                    Text(isRecording ? "Stop Recording" : "Start Recording")
//                        .frame(minWidth: 120)
//                }
//                .disabled(!cameraManager.isPreviewSetup)
//
//                Button("Recording Settings") {
//                    showSettings.toggle()
//                }
//                .disabled(isRecording)
//            }
//            .padding()
//
//            if !outputPath.isEmpty {
//                Text("Saved to: \(outputPath)")
//                    .font(.caption)
//                    .lineLimit(1)
//                    .truncationMode(.middle)
//                    .padding(.horizontal)
//            }
//        }
//        .padding()
//        .sheet(isPresented: $showSettings) {
//            RecordingSettingsView(settings: $cameraManager.recordingSettings)
//                .frame(width: 400, height: 500)
//        }
//        .onDisappear {
//            cameraManager.stopPreview()
//            if isRecording {
//                stopRecording()
//            }
//        }
//    }
//
//    func startRecording() {
//        guard let ffmpegPath = cameraManager.ffmpegPath else { return }
//
//        // Create output directory if needed
//        let outputDir = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Movies/IPCamera")
//        try? FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
//
//        // Create output file path with timestamp
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
//        let timestamp = dateFormatter.string(from: Date())
//        outputPath = outputDir.appendingPathComponent("ipcam_recording_\(timestamp).mp4").path
//
//        // Start FFmpeg recording
//        cameraManager.startRecording(inputURL: cameraURL, outputPath: outputPath)
//
//        isRecording = true
//    }
//
//    func stopRecording() {
//        cameraManager.stopRecording()
//        isRecording = false
//    }
// }
//
//// SwiftUI wrapper for AVPlayer
// struct VideoPlayerView: NSViewRepresentable {
//    var player: AVPlayer?
//
//    func makeNSView(context: Context) -> AVPlayerView {
//        let playerView = AVPlayerView()
//        playerView.player = player
//        playerView.controlsStyle = .none
//        return playerView
//    }
//
//    func updateNSView(_ nsView: AVPlayerView, context: Context) {
//        nsView.player = player
//    }
// }
//
//// Recording settings model
// struct RecordingSettings {
//    var videoCodec = "h264"            // h264, hevc, copy
//    var videoQuality = "medium"        // ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow
//    var videoBitrate = "2M"            // e.g., 1M, 2M, 5M
//    var frameRate = 30                 // frames per second
//    var audioCodec = "aac"             // aac, copy, none
//    var audioBitrate = "128k"          // e.g., 96k, 128k, 192k
//
//    // Convert to FFmpeg arguments
//    func toFFmpegArgs() -> [String] {
//        var args = [String]()
//
//        // Video settings
//        if videoCodec != "copy" {
//            args += ["-c:v", videoCodec]
//            args += ["-preset", videoQuality]
//            args += ["-b:v", videoBitrate]
//            args += ["-r", String(frameRate)]
//        } else {
//            args += ["-c:v", "copy"]
//        }
//
//        // Audio settings
//        if audioCodec == "none" {
//            args += ["-an"]  // No audio
//        } else if audioCodec == "copy" {
//            args += ["-c:a", "copy"]
//        } else {
//            args += ["-c:a", audioCodec]
//            args += ["-b:a", audioBitrate]
//        }
//
//        return args
//    }
// }
//
//// Settings view
// struct RecordingSettingsView: View {
//    @Binding var settings: RecordingSettings
//    @Environment(\.presentationMode) var presentationMode
//
//    let videoCodecs = ["h264", "hevc", "copy"]
//    let videoQualities = ["ultrafast", "superfast", "veryfast", "faster", "fast", "medium", "slow", "slower", "veryslow"]
//    let videoBitrates = ["500k", "1M", "2M", "3M", "5M", "8M"]
//    let frameRates = [10, 15, 24, 25, 30, 60]
//    let audioCodecs = ["aac", "copy", "none"]
//    let audioBitrates = ["64k", "96k", "128k", "192k", "256k"]
//
//    var body: some View {
//        VStack {
//            Text("Recording Settings")
//                .font(.headline)
//                .padding()
//
//            Form {
//                Section(header: Text("Video Settings")) {
//                    Picker("Video Codec", selection: $settings.videoCodec) {
//                        ForEach(videoCodecs, id: \.self) { codec in
//                            Text(codec)
//                        }
//                    }
//
//                    if settings.videoCodec != "copy" {
//                        Picker("Quality Preset", selection: $settings.videoQuality) {
//                            ForEach(videoQualities, id: \.self) { quality in
//                                Text(quality)
//                            }
//                        }
//
//                        Picker("Video Bitrate", selection: $settings.videoBitrate) {
//                            ForEach(videoBitrates, id: \.self) { bitrate in
//                                Text(bitrate)
//                            }
//                        }
//
//                        Picker("Frame Rate", selection: $settings.frameRate) {
//                            ForEach(frameRates, id: \.self) { fps in
//                                Text("\(fps) fps")
//                            }
//                        }
//                    }
//                }
//
//                Section(header: Text("Audio Settings")) {
//                    Picker("Audio Codec", selection: $settings.audioCodec) {
//                        ForEach(audioCodecs, id: \.self) { codec in
//                            Text(codec)
//                        }
//                    }
//
//                    if settings.audioCodec != "copy" && settings.audioCodec != "none" {
//                        Picker("Audio Bitrate", selection: $settings.audioBitrate) {
//                            ForEach(audioBitrates, id: \.self) { bitrate in
//                                Text(bitrate)
//                            }
//                        }
//                    }
//                }
//            }
//            .padding()
//
//            Button("Close") {
//                presentationMode.wrappedValue.dismiss()
//            }
//            .padding()
//        }
//    }
// }
//
// class IPCameraManager: ObservableObject {
//    // Published properties for UI updates
//    @Published var isPreviewSetup = false
//    @Published var statusMessage = "Camera not connected"
//    @Published var recordingSettings = RecordingSettings()
//
//    // FFmpeg and preview
//    var ffmpegPath: String?
//    var previewPlayer: AVPlayer?
//    var ffmpegProcesses = [Process]()
//
//    init() {
//        // Check for FFmpeg install path
//        self.ffmpegPath = findFFmpegPath()
//        if ffmpegPath == nil {
//            statusMessage = "FFmpeg not found"
//        }
//    }
//
//    func startPreview(url: String) {
//        guard !url.isEmpty else {
//            statusMessage = "Please enter a camera URL"
//            return
//        }
//
//        // For RTSP, HTTP, and other streaming protocols, we can use AVPlayer directly
//        if url.starts(with: "rtsp://") || url.starts(with: "http://") || url.starts(with: "https://") {
//            setupPlayerPreview(url: url)
//        }
//        // For other protocols or if AVPlayer fails, we can use FFmpeg to create an HLS stream
//        else if let ffmpegPath = ffmpegPath {
//            setupFFmpegPreview(inputURL: url, ffmpegPath: ffmpegPath)
//        } else {
//            statusMessage = "Unsupported camera URL or FFmpeg not found"
//        }
//    }
//
//    private func setupPlayerPreview(url: String) {
//        guard let streamURL = URL(string: url) else {
//            statusMessage = "Invalid URL"
//            return
//        }
//
//        // Create AVPlayer for the stream
//        let player = AVPlayer(url: streamURL)
//
//        // Configure player
//        player.automaticallyWaitsToMinimizeStalling = false
//        player.preventsDisplaySleepDuringVideoPlayback = true
//
//        // Set volume to zero for preview (often IP cameras have unwanted audio)
//        player.volume = 0
//
//        // Store player and update status
//        self.previewPlayer = player
//
//        // Start playback
//        player.play()
//
//        DispatchQueue.main.async {
//            self.isPreviewSetup = true
//            self.statusMessage = "Connected to camera"
//        }
//
//        // Add observer to handle playback issues
//        NotificationCenter.default.addObserver(
//            forName: .AVPlayerItemFailedToPlayToEndTime,
//            object: player.currentItem,
//            queue: .main
//        ) { [weak self] _ in
//            self?.statusMessage = "Stream playback failed"
//            self?.isPreviewSetup = false
//        }
//    }
//
//    private func setupFFmpegPreview(inputURL: String, ffmpegPath: String) {
//        // Create a temporary directory for the HLS stream
//        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("ipCameraStream")
//        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
//
//        // HLS playlist and segment path
//        let playlistPath = tempDir.appendingPathComponent("stream.m3u8").path
//        let segmentPattern = tempDir.appendingPathComponent("segment%03d.ts").path
//
//        // Create FFmpeg process for streaming
//        let process = Process()
//        process.executableURL = URL(fileURLWithPath: ffmpegPath)
//
//        // FFmpeg arguments to create an HLS stream from the input
//        process.arguments = [
//            "-y",                        // Overwrite files
//            "-i", inputURL,              // Input URL
//            "-c:v", "h264",              // Video codec
//            "-c:a", "aac",               // Audio codec
//            "-f", "hls",                 // HLS format
//            "-hls_time", "2",            // Segment duration
//            "-hls_list_size", "5",       // Number of segments to keep
//            "-hls_flags", "delete_segments", // Delete old segments
//            "-hls_segment_filename", segmentPattern, // Segment pattern
//            playlistPath                 // Output playlist
//        ]
//
//        // Setup pipes for logs
//        let pipe = Pipe()
//        process.standardError = pipe
//
//        // Start FFmpeg
//        do {
//            try process.run()
//            ffmpegProcesses.append(process)
//
//            // Wait a moment for FFmpeg to create the initial segments
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
//                // Create player for the local HLS stream
//                let playlistURL = URL(fileURLWithPath: playlistPath)
//                let player = AVPlayer(url: playlistURL)
//                player.automaticallyWaitsToMinimizeStalling = false
//                player.volume = 0
//
//                // Store player and update status
//                self?.previewPlayer = player
//                player.play()
//
//                DispatchQueue.main.async {
//                    self?.isPreviewSetup = true
//                    self?.statusMessage = "Connected to camera via FFmpeg"
//                }
//            }
//        } catch {
//            statusMessage = "Error starting FFmpeg: \(error.localizedDescription)"
//        }
//    }
//
//    func stopPreview() {
//        // Stop player
//        previewPlayer?.pause()
//        previewPlayer = nil
//
//        // Stop any FFmpeg processes used for preview
//        stopFFmpegProcesses(exceptRecording: true)
//
//        isPreviewSetup = false
//        statusMessage = "Camera disconnected"
//    }
//
//    func startRecording(inputURL: String, outputPath: String) {
//        guard let ffmpegPath = ffmpegPath else {
//            statusMessage = "FFmpeg not found"
//            return
//        }
//
//        // Create FFmpeg process
//        let process = Process()
//        process.executableURL = URL(fileURLWithPath: ffmpegPath)
//
//        // Build basic FFmpeg arguments
//        var arguments = [
//            "-y",                // Overwrite output
//            "-i", inputURL       // Input URL
//        ]
//
//        // Add video/audio settings from recording settings
//        arguments += recordingSettings.toFFmpegArgs()
//
//        // Add output file
//        arguments.append(outputPath)
//
//        // Set up pipes for output
//        let outputPipe = Pipe()
//        process.standardError = outputPipe
//
//        // Monitor FFmpeg output
//        let outputHandle = outputPipe.fileHandleForReading
//        outputHandle.readabilityHandler = { [weak self] handle in
//            let data = handle.availableData
//            if !data.isEmpty, let output = String(data: data, encoding: .utf8) {
//                print("FFmpeg output: \(output)")
//
//                // Update status if there's an error
//                if output.lowercased().contains("error") {
//                    DispatchQueue.main.async {
//                        self?.statusMessage = "Recording error"
//                    }
//                }
//            }
//        }
//
//        // Start recording
//        do {
//            try process.run()
//            ffmpegProcesses.append(process)
//            statusMessage = "Recording started"
//        } catch {
//            statusMessage = "Error starting recording: \(error.localizedDescription)"
//        }
//    }
//
//    func stopRecording() {
//        // Find and stop any recording FFmpeg processes
//        let recordingProcesses = ffmpegProcesses.filter { $0.isRunning }
//
//        for process in recordingProcesses {
//            // Send SIGINT (equivalent to Ctrl+C) for clean shutdown
//            process.interrupt()
//
//            // Remove from our processes list
//            if let index = ffmpegProcesses.firstIndex(of: process) {
//                ffmpegProcesses.remove(at: index)
//            }
//        }
//
//        statusMessage = "Recording stopped"
//    }
//
//    func stopFFmpegProcesses(exceptRecording: Bool = false) {
//        let processesToStop = exceptRecording ?
//            ffmpegProcesses.filter { $0 != ffmpegProcesses.last } :
//            ffmpegProcesses
//
//        for process in processesToStop {
//            if process.isRunning {
//                process.interrupt()
//            }
//
//            if let index = ffmpegProcesses.firstIndex(of: process) {
//                ffmpegProcesses.remove(at: index)
//            }
//        }
//    }
//
//    // Find FFmpeg installation path
//    private func findFFmpegPath() -> String? {
//        // Check common locations
//        let potentialPaths = [
//            "/usr/local/bin/ffmpeg",       // Homebrew default
//            "/opt/homebrew/bin/ffmpeg",    // Apple Silicon Homebrew
//            "/usr/bin/ffmpeg",             // System install
//            "/opt/local/bin/ffmpeg"        // MacPorts
//        ]
//
//        for path in potentialPaths {
//            if FileManager.default.fileExists(atPath: path) {
//                return path
//            }
//        }
//
//        // Try which command
//        let process = Process()
//        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
//        process.arguments = ["ffmpeg"]
//
//        let pipe = Pipe()
//        process.standardOutput = pipe
//
//        do {
//            try process.run()
//            let data = pipe.fileHandleForReading.readDataToEndOfFile()
//            process.waitUntilExit()
//
//            if let path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
//               !path.isEmpty,
//               FileManager.default.fileExists(atPath: path) {
//                return path
//            }
//        } catch {
//            print("Error finding FFmpeg: \(error)")
//        }
//
//        return nil
//    }
// }
//
//// Usage example
// struct ContentView: View {
//    var body: some View {
//        VStack {
//            Text("IP Camera Recorder")
//                .font(.title)
//                .padding()
//
//            IPCameraRecorderView()
//                .frame(minWidth: 640, minHeight: 480)
//        }
//        .padding()
//    }
// }

import AVFoundation
import SwiftUI

struct ContentViewTest: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var isRecording = false
    @State private var selectedCamera: AVCaptureDevice?
    @State private var selectedMicrophone: AVCaptureDevice?
    @State private var recordingPath: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Camera Viewer").font(.largeTitle)
                    
                    HStack {
                        Text("IP Camera URL:")
                        TextField("rtsp://username:password@ip:port/stream", text: $cameraManager.ipCameraURL)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Button("Connect to IP Camera") {
                        connectToIPCamera()
                    }
                    .padding(.vertical, 5)
                    
                    Divider()
                    
                    Text("Available Devices:").font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Cameras:").font(.subheadline)
                            List(cameraManager.availableCameras, id: \.uniqueID) { camera in
                                HStack {
                                    Text(camera.localizedName)
                                    Spacer()
                                    if selectedCamera?.uniqueID == camera.uniqueID {
                                        Image(systemName: "checkmark")
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedCamera = camera
                                    cameraManager.switchToCamera(camera)
                                }
                            }
                            .frame(height: 120)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Microphones:").font(.subheadline)
                            List(cameraManager.availableMicrophones, id: \.uniqueID) { mic in
                                HStack {
                                    Text(mic.localizedName)
                                    Spacer()
                                    if selectedMicrophone?.uniqueID == mic.uniqueID {
                                        Image(systemName: "checkmark")
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedMicrophone = mic
                                }
                            }
                            .frame(height: 120)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Button(action: {
                            toggleRecording()
                        }) {
                            HStack {
                                Image(systemName: isRecording ? "stop.circle.fill" : "record.circle")
                                    .foregroundColor(isRecording ? .red : .primary)
                                Text(isRecording ? "Stop Recording" : "Start Recording")
                            }
                            .padding(8)
                        }
                        .disabled(!cameraManager.isSetup && cameraManager.ipCameraURL.isEmpty)
                        
                        if isRecording {
                            Text("Recording to: \(recordingPath)")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding()
                .frame(width: 300)
                
                Divider()
                
                // Camera preview
                ZStack {
                    if cameraManager.isSetup {
                        CameraPreviewView(cameraManager: cameraManager)
                    } else {
                        Rectangle()
                            .fill(Color.black.opacity(0.8))
                            .overlay(
                                Text("No camera connected")
                                    .foregroundColor(.white)
                            )
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding()
            }
        }
        .onAppear {
            cameraManager.checkAuthorization()
            cameraManager.setupSession()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Camera Viewer"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func connectToIPCamera() {
        if !cameraManager.ipCameraURL.isEmpty {
            // Stop any existing stream
            if cameraManager.isSetup {
                cameraManager.stopSession()
            }
            
            // Use FFmpeg to connect to the IP camera stream
            cameraManager.connectToIPCamera(url: cameraManager.ipCameraURL) { success, message in
                if !success {
                    alertMessage = message
                    showAlert = true
                }
            }
        }
    }
    
    private func toggleRecording() {
        if isRecording {
            // Stop recording
            cameraManager.stopRecording()
            isRecording = false
        } else {
            // Start recording
            let desktopPath = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).first!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
            let dateString = dateFormatter.string(from: Date())
            recordingPath = "\(desktopPath)/recording_\(dateString).mp4"
            
            if cameraManager.startRecording(toPath: recordingPath, withMicrophone: selectedMicrophone) {
                isRecording = true
            } else {
                alertMessage = "Failed to start recording"
                showAlert = true
            }
        }
    }
}

// Camera preview view using AVCaptureVideoPreviewLayer
struct CameraPreviewView: NSViewRepresentable {
    var cameraManager: CameraManager
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor
        
        if let previewLayer = cameraManager.previewLayer {
            previewLayer.frame = view.bounds
            previewLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
            view.layer?.addSublayer(previewLayer)
        }
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if let previewLayer = cameraManager.previewLayer {
            previewLayer.frame = nsView.bounds
        }
    }
}

class CameraManager: ObservableObject {
    @Published var availableCameras: [AVCaptureDevice] = []
    @Published var availableMicrophones: [AVCaptureDevice] = []
    @Published var isSetup = false
    @Published var ipCameraURL: String = ""
    
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    private var videoOutput: AVCaptureMovieFileOutput?
    private var ffmpegProcess: Process?
    
    init() {
        discoverCameras()
    }
    
    func checkAuthorization() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.discoverCameras()
                    }
                }
            }
        case .authorized:
            discoverCameras()
        default:
            break
        }
    }
    
    func discoverCameras() {
        // Get available cameras
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .external],
            mediaType: .video,
            position: .unspecified
        )
        availableCameras = discoverySession.devices
        
        // Get available microphones
        let audioDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.microphone, .external],
            mediaType: .audio,
            position: .unspecified
        )
        availableMicrophones = audioDiscoverySession.devices
    }
    
    func setupSession() {
        guard !availableCameras.isEmpty else { return }
        
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .high
        
        if let camera = availableCameras.first {
            switchToCamera(camera)
        }
    }
    
    func switchToCamera(_ camera: AVCaptureDevice) {
        guard let captureSession = captureSession else { return }
        
        // Remove all existing inputs
        for input in captureSession.inputs {
            captureSession.removeInput(input)
        }
        
        // Add the new camera input
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            
            captureSession.beginConfiguration()
            if captureSession.canAddInput(cameraInput) {
                captureSession.addInput(cameraInput)
            }
            
            // Setup the video output for recording
            if videoOutput == nil {
                videoOutput = AVCaptureMovieFileOutput()
                if captureSession.canAddOutput(videoOutput!) {
                    captureSession.addOutput(videoOutput!)
                }
            }
            
            captureSession.commitConfiguration()
            
            // Create preview layer if it doesn't exist
            if previewLayer == nil {
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = .resizeAspect
            }
            
            startSession()
            isSetup = true
        } catch {
            print("Error setting up camera: \(error)")
        }
    }
    
    func startSession() {
        if let captureSession = captureSession, !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession?.startRunning()
            }
        }
    }
    
    func stopSession() {
        if let captureSession = captureSession, captureSession.isRunning {
            captureSession.stopRunning()
        }
        
        // Stop FFmpeg if it's running
        ffmpegProcess?.terminate()
        ffmpegProcess = nil
        
        isSetup = false
    }
    
    func connectToIPCamera(url: String, completion: @escaping (Bool, String) -> Void) {
        stopSession() // Stop any existing session
        
        // Use FFmpeg to connect to the IP camera
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/ffplay") // Make sure ffplay is installed
        process.arguments = [
            "-hide_banner",
            "-loglevel", "warning",
            "-fflags", "nobuffer",
            "-flags", "low_delay",
            "-framedrop",
            url
        ]
        
        do {
            try process.run()
            ffmpegProcess = process
            isSetup = true
            completion(true, "Connected to IP camera")
        } catch {
            completion(false, "Failed to connect to IP camera: \(error.localizedDescription)")
        }
    }
    
//    func startRecording(toPath path: String, withMicrophone microphone: AVCaptureDevice?) -> Bool {
//        // Using FFmpeg for recording
//        let process = Process()
//        process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/ffmpeg") // Make sure ffmpeg is installed
//
//        var arguments = [
//            "-y",  // Overwrite output file if it exists
//            "-loglevel", "warning"
//        ]
//
//        if let captureSession = captureSession, captureSession.isRunning {
//            // Record from local camera
//            arguments += [
//                "-f", "avfoundation",
//                "-framerate", "30",
//                "-video_size", "1280x720",
//                "-i", "default"  // Default camera
//            ]
//        } else if !ipCameraURL.isEmpty {
//            // Record from IP camera
//            arguments += [
//                "-i", ipCameraURL
//            ]
//        } else {
//            return false
//        }
//
//        // Add microphone if selected
//        if let mic = microphone {
//            arguments += [
//                "-f", "avfoundation",
//                "-i", ":\(mic.uniqueID)", // Audio device
//                "-c:a", "aac",
//                "-strict", "experimental"
//            ]
//        }
//
//        // Output settings
//        arguments += [
//            "-c:v", "h264",
//            "-preset", "medium",
//            "-crf", "23",
//            "-r", "30",
//            "-pix_fmt", "uyvy422",
//            path
//        ]
//
//        process.arguments = arguments
//
//        do {
//            try process.run()
//            ffmpegProcess = process
//            return true
//        } catch {
//            print("Failed to start recording: \(error)")
//            return false
//        }
//    }
    
    func startRecording(toPath path: String, withMicrophone microphone: AVCaptureDevice?) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/ffmpeg")

        var arguments = ["-y"] // Overwrite output file if it exists

        if let captureSession = captureSession, captureSession.isRunning {
            // 🔹 LOCAL CAMERA + MIC (AVFoundation input)
            // Replace with your actual device indexes
            let videoDeviceIndex = "0"
            let audioDeviceIndex = microphone != nil ? "0" : ""

            let deviceInput = "\(videoDeviceIndex):\(audioDeviceIndex)"
            
            arguments += [
                "-f", "avfoundation",
                "-framerate", "30",
                "-video_size", "1280x720",
                "-i", deviceInput,
                "-t", "00:00:10",
                "-c:v", "h264",
                "-preset", "medium",
                "-crf", "23",
                "-r", "30",
                "-c:a", "aac",
                "-strict", "experimental",
                path
            ]
        } else if !ipCameraURL.isEmpty, let mic = microphone {
            // 🔹 IP CAMERA + MIC (2 separate inputs)
            // Get mic device index (you should fetch actual index if needed)
            let audioDeviceIndex = "1" // Adjust as necessary
            
            arguments += [
                "-i", ipCameraURL,
                "-f", "avfoundation",
                "-i", ":\(audioDeviceIndex)",
                "-map", "0:v:0",
                "-map", "1:a:0",
                "-c:v", "copy", // or h264 if transcoding needed
                "-c:a", "aac",
                "-strict", "experimental",
                path
            ]
        } else if !ipCameraURL.isEmpty {
            // 🔹 IP CAMERA ONLY (no mic)
            arguments += [
                "-i", ipCameraURL,
                "-c:v", "copy",
                path
            ]
        } else {
            print("No input device found.")
            return false
        }

        process.arguments = arguments

        do {
            try process.run()
            ffmpegProcess = process
            return true
        } catch {
            print("Failed to start recording: \(error)")
            return false
        }
    }

    func stopRecording() {
        if videoOutput?.isRecording == true {
            videoOutput?.stopRecording()
        }
        
        // Stop FFmpeg recording
        ffmpegProcess?.terminate()
        ffmpegProcess = nil
    }
    
    deinit {
        stopSession()
    }
}
