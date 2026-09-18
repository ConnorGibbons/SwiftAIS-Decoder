//
//  DesignatedAreaCode.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/10/26.
//

/// Designated Area Code — the 10-bit jurisdiction half of the 16-bit application identifier carried by
/// message types 6, 8, 25, and 26. The other 6 bits are the Function Identifier (FI).
///
/// DAC 1 is international (ITU-R M.1371 Annex 5 for FI 0-9, IMO SN.1/Circ.289 for FI 10-63), and 10-999
/// are regional messages owned by the administration whose MID matches the DAC. That makes the DAC space
/// a superset of the MID space rather than a copy of it: DAC 0 is registered despite sitting outside the
/// allocation rules, and values that are neither registered nor valid MIDs (DAC 2, for one) show up in
/// real traffic. So this wraps the raw value instead of enumerating it — every 10-bit value decodes and
/// keeps its number, with naming layered on top.
///
/// Sources: ITU-R M.1371-5 Annex 5, IMO SN.1/Circ.289, IALA ASM register (https://www.iala.int/asm/).
struct DesignatedAreaCode: RawRepresentable, Equatable, Hashable {
    let rawValue: UInt16

    init(rawValue: UInt16) {
        self.rawValue = rawValue
    }

    static let international = DesignatedAreaCode(rawValue: 1)

    /// DACs with a registration in the IALA ASM register. Regional DACs that only ever name their
    /// administration are left out — `description` names those from the MID table instead.
    private static let registrants: [UInt16: String] = [
        0: "Zeni Lite Buoy Co., Ltd",
        1: "International (ITU/IMO)",
        200: "European inland waterways",
        219: "Denmark - Danish Maritime Authority",
        235: "United Kingdom - General Lighthouse Authorities",
        250: "Ireland - Commissioners of Irish Lights",
        265: "Sweden - Swedish Maritime Administration",
        316: "Canada - St. Lawrence Seaway",
        366: "United States - USCG / USACE / St. Lawrence Seaway",
        367: "United States - USCG RDC / USACE",
        412: "China - Maritime Safety Administration",
        421: "Sena and Vans Co., Ltd",
        710: "Brazil - PETROBRAS"
    ]

    /// Whether this DAC has a registration in the IALA ASM register.
    /// A registered DAC doesn't imply the DAC/FI pair itself is registered.
    var isRegistered: Bool {
        Self.registrants[rawValue] != nil
    }

    var description: String {
        if let registrant = Self.registrants[rawValue] { return registrant }
        // Regional DACs are keyed to the owning administration's MID, so anything left that's a valid MID
        // at least names the country, even without a registration of its own.
        if let areaCode = AreaCode(rawValue: rawValue) { return areaCode.description }
        return "Unregistered"
    }

}
