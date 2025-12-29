//
//  NISQuery.swift
//  APC UPS Status
//
//  Created by Ioan Moldovan on 10/05/2020.
//  Copyright © 2020 Ioan Moldovan. All rights reserved.
//

import Foundation
import Socket
import SwiftUI
import SwiftSnmpKit
import AsyncDNSResolver


enum SNMPQueryStatus {
    case Success
    case Failure
}

class SNMPQuery {
    public var QueryHashmap: [String : String]!
    
    let upsOIDPrettyName: [String: String] = [
        
        // MARK: - UPS Identity
        "1.3.6.1.2.1.33.1.1.1.0": "Manufacturer: ",
        "1.3.6.1.2.1.33.1.1.2.0": "Model: ",
        "1.3.6.1.2.1.33.1.1.3.0": "UPS Software Version: ",
        "1.3.6.1.2.1.33.1.1.4.0": "Agent Software Version: ",
        "1.3.6.1.2.1.33.1.1.5.0": "UPS Name: ",
        "1.3.6.1.2.1.33.1.1.6.0": "Attached Devices: ",
        
        // MARK: - Battery
        "1.3.6.1.2.1.33.1.2.1.0": "Battery Status: ",
        "1.3.6.1.2.1.33.1.2.2.0": "Seconds on Battery: ",
        "1.3.6.1.2.1.33.1.2.3.0": "Estimated Minutes Remaining: ",
        "1.3.6.1.2.1.33.1.2.4.0": "Battery Charge (%): ",
        "1.3.6.1.2.1.33.1.2.5.0": "Battery Voltage: ",
        "1.3.6.1.2.1.33.1.2.6.0": "Battery Current: ",
        "1.3.6.1.2.1.33.1.2.7.0": "Battery Temperature: ",
        
        // MARK: - Input
        "1.3.6.1.2.1.33.1.3.1.0": "Input Line Bads: ",
        "1.3.6.1.2.1.33.1.3.2.0": "Number of Input Lines: ",
        
        // MARK: - Output
        "1.3.6.1.2.1.33.1.4.1.0": "Output Source: ",
        "1.3.6.1.2.1.33.1.4.2.0": "Output Frequency: ",
        "1.3.6.1.2.1.33.1.4.3.0": "Number of Output Lines: ",
        
        // MARK: - Alarms
        "1.3.6.1.2.1.33.1.6.1.0": "Alarm Present: ",
        "1.3.6.1.2.1.33.1.6.2.0": "Alarm Count: "
    ]
    
    func isIPAddress(_ host: String) -> Bool {
        var ipv4 = in_addr()
        var ipv6 = in6_addr()
        
        if host.withCString({ inet_pton(AF_INET, $0, &ipv4) }) == 1 {
            return true
        }
        
        if host.withCString({ inet_pton(AF_INET6, $0, &ipv6) }) == 1 {
            return true
        }
        
        return false
    }
    
    public func GetStatus(_ hostname: String)  -> SNMPQueryStatus
    {
        let sema = DispatchSemaphore (value: 0)
        guard let snmpSender = SnmpSender.shared else {
            fatalError("Snmp Sender not inialized")
        }
        var addr : String?
        
        Task {
            do {
                if isIPAddress(hostname) {
                    addr = hostname
                } else {
                    let resolver = try AsyncDNSResolver()
                    addr = try await resolver.queryA(name: hostname).first?.address.address
                    
                }
            } catch
            {
                
            }
            sema.signal()
        }
        
        _ = sema.wait(timeout: .distantFuture)
        if (addr == nil) { return .Failure }
        
        QueryHashmap = [:]
        
        
        for (oid, prettyName) in upsOIDPrettyName {
            
            Task {
                let getResult =  await snmpSender.send(host: addr!, command: .getRequest, community: "public", oid: oid)
                
                switch getResult {
                case .success(let variableBinding):
                    switch variableBinding.value {
                    case .octetString(let bytes):
                        QueryHashmap[prettyName] =  bytes.withUnsafeBytes { buffer in
                            String(decoding: buffer, as: UTF8.self)
                        }
                        break
                    case .integer(let intvalue):
                        switch oid {
                            // Battery Status
                        case "1.3.6.1.2.1.33.1.2.1.0":
                            switch (intvalue)
                            {
                            case 2:
                                QueryHashmap[prettyName] = "Normal"
                            case 3:
                                QueryHashmap[prettyName] = "Low"
                            case 4:
                                QueryHashmap[prettyName] = "Depleted"
                            default:
                                QueryHashmap[prettyName] = "Unknown"
                            }
                            
                            break
                            // Voltage & frequency
                        case "1.3.6.1.2.1.33.1.2.5.0":
                            fallthrough
                        case "1.3.6.1.2.1.33.1.4.2.0":
                            QueryHashmap[prettyName] = String(Double(intvalue)/10)
                            break
                            // Output Source
                        case "1.3.6.1.2.1.33.1.4.1.0":
                            switch (intvalue)
                            {
                            case 3, 4:
                                QueryHashmap[prettyName] = "On-Line"
                                break
                            case 5, 6:
                                QueryHashmap[prettyName] = "Battery"
                                break
                            default:
                                QueryHashmap[prettyName] = "Unknown (\(intvalue))"
                                break
                            }
                            break
                        default:
                            QueryHashmap[prettyName] = String(intvalue)
                            break
                            
                        }
                        
                        
                        break
                    case .gauge32(let uintvalue):
                        QueryHashmap[prettyName] = String(uintvalue)
                        break
                    default: break
                    }
                    
                default: break
                }
                sema.signal()
            }
            
            _ = sema.wait(timeout: .distantFuture)
            
        }
        
        
        
        
        if (!QueryHashmap.isEmpty) {
            return .Success
        } else { return .Failure }
    }
    
}
