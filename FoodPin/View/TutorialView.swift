//
//  TutorialView.swift
//  BookTraining
//
//  Created by Никита Котов on 18.12.2023.
//

import SwiftUI

struct TutorialView: View {
    
    @State private var currentPage = 0
    
    @Environment(\.dismiss) var dismiss
    @AppStorage("hasViewedWalkthrough") var hasViewedWalkthrough: Bool = false

    let pageHeadings = ["CREATE YOUR OWN FOOD GUIDE", "SHOW YOU THE LOCATION", "DISCOVER GREAT RESTAURANTS"]
    let pageSubHeadings = [
        "Pin your favorite restaurants and create your own food guide", 
        "Search and locate your favorite restaurant on Map's",
        "Find restaurants shared by your friends and other foodies"
    ]
    let pageImages = ["onboarding-1", "onboarding-2", "onboarding-3"]
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .systemIndigo
        UIPageControl.appearance().pageIndicatorTintColor = .lightGray
    }
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(pageHeadings.indices, id: \.self) { index in
                    TutorialPage(image: pageImages[index], headline: pageHeadings[index], subHeadline: pageSubHeadings[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .automatic))
            .animation(.default, value: currentPage)
            
            VStack(spacing: 20) {
                Button {
                    if currentPage < pageHeadings.count - 1 {
                        currentPage += 1
                    } else {
                        hasViewedWalkthrough = true
                        dismiss()
                    }
                } label: {
                    Text(currentPage == pageHeadings.count - 1 ? "GET STARTED" : "NEXT")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .padding(.horizontal, 50)
                        .background(Color(.systemIndigo))
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                }
                
                if currentPage < pageHeadings.count - 1 {
                    Button {
                        hasViewedWalkthrough = true
                        dismiss()
                    } label: {
                        Text("Skip")
                            .font(.headline)
                            .foregroundStyle(Color(.darkGray))
                    }
                }
            }
            .padding(.bottom)
        }
    }
}

#Preview {
    TutorialView()
}

struct TutorialPage: View {

    let image: String
    let headline: String
    let subHeadline: String
    
    var body: some View {
        VStack(spacing: 70) {
            Image(image)
                .resizable()
                .scaledToFit()
            
            VStack(spacing: 10) {
                Text(headline)
                    .font(.subheadline)
                
                Text(subHeadline)
                    .font(.body)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding(.top)
    }
}
