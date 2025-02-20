//
//  SimulatorInfo.swift
//
//  Created by Alex da Franca on 23.06.21.
//

import Foundation

/// Codable response object of 'simctl -j' (JSON) output.
struct SimulatorInfo: Codable {
    let udid: String // "60D88D7C-7E8D-4F9F-8CB7-51C0D6CA77A3",
    let name: String // "iPhone 12 Pro"
    let state: String // "Shutdown",
    
    let dataPath: String? // "\/Users\/miniagent-05\/Library\/Developer\/CoreSimulator\/Devices\/60D88D7C-7E8D-4F9F-8CB7-51C0D6CA77A3\/data",
    let logPath: String? // "\/Users\/miniagent-05\/Library\/Logs\/CoreSimulator\/60D88D7C-7E8D-4F9F-8CB7-51C0D6CA77A3",
    let isAvailable: Bool? // true,
    let deviceTypeIdentifier: String? // "com.apple.CoreSimulator.SimDeviceType.iPhone-12-Pro"

    func isMatched(name: String, exact: Bool) -> Bool {
        if name.isEmpty {
            return true
        } else if exact, self.name == name {
            return true
        } else if !exact, self.name.contains(name) {
            return true
        } else {
            return false
        }
    }
}
