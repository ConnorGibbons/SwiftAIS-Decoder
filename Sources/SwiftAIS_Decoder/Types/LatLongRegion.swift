//
//  LatLongRegion.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/8/26.
//
//  Types 22 and 23 send 2 lat/ 2 longs that form a rectangular area.
//  Inputs are expected to be in 0.1 minutes and is therefore divided by 600 to get degrees.

public struct LatLongRegion {
    public let longitudeNE: Longitude
    public let latitudeNE: Latitude
    public let longitudeSW: Longitude
    public let latitudeSW: Latitude
    
    public init(longitudeNEMins: UInt32, latitudeNEMins: UInt32, longitudeSWMins: UInt32, latitudeSWMins: UInt32) {
        self.longitudeNE = Longitude(rawValue: longitudeNEMins, isTenths: true)
        self.latitudeNE = Latitude(rawValue: latitudeNEMins, isTenths: true)
        self.longitudeSW = Longitude(rawValue: longitudeSWMins, isTenths: true)
        self.latitudeSW = Latitude(rawValue: latitudeSWMins, isTenths: true)
    }
    
    public var description: String {
        "NE Corner: (Lat: \(latitudeNE.description), Long: \(longitudeNE.description)) SW Corner: (Lat: \(latitudeSW.description), Long: \(longitudeSW.description))"
    }
}


