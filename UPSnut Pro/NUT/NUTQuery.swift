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


enum NUTQueryStatus {
    case Success
    case Failure
}

class NUTQuery {
 
    public var QueryResult: [String]!
    public var QueryHashmap: [String : String]!
    
    public func GetStatus(_ hostname: String, port: Int32, username: String, password: String, nickname: String) -> NUTQueryStatus
    {
        do {
            let tcpClient = try Socket.create(family: .inet, type: .stream, proto: .tcp)
            try tcpClient.connect(to: hostname, port: port, timeout: 3000)
            try tcpClient.setBlocking(mode: true)
            
            if (!tcpClient.isConnected) {
                return .Failure
            }
            
            try tcpClient.write(from: "VER\r\n")
            guard let responseVer = try tcpClient.readString() else { return .Failure }
            if (responseVer.contains("Network UPS Tools"))
            {
                try tcpClient.write(from: "USERNAME \(username)\r\n")
                guard let responseUser = try tcpClient.readString() else { return .Failure }
                if (!responseUser.contains("OK")) { return .Failure }
                try tcpClient.write(from: "PASSWORD \(password)\r\n")
                guard let responsePassword = try tcpClient.readString() else { return .Failure }
                if (!responsePassword.contains("OK")) { return .Failure }
                try tcpClient.write(from: "LOGIN \(nickname)\r\n")
                guard let responseLogin = try tcpClient.readString() else { return .Failure }
                if (!responseLogin.contains("OK")) { return .Failure }
                
                QueryResult = [String]()
                try tcpClient.write(from: "LIST VAR \(nickname)\r\n")
                guard var responseList = try tcpClient.readString() else { return .Failure }
              
                if (responseList.contains("BEGIN LIST VAR \(nickname)")) {
                    var responseString = responseList
                    responseList = responseList.replacingOccurrences(of: "\n", with: "")
                    QueryResult.append(responseList)
                    
                    var responseListComplete = try tcpClient.readString()!
                    
                    while !responseListComplete.contains("END LIST VAR \(nickname)")
                    {
                        responseString.append(contentsOf: responseListComplete)
                        responseListComplete = try tcpClient.readString()!
                    }
                    responseString.append(contentsOf: responseListComplete)
                    QueryResult.append(contentsOf: responseString.components(separatedBy: "\n"))
                  
                    tcpClient.close()
                    
                    QueryResult = QueryResult.filter{ !$0.isEmpty }
               
                    for i in QueryResult.indices {
                        QueryResult[i] = QueryResult[i].replacingOccurrences(of: "VAR \(nickname) ", with: "")
                    }
                    
                    QueryResult.removeFirst()
                    QueryResult.removeLast()
                  
                    QueryHashmap = [String : String]()
                    
                    for i in QueryResult.indices {
               
                        let spacePos = QueryResult[i].firstIndex(of: " ")!
                      
                        QueryHashmap.updateValue( String(QueryResult[i].suffix(from: QueryResult[i].index(spacePos, offsetBy: 1))).replacingOccurrences(of: "\"", with: ""), forKey: String(QueryResult[i].prefix(upTo: spacePos)))
                      
                    }
                    
                    return .Success
                }
                else {
                    return .Failure
                }
                
            } else { return .Failure }
  
        } catch {
            return .Failure
        }
    }
    
}
