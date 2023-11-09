//
//  SlideshowManager.swift
//  authandsearch2
//
//  Created by Carl Rudling on 2023-10-31.
//

import Foundation
import SwiftUI

class SlideshowManager: ObservableObject {
    @Published var counter: Int = 0
    var timer = Timer()
    
    
    func start() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0,
                                          repeats: true) { _ in
            self.counter += 1
        }
    }
    
    func stop() {
        self.timer.invalidate()
    }
    
    func reset() {
        self.counter = 0
        self.timer.invalidate()
    }
}
