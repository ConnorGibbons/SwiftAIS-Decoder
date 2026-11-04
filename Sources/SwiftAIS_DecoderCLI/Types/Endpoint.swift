//
//  Endpoint.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 11/3/26.
//

enum EndpointErrors: Error {
    case badFormat
    case badIP
    case badPort
}

struct Endpoint {
    let ip: String
    let port: UInt16
    
    init(fromString: String) throws {
        let split = fromString.split(separator: ":")
        guard split.count == 2 else { throw EndpointErrors.badFormat }
        guard let port = UInt16(split[1]) else { throw EndpointErrors.badPort }
        self.ip = String(split[0])
        self.port = port
    }
    
}

