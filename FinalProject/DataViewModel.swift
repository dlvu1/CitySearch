//
//  DataViewModel.swift
//  FinalProject
//
//  Created by Duyen Vu on 3/16/24.
//

import Foundation
import CoreLocation
import SwiftData

class DataViewModel: ObservableObject {
    private var data: DataModel
    @Published var favoriteCities: [CityModel] = []
    
    init(data: DataModel) {
        self.data = data
        loadFavorites()
    }
    
    func getCityViewModels() -> [CityViewModel] {
        return data.cities.map { CityViewModel(city: $0, viewModel: self) }
    }
    
    func updateCities(_ cities: [CityModel]) {
        self.data.cities = cities
    }
    
    func saveFavorites() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(favoriteCities) {
            UserDefaults.standard.set(encoded, forKey: "favoriteCities")
            print("Saved favorite cities to UserDefaults.")
        }
    }
    
    func loadFavorites() {
        if let savedCities = UserDefaults.standard.data(forKey: "favoriteCities") {
            let decoder = JSONDecoder()
            if let loadedCities = try? decoder.decode([CityModel].self, from: savedCities) {
                DispatchQueue.main.async {
                    self.favoriteCities = loadedCities
                    print("Loaded favorite cities from UserDefaults: \(self.favoriteCities.map { $0.title })")
                }
            } else {
                print("Failed to decode favorite cities.")
            }
        } else {
            print("No favorite cities data found in UserDefaults.")
        }
    }
}

extension DataViewModel {
    func fetchCities(query: String, completion: @escaping (Result<[CityModel], Error>) -> Void) {
        let urlString = "http://api.geonames.org/wikipediaSearchJSON?q=\(query)&maxRows=10&username=dlvu1&style=full"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                let geoNamesResponse = try decoder.decode(GeoNamesResponse.self, from: data)
                let cities = geoNamesResponse.geonames.map { geoName in
                    CityModel(title: geoName.title, summary: geoName.summary, feature: geoName.feature,
                              countryCode: geoName.countryCode, lat: geoName.lat, lng: geoName.lng,
                              elevation: geoName.elevation, wikipediaUrl: geoName.wikipediaUrl, thumbnailImg: geoName.thumbnailImg)
                }
                DispatchQueue.main.async {
                    completion(.success(cities))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

