//
//  MainView.swift
//  BookTraining
//
//  Created by Никита Котов on 19.12.2023.
//

import SwiftUI

struct MainView: View {
    
    @State private var selectedTabIndex = 0
    
    var body: some View {
        TabView(selection: $selectedTabIndex) {
            RestaurantListView()
                .tabItem {
                    Label("Favorities", systemImage: "tag.fill")
                }
                .tag(0)
            
            Text("Soon...")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .tabItem {
                    Label("Discover", systemImage: "wand.and.rays")
                }
                .tag(1)
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "square.stack")
                }
                .tag(2)
        }
        .tint(.orange)
        .onOpenURL(perform: { url in
            switch url.path {
            case "/OpenFavorites": selectedTabIndex = 0
            case "/OpenDiscover": selectedTabIndex = 1
            case "/NewRestaurant": selectedTabIndex = 0
            default: return
            }
        })
    }
}

#Preview {
    MainView()
}
