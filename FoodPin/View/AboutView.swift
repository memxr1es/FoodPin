//
//  AboutView.swift
//  BookTraining
//
//  Created by Никита Котов on 19.12.2023.
//

import SwiftUI

enum WebLink: String, Identifiable {
    case rateUs = "https://www.apple.com/ios/app-store"
    case feedback = "https://www.appcoda.com/contact"
    case twitter = "https://www.twitter.com/appcodamobile"
    case facebook = "https://www.facebook.com/appcodamobile"
    case instagram = "https://www.instagram.com/appcodadotcom"
    
    var id: UUID {
        UUID()
    }
}

struct AboutView: View {
    
    @State private var link: WebLink?
    
    var body: some View {
        NavigationStack {
            List {
                Image("about")
                    .resizable()
                    .scaledToFit()
                
                Section {
                    Link(destination: URL(string: WebLink.rateUs.rawValue)!, label: {
                        Label(String(localized: "Rate us to App Store", comment: "Rate us to App Store"), image: "store")
                            .tint(.primary)
                    })
                    
                    Label(String(localized: "Tell us your Feeback", comment: "Tell us your Feeback"), image: "chat")
                        .onTapGesture {
                            link = .feedback
                        }
                }
                
                Section {
                    Label(String(localized: "Twitter", comment: "Twitter"), image: "twitter")
                        .onTapGesture {
                            link = .twitter
                        }
                    
                    Label(String(localized: "Facebook", comment: "Facebook"), image: "facebook")
                        .onTapGesture {
                            link = .facebook
                        }
                    
                    Label(String(localized: "Instagram", comment: "Instagram"), image: "instagram")
                        .onTapGesture {
                            link = .instagram
                        }
                }
            }
            .listStyle(.grouped)
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.automatic)
            .sheet(item: $link) { item in
                if let url = URL(string: item.rawValue) {
                    SafariView(url: url)
                }
            }
        }
    }
}

#Preview {
    AboutView()
}
