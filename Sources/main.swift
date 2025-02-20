//
//  main.swift
//  findsimulator
//
//  Created by Alex da Franca on 23.06.21.
//

import Foundation
import ArgumentParser

private let marketingVersion = "0.2"

struct findsimulator: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Interface to simctl in order to get suitable strings for destinations for the xcodebuild command."
    )
    
    @Option(name: .shortAndLong, help: "The os type. It can be either 'ios', 'watchos' or 'tvos'. Does only apply without '-pairs' option.")
    var osType = "ios"

    @Option(name: .shortAndLong, help: "The major OS version. Can be something like '12' or '14', 'all' or 'latest', which is the latest installed major version. Does only apply without '-pairs' option.")
    var majorOSVersion = "all"

    @Option(name: .shortAndLong, help: "The minor OS version. Can be something like '2' or '4', 'all' or 'latest', which is the latest installed minor version of a given major version. Note, if 'majorOSVersion' is set to 'latest', then minor version will also be 'latest'. Does only apply without '-pairs' option.")
    var subOSVersion = "all"
    
    @Flag(name: .shortAndLong, help: "Find iPhone Simulator in available iPhone/Watch Pairs.")
    var pairs: Int

    @Flag(name: .shortAndLong, help: "List all available and matching simulators.")
    var listAll: Int
    
    @Flag(name: .shortAndLong, help: "Print version of this tool.")
    var version: Int

    @Flag(name: .shortAndLong, help: "Search for exact device name.")
    var exact = false

    @Flag(name: [.long, .customShort("u")], help: "Print udid only. It doesn not work with --list-all")
    var onlyUdid = false

    @Option(name: .shortAndLong, help: "Config based on xcodebuild destination format")
    var destination = ""

    @Argument(help: "A string check on the name of the simulator.")
    var name = ""

    mutating func run() throws {
        guard version != 1 else {
            printVersion()
            return
        }

        // override flags with destination attributes
        if destination != "" {
            let parser = DestinationParser(destination: destination)
            if let osType = parser.osType {
                self.osType = osType
            }
            if let majorOSVersion = parser.majorOSVersion {
                self.majorOSVersion = majorOSVersion
            }
            if let subOSVersion = parser.subOSVersion {
                self.subOSVersion = subOSVersion
            }
            if let name = parser.name {
                self.exact = true
                self.name = name
            }
        }

        let controller = SimulatorControl(
            osFilter: osType,
            majorVersionFilter: majorOSVersion,
            minorVersionFilter: subOSVersion,
            exact: exact,
            nameFilter: name
        )
        if pairs == 1 {
            let sims = (try controller.filterSimulatorPairs()).sorted(by: { $0.name > $1.name})
            if listAll == 1 {
                sims.forEach {
                    print("platform=iOS Simulator,id=\($0.udid),name=\($0.name)")
                }
            } else {
                if let first = sims.first {
                    if onlyUdid {
                        print(first.udid)
                    } else {
                        print("platform=iOS Simulator,id=\(first.udid)")
                    }
                } else {
                    throw(NSError.noDeviceFound)
                }
            }
        } else {
            let versions = (try controller.filterSimulators()).sorted(by: { $0.versionString > $1.versionString})
            if listAll == 1 {
                versions.forEach { osVersion in
                    osVersion.simulators
                        .filter({ $0.isMatched(name: name, exact: exact) })
                        .sorted(by: { $0.name > $1.name}).forEach {
                        print("platform=\(osVersion.platform),OS=\(osVersion.versionString),id=\($0.udid),name=\($0.name)")
                    }
                }
            } else {
                if let firstVersion = versions.first,
                   let first = firstVersion.simulators
                    .filter({ $0.isMatched(name: name, exact: exact) })
                    .sorted(by: { $0.name > $1.name}).first {
                    if onlyUdid {
                        print(first.udid)
                    } else {
                        print("platform=\(firstVersion.platform),id=\(first.udid)")
                    }
                } else {
                    throw(NSError.noDeviceFound)
                }
            }
        }
    }

    private func printVersion() {
        print(marketingVersion)
    }
}

private extension OsVersion {
    var versionString: String {
        return "\(majorVersion).\(minorVersion)"
    }
    var platform: String {
        return "\(name) Simulator"
    }
}

private extension NSError {
    static let noDeviceFound: NSError = {
        let domain = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? "com.farbflash"
        return NSError(domain: "\(domain).error", code: 1, userInfo: [NSLocalizedDescriptionKey: "No simulator found, which matches the query."])
    }()
}

findsimulator.main()
