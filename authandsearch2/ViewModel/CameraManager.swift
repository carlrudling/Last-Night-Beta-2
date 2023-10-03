//
//  CameraManager.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-10-02.
//

import Foundation
import UIKit
import AVFoundation

class CameraManager {
    static let shared = CameraModel()

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc func appMovedToBackground() {
        // Stop the camera session if it's running
    }

    @objc func appMovedToForeground() {
        // Start the camera session if it's not running
    }
}
