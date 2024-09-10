//
//  ContentView.swift
//  FinalProject
//
//  Created by Duyen Vu on 3/16/24.
//

import SwiftUI
import MapKit
import SwiftData

struct ContentView: View {
    @StateObject var viewModel: DataViewModel
    @State private var searchText = ""
    @State private var showCityDetail = false
    @State private var showAlert = false
    @State private var selectedCity: CityViewModel?
    
    init(viewModel: DataViewModel = DataViewModel(data: DataModel(cities: []))) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    TextField("Search Cities", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Search") {
                        performSearch()
                    }
                    .padding(.leading, 10)
                    .buttonStyle(.bordered)
                }
                .padding()
                
                if let cityVM = selectedCity {
                    Map(coordinateRegion: .constant(MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: cityVM.lat, longitude: cityVM.lng),
                        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                    )))
                    .frame(height: 500)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.top, 20)
                } else {
                    GlobeView(cities: viewModel.getCityViewModels())
                        .frame(height: 500)
                }
                
                Spacer()
                NavigationLink(destination: CityDetailView(viewModel: selectedCity ?? CityViewModel(city: CityModel(title: "", summary: "", feature: nil, countryCode: "", lat: 0, lng: 0, elevation: nil, wikipediaUrl: "", thumbnailImg: nil), viewModel: viewModel)), isActive: $showCityDetail) {
                    EmptyView()
                }
            }
            .alert("Please search for a city", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
            .navigationBarTitle("Explore the World")
            .toolbar {
                bottomToolbar
            }
        }
    }
    
    private func performSearch() {
        viewModel.fetchCities(query: searchText) { result in
            switch result {
            case .success(let cities):
                viewModel.updateCities(cities)
                if let firstCity = viewModel.getCityViewModels().first {
                    self.selectedCity = firstCity
                }
            case .failure(let error):
                print("Error fetching cities: \(error)")
            }
        }
    }

    
    @ToolbarContentBuilder
    var bottomToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            HStack {
                Spacer()
                
                NavigationLink(destination: SavedCitiesView(viewModel: viewModel)) {
                    HStack {
                        Image(systemName: "star")
                        Text("Saved Cities")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .foregroundColor(.black)
                    .bold()
                }
                
                Button(action: {
                    if selectedCity != nil {
                        self.showCityDetail = true
                    } else {
                        self.showAlert = true
                    }
                }) {
                    Text("View City Details")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .foregroundColor(.black)
                        .bold()
                }
                .alert("Please search for a city", isPresented: $showAlert) { // Alert definition
                    Button("OK", role: .cancel) { }
                }
            }
        }
    }
}

struct GlobeView: View {
    let cities: [CityViewModel]

    var body: some View {
        ZStack {
            Map(coordinateRegion: .constant(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 15, longitude: -75),
                span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100)
            )))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct CityDetailView: View {
    @ObservedObject var viewModel: CityViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text(viewModel.cityName)
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.isFavorite.toggle()
                    }) {
                        Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
                            .foregroundColor(viewModel.isFavorite ? .yellow : .gray)
                            .imageScale(.large)
                    }
                }
                
                if let imageUrl = viewModel.cityThumbnailImg, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(10)
                        case .failure:
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 350, height: 300)
                }
                
                Text(viewModel.cityDescription)
                    .font(.subheadline)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let feature = viewModel.cityFeature {
                    Text(feature)
                }
                
                Text("Country: \(viewModel.countryCode)")
                
                if let elevation = viewModel.cityElevation {
                    Text(elevation)
                }
                
                Link("Read more on Wikipedia", destination: URL(string: viewModel.cityWikipediaUrl)!)
            }
            .padding()
        }
        .navigationTitle("City Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SavedCitiesView: View {
    @ObservedObject var viewModel: DataViewModel

    var body: some View {
        List {
            ForEach(viewModel.favoriteCities, id: \.id) { city in
                NavigationLink(destination: CityDetailView(viewModel: CityViewModel(city: city, viewModel: viewModel))) {
                    Text(city.title)
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle("Saved Cities")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

