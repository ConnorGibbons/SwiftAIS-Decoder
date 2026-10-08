//
//  AtoNDimensionType.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 10/7/26.
//

/// Defines what Dimensions A and B represent.
/// Strictly for message type 28
public enum AtoNDimensionType: UInt8 {
    case standard = 0
    /// Position is the midpoint of the AtoN's structural area.
    /// A = radius (1 m steps, 0-511), B = height above sea level (0.1 m steps, 0-204.7).
    case heightAndStructuralArea = 1
    /// Position is the centre of the swing circle (Type of AtoN > 19 < 31).
    /// Radius = A (100 m steps, 0-51 100) + B (1 m steps, 0-100).
    case swingCircle = 2
    /// A = COG (0-359, 360-364 special values), B = SOG (1 knot steps, 0-59, 60 = unreported).
    case mobileVector = 3
    /// Position is the start of a polygon vertex.
    /// A = vertex sequence number (1-8, 0 = closes the polygon), B = total number of lines (0-8).
    /// It looks like technically you're supposed to construct the polygon yourself across multiple consecutive messages. For now, I'm not going to implement that because I feel this will rarely be used.
    case areaPolygon = 4
    /// Position is the centre of a circular area.
    /// Radius = A (1 m steps, 0-99) + B (100 m steps, 100-204 700).
    case areaCircle = 5
    /// Position is the start of a right-hand boundary line.
    /// A = orientation (degrees from true North, 0-359), B = length (10 m steps, 10-20 470).
    case boundaryLine1 = 6
    /// Position is the start of a line connected clockwise with a Type 6 at the same position to form a sector.
    /// A = orientation (degrees from true North, 0-359), B = length (10 m steps, 10-20 470).
    case areaSector = 7
    /// Position is the midpoint of a boundary line.
    /// A = orientation (degrees from true North, 0-359), B = length (10 m steps, 10-20 470).
    case boundaryLine2 = 8
    /// Position is the midpoint of one side of a quadrilateral, connected clockwise with a Type 8 or 12.
    /// A = orientation (degrees from true North, 0-359, 361 = not available), B = diagonal length (10 m steps, 10-20 470).
    case areaQuadrilateral = 9
    /// Position is the start of a right-hand boundary line.
    /// A = orientation (degrees from true North, 0-359), B = length (200 m steps, 0-409 400).
    case largeBoundaryLine1 = 10
    /// Position is the start of a line connected clockwise with a Type 10 at the same position to form a sector.
    /// A = orientation (degrees from true North, 0-359), B = length (200 m steps, 0-409 400).
    case largeAreaSector = 11
    /// Position is the midpoint of a boundary line.
    /// A = orientation (degrees from true North, 0-359), B = length (200 m steps, 0-409 400).
    case largeBoundaryLine2 = 12
    /// Position is the midpoint of one side of a quadrilateral, connected clockwise with a Type 12.
    /// A = orientation (degrees from true North, 0-359, 361 = not available), B = diagonal length (200 m steps, 0-409 400).
    case largeAreaQuadrilateral = 13
    case reserved = 14
    case reserved2 = 15

    public var description: String {
        switch self {
        case .standard:
            "Default AtoN Dimensions"
        case .heightAndStructuralArea:
            "AtoN Height and Structural Area"
        case .swingCircle:
            "AtoN Swing Circle"
        case .mobileVector:
            "Mobile AtoN Vector"
        case .areaPolygon:
            "AtoN Area-Polygon"
        case .areaCircle:
            "AtoN Area-Circle"
        case .boundaryLine1:
            "AtoN Boundary Line 1"
        case .areaSector:
            "AtoN Area-Sector"
        case .boundaryLine2:
            "AtoN Boundary Line 2"
        case .areaQuadrilateral:
            "AtoN Area-Quadrilateral"
        case .largeBoundaryLine1:
            "AtoN Large Boundary Line 1"
        case .largeAreaSector:
            "AtoN Large Area-Sector"
        case .largeBoundaryLine2:
            "AtoN Large Boundary Line 2"
        case .largeAreaQuadrilateral:
            "AtoN Large Area-Quadrilateral"
        case .reserved:
            "Reserved"
        case .reserved2:
            "Reserved"
        }
    }
}
