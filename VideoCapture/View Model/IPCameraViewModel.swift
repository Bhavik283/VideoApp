//
//  IPCameraViewModel.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 15/05/25.
//

import Foundation

class IPCameraViewModel: ObservableObject {
    @Published var activeCamera: IPCamera?
    @Published var cameraList: [IPCamera] = [] {
        didSet {
            StorageViewModel.shared.saveIPCameras(cameraList)
        }
    }

    // Input fields bound to UI
    @Published var name: String = ""
    @Published var url: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var rtp: RTP = .rtp
    @Published var sdpFile: String = ""
    @Published var deinterfaceFeed: Bool = false

    init() {
        cameraList = StorageViewModel.shared.loadIPCameras()
    }

    // MARK: - CRUD

    func addNewCamera() {
        let newCamera = IPCamera(name: "IP Camera \(cameraList.count + 1)")
        cameraList.append(newCamera)
        activeCamera = newCamera
    }

    func removeActiveCamera() {
        guard let active = activeCamera else { return }
        if let index = cameraList.firstIndex(of: active) {
            cameraList.remove(at: index)
            activeCamera = nil
        }
    }

    func updateCameraName(at index: Int, newName: String) -> Bool {
        guard index >= 0, index < cameraList.count else { return false }
        cameraList[index].name = newName
        return true
    }
}
