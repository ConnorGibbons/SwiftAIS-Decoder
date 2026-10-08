//
//  AssignmentModeCommand.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/1/26.
//
//  Type 16: Assignment Mode Command
//  Used by base stations to control the operation of other base stations.
//  Payload character: @

public struct AssignmentModeCommand: AISMessage {
    public let nmeaSentence: AISNMEA0183Sentence
    public let messageType: AISMessageType
    public let mmsiNumber: MMSI
    
    public let spare1: UInt8
    public let destination1: MMSI
    public let offset1: UInt16
    public let increment1: UInt16
    
    public var destination2: MMSI?
    public var offset2: UInt16?
    public var increment2: UInt16?
    
    
    public init(nmea: AISNMEA0183Sentence) throws(AISDecodingError) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits

        let messageType: AISMessageType = try bits.read(0...5, "messageType")
        guard messageType.rawValue == 16 else { throw .unexpectedMessageType(messageType.rawValue, expected: [16]) }
        self.messageType = messageType

        let mmsiBits: UInt32 = try bits.read(8...37, "mmsiNumber")
        guard let mmsi = MMSI(value: mmsiBits) else { throw .invalidValue(field: "mmsiNumber", rawValue: UInt64(mmsiBits)) }
        self.mmsiNumber = mmsi

        self.spare1 = try bits.read(38...39, "spare1")

        let destination1Bits: UInt32 = try bits.read(40...69, "destination1")
        guard let destination1 = MMSI(value: destination1Bits) else { throw .invalidValue(field: "destination1", rawValue: UInt64(destination1Bits)) }
        self.destination1 = destination1

        self.offset1 = try bits.read(70...81, "offset1")
        self.increment1 = try bits.read(82...91, "increment1")

        if(bits.count > 96) { // 96 instead of 92 becuase according to the spec, 4 fill bits are inserted in messages where 1 station is addressed
            let destination2Bits: UInt32 = try bits.read(92...121, "destination2")
            guard let destination2 = MMSI(value: destination2Bits) else { throw .invalidValue(field: "destination2", rawValue: UInt64(destination2Bits)) }
            self.destination2 = destination2

            self.offset2 = try bits.read(122...133, "offset2")
            self.increment2 = try bits.read(134...143, "increment2")
        }
        
    }
    
    
    
    public func description() -> String {
        var rows: [String] = [
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Assigned MMSI:", "\(destination1.country) - \(destination1.description)"),
            row("Assignment:", assignmentDescription(offset: offset1, increment: increment1))
        ]

        // A single message can assign up to two stations, so the second station's rows are only listed when
        // present. A destination of 0 means the sender filled the block in without addressing anyone, so
        // it's skipped here even though the parsed values are still kept on the message.
        if let destination2 = destination2, let offset2 = offset2, let increment2 = increment2, destination2.value != 0 {
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

