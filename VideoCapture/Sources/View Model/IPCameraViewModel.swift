//
//  IPCameraViewModel.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 15/05/25.
//

import Foundation

class IPCameraViewModel: ObservableObject {
    @Published var activeCamera: IPCamera? {
        didSet {
            syncStateWithActiveCamera()
        }
    }

    @Published var cameraList: [IPCamera] = [] {
        didSet {
            StorageViewModel.shared.saveIPCameras(cameraList)
        }
    }

    // Input fields bound to UI
    @Published var url: String = "" { didSet { if !isSyncing { updateActiveCamera() } } }
    @Published var username: String = "" { didSet { if !isSyncing { updateActiveCamera() } } }
    @Published var password: String = "" { didSet { if !isSyncing { updateActiveCamera() } } }
    @Published var rtp: RTP = .rtp { didSet { if !isSyncing { updateActiveCamera() } } }
    @Published var sdpFile: String = "" { didSet { if !isSyncing { updateActiveCamera() } } }
    @Published var deinterfaceFeed: Bool = false { didSet { if !isSyncing { updateActiveCamera() } } }

    init() {
        cameraList = StorageViewModel.shared.loadIPCameras()
    }

    private var isSyncing: Bool = false

    private func syncStateWithActiveCamera() {
        guard let camera = activeCamera else { return }
        isSyncing = true

        url = camera.url
        username = camera.username
        password = camera.password
        rtp = camera.rtp
        sdpFile = camera.sdpFile ?? ""
        deinterfaceFeed = camera.deinterfaceFeed

        isSyncing = false
    }

    private func updateActiveCamera() {
        guard !isSyncing, var camera = activeCamera else { return }
        camera.url = url
        camera.username = username
        camera.password = password
        camera.rtp = rtp
        camera.sdpFile = sdpFile
        camera.deinterfaceFeed = deinterfaceFeed

        if activeCamera != camera {
            activeCamera = camera
            if let index = cameraList.firstIndex(where: { $0.id == camera.id }) {
                cameraList[index] = camera
            }
        }
    }

    // MARK: - CRUD

    func addNewCamera() {
        let newCamera = IPCamera(name: "IP Camera \(cameraList.count + 1)")
        cameraList.append(newCamera)
        activeCamera = newCamera
    }

    func removeCamera(at index: Int) {
        if index >= 0 && index < cameraList.count {
            cameraList.remove(at: index)
            activeCamera = nil
        }
    }

    func setActiveValue(at index: Int?) {
        if index == nil {
            activeCamera = nil
        } else if let index, index >= 0 && index < cameraList.count {
            activeCamera = cameraList[index]
        }
    }

    func updateName(for id: UUID, to newName: String) {
        guard let index = cameraList.firstIndex(where: { $0.id == id }) else { return }
        var updated = cameraList[index]
        updated.name = newName
        cameraList[index] = updated

        if activeCamera?.id == updated.id {
            activeCamera = updated
        }
    }
}
