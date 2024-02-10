//
//  MapView.swift
//  BookTraining
//
//  Created by Никита Котов on 15.12.2023.
//

import SwiftUI
import MapKit

struct AnnotatedItem: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}

struct MapView: View {
    
    var location = ""
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.510357, longitude: -0.116773), span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0))
    @State private var annotatedItem: AnnotatedItem = AnnotatedItem(coordinate: CLLocationCoordinate2D(latitude: 51.510357, longitude: -0.116773))
    
    @Binding var showMap: Bool
    
    var body: some View {
        Map(coordinateRegion: $region, interactionModes: [], annotationItems: [annotatedItem]) { item in
            MapMarker(coordinate: item.coordinate, tint: .purple)
        }
        .task {
            convertAddress(location: location)
        }
        .overlay {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18))
                    .foregroundStyle(.orange)
                    .padding(10)
                    .background(Circle().fill(.white))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
            .padding(.top, 50)
            .opacity(showMap ? 1 : 0)
        }
    }
    
    private func convertAddress(location: String) {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(location) { placemarks, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let placemarks = placemarks,
                  let location = placemarks[0].location
            else { return }
            
            self.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.0015, longitudeDelta: 0.0015))
            self.annotatedItem = AnnotatedItem(coordinate: location.coordinate)
        }
    }
}

#Preview {
    MapView(location: "г. Рыбное, улица Большая, дом 8б", showMap: .constant(true))
}
