//
//  InterrogationMessage.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 8/18/26.
//
//  Type 15: Interrogation message. Used to request 1 or 2 AIS stations send a particular message type.
//  Payload character: ?

class InterrogationMessage: AISMessage {
    let nmeaSentence: AISNMEA0183Sentence
    let messageType: AISMessageType
    let mmsiNumber: MMSI
    
    let spare_1: UInt8
    let interrogatedMMSI_1: MMSI
    let requestedMessageType_1: AISMessageType
    let slotOffset_1: UInt16
    
    /// Anything beyond this point is optional because the message can end at 88 bits.
    let spare_2: UInt8?
    let requestedMessageType_2: AISMessageType?
    let slotOffset_2: UInt16?
    
    let spare_3: UInt8?
    let interrogatedMMSI_2: MMSI?
    let requestedMessageType_3: AISMessageType?
    let slotOffset_3: UInt16?
    let spare_4: UInt8?
    
    
    init?(nmea: AISNMEA0183Sentence) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits
        
        guard let messageTypeBits: UInt8 = bits[0...5] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageTypeBits)) else { return nil }
        guard messageType.rawValue == 15 else { return nil }
        self.messageType = messageType
        
        guard let mmsiBits: UInt32 = bits[8...37] else { return nil }
        guard let mmsi = MMSI(value: mmsiBits) else { return nil }
        self.mmsiNumber = mmsi
        
        guard let spare1Bits: UInt8 = bits[38...39] else { return nil }
        self.spare_1 = spare1Bits
        
        guard let interrogatedMMSI1Bits: UInt32 = bits[40...69] else { return nil }
        guard let interrogatedMMSI_1 = MMSI(value: interrogatedMMSI1Bits) else { return nil }
        self.interrogatedMMSI_1 = interrogatedMMSI_1
        
        guard let requestedMessageType1Bits: UInt8 = bits[70...75] else { return nil }
        guard let requestedMessageType_1 = AISMessageType(rawValue: Int(requestedMessageType1Bits)) else { return nil }
        self.requestedMessageType_1 = requestedMessageType_1
        
        guard let slotOffset1Bits: UInt16 = bits[76...87] else { return nil }
        self.slotOffset_1 = slotOffset1Bits
        
        self.spare_2 = nil
        self.requestedMessageType_2 = nil
        self.slotOffset_2 = nil
        self.spare_3 = nil
        self.interrogatedMMSI_2 = nil
        self.requestedMessageType_3 = nil
        self.slotOffset_3 = nil
        self.spare_4 = nil
        
        guard let spare2Bits: UInt8 = bits[88...89] else { return }
        self.spare_2 = spare2Bits
        
        guard let requestedMessageType2Bits: UInt8 = bits[90...95] else { return }
        if(requestedMessageType2Bits != 0) { // If querying two stations for one type each, this field & slot offset will be 0
            guard let requestedMessageType_2 = AISMessageType(rawValue: Int(requestedMessageType2Bits)) else { return }
            self.requestedMessageType_2 = requestedMessageType_2
        }
        
        guard let slotOffset2Bits: UInt16 = bits[96...107] else { return }
        if(slotOffset2Bits != 0) {
            self.slotOffset_2 = slotOffset2Bits
        }
        
        guard let spare3Bits: UInt8 = bits[108...109] else { return }
        self.spare_3 = spare3Bits
        
        guard let interrogatedMMSI2Bits: UInt32 = bits[110...139] else { return }
        guard let interrogatedMMSI_2 = MMSI(value: interrogatedMMSI2Bits) else { return } // If there's this many bits in the message, the second MMSI is non-optional.
        self.interrogatedMMSI_2 = interrogatedMMSI_2
        
        guard let requestedMessageType3Bits: UInt8 = bits[140...145] else { return }
        guard let requestedMessageType_3 = AISMessageType(rawValue: Int(requestedMessageType3Bits)) else { return }
        self.requestedMessageType_3 = requestedMessageType_3
        
        guard let slotOffset3Bits: UInt16 = bits[146...157] else { return }
        self.slotOffset_3 = slotOffset3Bits
        
        guard let spare4Bits: UInt8 = bits[158...159] else { return }
        self.spare_4 = spare4Bits
    }
    
    func description() -> String {
        <#code#>
    }
    
    
}
