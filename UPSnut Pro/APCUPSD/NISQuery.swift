//
//  NISQuery.swift
//  APC UPS Status
//
//  Created by Ioan Moldovan on 10/05/2020.
//  Copyright © 2020 Ioan Moldovan. All rights reserved.
//

import Foundation
import Socket

enum NISQueryType {
    case Status
    case Events
}

enum NISQueryStatus {
    case Success
    case Failure
}

class NISQuery {
    internal var NISQueryType : NISQueryType
    
    internal let StatusByteRequest : [UInt8] = [
        0x00, 0x06, 0x73, 0x74, 0x61, 0x74, 0x75, 0x73
    ]
    
    internal let EventsByteRequest : [UInt8] = [
        0x00, 0x06, 0x65, 0x76, 0x65, 0x6e, 0x74, 0x73
    ]
    
    public var QueryResult: [String]!
    
    private var unreadData: Data
    
    init(_ queryType: NISQueryType)
    {
        self.NISQueryType = queryType
        self.unreadData = Data()
    }
    
    public func Execute(_ hostname: String, port: Int32) -> NISQueryStatus
    {
        do {
            let tcpClient = try Socket.create(family: .inet, type: .stream, proto: .tcp)
            try tcpClient.connect(to: hostname, port: port, timeout: 3000)
    
            if (self.NISQueryType == .Status) {
                return getCommandResult(tcpClient, byteRequest: StatusByteRequest)
            }
            if (self.NISQueryType == .Events) {
                return getCommandResult(tcpClient, byteRequest: EventsByteRequest)
            }
            return .Failure
        } catch {
            return .Failure
        }
    }
    
    internal func getCommandResult (_ tcpClient: Socket, byteRequest: [UInt8]) -> NISQueryStatus
    {
        do {
            try tcpClient.setBlocking(mode: true)
            try tcpClient.write(from: Data(byteRequest))
            
            QueryResult = [String]()
            
            if (!tcpClient.isConnected) {
                return .Failure
            }
            
            try tcpClient.setBlocking(mode: false)
            
            repeat {
                let lenBytes = try readAtLeast(tcpClient, numBytesWanted: 2)
                
                let len = Int(lenBytes[0] << 8 | lenBytes[1])
                
                guard len != 0 else {
                    tcpClient.close()
                    return .Success
                }
                
                
                var responseLineBytes = try readAtLeast(tcpClient, numBytesWanted: len)
                
                // Remove extra newline :-)
                responseLineBytes.removeLast()
                
                guard let responseLine = String(bytes: responseLineBytes, encoding: .utf8) else {
                        if (QueryResult.count > 0) {
                            QueryResult.append("Log is Corrupted! Contact Support!")
                            tcpClient.close()
                            return .Success
                        } else {
                            return .Failure
                        }
                    }
    
                QueryResult.append(responseLine)
            } while true
            
            
        } catch (let error) {
            print(error)
            tcpClient.close()
            return .Failure
        }
    
        
    }
    
    // Sometimes there are more bytes in the server's response than needed, and they all need to be read
    // else they will overwhelm the socket's buffer, so, in order to fix the endless issues,
    //
    // All bytes available are read, if it fails to read


    internal func readAtLeast(_ tcpClient: Socket, numBytesWanted: Int) throws -> Data {
        try tcpClient.setBlocking(mode: false)
        
        var result = Data()
        
        var tmp = Data()
        
        try tcpClient.read(into: &tmp)
        if (tmp.count > 0) { unreadData.append(tmp) }
        
        if (unreadData.count >= numBytesWanted) {
            result.append(unreadData.subdata(in: 0..<(numBytesWanted)))
            unreadData.removeSubrange(0..<(numBytesWanted))
            return result
        }
        else
        {
            let startTime = Date().timeIntervalSince1970
            
            repeat {
                tmp.removeAll()
         
                try tcpClient.read(into: &tmp)
                if (tmp.count > 0) { unreadData.append(tmp) }
                else {
                    // Timeout 3 seconds from last received data
                    if (Date().timeIntervalSince1970 - 3 > startTime)
                    {
                        throw "I'm sorry, Dave, request timed out! Buffer not enough: \(unreadData.count) bytes available"
                    }
                }
            }
            while (unreadData.count < numBytesWanted)
            
            result.append(unreadData.subdata(in: 0..<(numBytesWanted)))
            unreadData.removeSubrange(0..<(numBytesWanted))
            return result
        }
        

    }
    

}

// It's a Wonderful Life :-)

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
