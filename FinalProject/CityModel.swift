//
//  CityModel.swift
//  FinalProject
//
//  Created by Duyen Vu on 3/16/24.
//

import Foundation
import SwiftData

struct GeoNamesResponse: Codable {
    let geonames: [CityModel]
}

struct CityModel: Identifiable, Codable {
    let id: UUID = UUID()
    let title: String
    let summary: String
    let feature: String?
    let countryCode: String
    let lat: Double
    let lng: Double
    let elevation: Int?
    let wikipediaUrl: String
    let thumbnailImg: String?
    
    enum CodingKeys: String, CodingKey {
        case title, summary, feature, countryCode, lat, lng, elevation, wikipediaUrl, thumbnailImg
    }
}
