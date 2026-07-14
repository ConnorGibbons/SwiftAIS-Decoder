//
//  AISMessage.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/14/26.
//

protocol AISMessage {
    var nmeaSentence: AISNMEA0183Sentence { get }
    var messageType: AISMessageType { get }
    var mmsiNumber: MMSI { get }
    
    func description() -> String // Give a human-readable version of the message
}
