//
//  ReviewView.swift
//  BookTraining
//
//  Created by Никита Котов on 15.12.2023.
//

import SwiftUI

struct ReviewView: View {
    
    @State private var showRatings = false
    @Binding var isDisplayed: Bool
    
    var restaurant: Restaurant
    
    var body: some View {
        ZStack {
            Image(uiImage: UIImage(data: restaurant.image)!)
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity)
                .ignoresSafeArea()
            
            Color.black
                .opacity(0.6)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
            
            HStack {
                Spacer()
                
                VStack {
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.3)) {
                            self.isDisplayed = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Spacer()
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Restaurant.Rating.allCases, id: \.self) { rating in
                    HStack(spacing: 15) {
                        Text(rating.emoji)
                            .font(.system(size: 52))
                        Text(rating.rawValue.capitalized)
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                    .opacity(showRatings ? 1 : 0)
                    .offset(x: showRatings ? 0 : 1000)
                    .animation(.bouncy.delay(Double(Restaurant.Rating.allCases.firstIndex(of: rating)!) * 0.5), value: showRatings)
                    .onTapGesture {
                        self.restaurant.rating = rating
                        self.isDisplayed = false
                    }
                }
            }
        }
        .onAppear {
            showRatings.toggle()
        }
    }
}

#Preview {
    ReviewView(isDisplayed: .constant(true), restaurant: (PersistenceController.testData?.first)!)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
