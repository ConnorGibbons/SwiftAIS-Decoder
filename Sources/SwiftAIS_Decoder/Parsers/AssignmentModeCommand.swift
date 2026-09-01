//
//  AssignmentModeCommand.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/1/26.
//
//  Type 16: Assignment Mode Command
//  Used by base stations to control the operation of other base stations.
//  Payload character: @

class AssignmentModeCommand: AISMessage {
    let nmeaSentence: AISNMEA0183Sentence
    let messageType: AISMessageType
    let mmsiNumber: MMSI
    
    let spare1: UInt8
    let destination1: MMSI
    let offset1: UInt16
    let increment1: UInt16
    
    var destination2: MMSI?
    var offset2: UInt16?
    var incrememt2: UInt16?
    
    
    init?(nmea: AISNMEA0183Sentence) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits
        
        guard let messageTypeBits: UInt8 = bits[0...5] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageTypeBits)) else { return nil }
        guard messageType.rawValue == 16 else { return nil }
        self.messageType = messageType
        
        guard let mmsiBits: UInt32 = bits[8...37] else { return nil }
        guard let mmsi = MMSI(value: mmsiBits) else { return nil }
        self.mmsiNumber = mmsi
        
        guard let spare1Bits: UInt8 = bits[38...39] else { return nil }
        self.spare1 = spare1Bits
        
        guard let destination1Bits: UInt32 = bits[40...69] else { return nil }
        guard let destination1 = MMSI(value: destination1Bits) else { return nil }
        self.destination1 = destination1
        
        guard let offset1Bits: UInt16 = bits[70...81] else { return nil }
        self.offset1 = offset1Bits
        
        guard let increment1Bits: UInt16 = bits[82...91] else { return nil }
        self.increment1 = increment1Bits
        
        if(bits.count > 96) { // 96 instead of 92 becuase according to the spec, 4 fill bits are inserted in messages where 1 station is addressed
            guard let destination2Bits: UInt32 = bits[92...121] else { return nil }
            guard let destination2 = MMSI(value: destination2Bits) else { return nil }
            self.destination2 = destination2
            
            guard let offset2Bits: UInt16 = bits[122...133] else { return nil }
            self.offset2 = offset2Bits
            
            guard let increment2Bits: UInt16 = bits[134...143] else { return nil }
            self.incrememt2 = increment2Bits
        }
        
    }
    
    
    
    func description() -> String {
        var rows: [String] = [
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Assigned MMSI:", "\(destination1.country) - \(destination1.description)"),
            row("Assignment:", assignmentDescription(offset: offset1, increment: increment1))
        ]

        // A single message can assign up to two stations, so the second station's rows are only listed when
        // present. A destination of 0 means the sender filled the block in without addressing anyone, so
        // it's skipped here even though the parsed values are still kept on the message.
        if let destination2 = destination2, let offset2 = offset2, let increment2 = incrememt2, destination2.value != 0 {
            rows.append(row("Assigned MMSI:", "\(destination2.country) - \(destination2.description)"))
            rows.append(row("Assignment:", assignmentDescription(offset: offset2, increment: increment2)))
        }

        return rows.joined(separator: "\n")
    }

    /// An increment of 0 means the station should report once in the assigned slot, so the increment is only shown when set.
    private func assignmentDescription(offset: UInt16, increment: UInt16) -> String {
        let assignment = "Slot Offset \(offset)"
        guard increment != 0 else { return assignment }
        return assignment + ", Increment \(increment)"
    }

    
}

