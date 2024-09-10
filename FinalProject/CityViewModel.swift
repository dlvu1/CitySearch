//
//  CityViewModel.swift
//  FinalProject
//
//  Created by Duyen Vu on 3/16/24.
//

import Foundation
import SwiftData

class CityViewModel: ObservableObject, Identifiable {
    @Published var isFavorite: Bool {
        didSet {
            if isFavorite {
                viewModel.addFavorite(city: city)
            } else {
                viewModel.removeFavorite(city: city)
            }
        }
    }
    var city: CityModel
    private var viewModel: DataViewModel

    init(city: CityModel, viewModel: DataViewModel) {
        self.city = city
        self.viewModel = viewModel
        self.isFavorite = viewModel.favoriteCities.contains(where: { $0.id == city.id })
    }

    var id: UUID {
        city.id
    }
    
    func getId() -> UUID {
        return city.id
    }
    
    var cityName: String { city.title }
    var cityDescription: String { city.summary }
    var cityFeature: String? { city.feature }
    var countryCode: String { city.countryCode }
    var cityElevation: String? { city.elevation.map { "Elevation: \($0) meters" } }
    var cityWikipediaUrl: String { city.wikipediaUrl }
    var cityThumbnailImg: String? { city.thumbnailImg }
    
    var lat: Double { city.lat }
    var lng: Double { city.lng }
}

extension DataViewModel {
    func addFavorite(city: CityModel) {
        if !favoriteCities.contains(where: { $0.id == city.id }) {
            favoriteCities.append(city)
            saveFavorites()
        }
    }

    func removeFavorite(city: CityModel) {
        favoriteCities.removeAll { $0.id == city.id }
        saveFavorites()
    }
}
