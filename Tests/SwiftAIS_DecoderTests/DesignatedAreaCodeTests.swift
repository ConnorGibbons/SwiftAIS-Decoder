//
//  DesignatedAreaCodeTests.swift
//  SwiftAIS-Decoder
//

import Testing
@testable import SwiftAIS_Decoder

struct DesignatedAreaCodeTests {

    @Test func namesRegisteredAreaCodes() {
        #expect(DesignatedAreaCode(rawValue: 1) == .international)
        #expect(DesignatedAreaCode.international.description == "International (ITU/IMO)")

        // DAC 0 sits outside the allocation rules but carries a registration anyway
        #expect(DesignatedAreaCode(rawValue: 0).isRegistered)
        #expect(DesignatedAreaCode(rawValue: 0).description == "Zeni Lite Buoy Co., Ltd")

        #expect(DesignatedAreaCode(rawValue: 200).description == "European inland waterways")
        #expect(DesignatedAreaCode(rawValue: 366).isRegistered)
        #expect(DesignatedAreaCode(rawValue: 710).description == "Brazil - PETROBRAS")
    }

    @Test func namesUnregisteredRegionalAreaCodesFromTheirMID() {
        // Regional DACs are keyed to the owning administration's MID, so an unregistered one still names a country
        let norway = DesignatedAreaCode(rawValue: 257)
        #expect(norway.isRegistered == false)
        #expect(norway.description == AreaCode.norway257.description)
    }

    @Test func preservesAreaCodesThatAreNeitherRegisteredNorValidMIDs() {
        // DAC 2 shows up in real traffic despite being unallocated — the raw value has to survive
        let unallocated = DesignatedAreaCode(rawValue: 2)
        #expect(unallocated.rawValue == 2)
        #expect(unallocated.isRegistered == false)
        #expect(unallocated.description == "Unregistered")

        // The field is 10 bits, so the whole 0...1023 range has to decode
        #expect(DesignatedAreaCode(rawValue: 1023).rawValue == 1023)
    }
}
