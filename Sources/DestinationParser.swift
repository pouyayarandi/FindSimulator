//
//  DestinationParser.swift
//  
//
//  Created by Pouya on 5/27/1402 AP.
//

import Foundation

struct DestinationParser {
    let destination: String

    private var dict: [String: String] {
        .init(uniqueKeysWithValues: destination
            .components(separatedBy: ",")
            .map({
                let pair = $0.components(separatedBy: "=")
                return (pair[0], pair[1])
            }))
    }

    var osType: String? {
        dict["platform"]?
            .replacingOccurrences(of: " Simulator", with: "")
            .lowercased()
    }

    var majorOSVersion: String? {
        let os = dict["OS"]
        if os == "latest" {
            return os
        } else {
            return os?.components(separatedBy: ".")[0]
        }
    }

    var subOSVersion: String? {
        let os = dict["OS"]
        if os == "latest" {
            return os
        } else {
            return os?.components(separatedBy: ".")[1]
        }
    }

    var name: String? {
        dict["name"]
    }
}
