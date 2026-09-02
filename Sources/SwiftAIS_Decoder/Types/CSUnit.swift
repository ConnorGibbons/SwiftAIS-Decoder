//
//  CSUnit.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/2/26.
//
//  0 = SOTDMA (Self organized time division multiple access)
//  1 = CSTDMA (Carrier sense time division multiple access)

//  Describes the TDMA scheme a class B transmitter uses to determine when it transmits.
//
//  SOTDMA is more complex, and involves transmitters pre-allocating their next slot during their transmission.
//  Units are expected to build a slot map of which transmitters are using which slots, allowing them to determine when they can transmit next.
//
//  CSTDMA units wait until the beginning of a slot, and attempt to determine if the slot is unused by referencing background signal strength vs. at the beginning of the slot.
//  If the slot is empty (SOTDMA units have priority) the unit can transmit.
//
//  More here, since it's kinda neat: http://www.allaboutais.com/index.php/en/technical-info/transmission-types

enum CSUnit: UInt8 {
    case sotdma = 0
    case carrierSense = 1

    var description: String {
        switch self {
        case .carrierSense:
            "CSTDMA: Carrier Sense Time Division Multiple Access"
        case .sotdma:
            "SOTDMA: Self Organized Time Division Multiple Access"
        }
    }
    
}
