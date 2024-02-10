//
//  RestaurantDetailView.swift
//  BookTraining
//
//  Created by Никита Котов on 13.12.2023.
//

import SwiftUI

struct RestaurantDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var context
    
    @State private var showReview = false
    @State private var showMap = false
    
    @Binding var currentView: String
    
    @ObservedObject var restaurant: Restaurant
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Image(uiImage: UIImage(data: restaurant.image) ?? UIImage())
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 445)
                    .clipped()
                    .overlay {
                        VStack {
                            HStack(alignment: .bottom) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(restaurant.name)
                                        .font(.custom("Nunito-Regular", size: 35, relativeTo: .largeTitle))
                                        .bold()
                                    
                                    Text(restaurant.type)
                                        .font(.system(.headline, design: .rounded))
                                        .padding(.all, 5)
                                        .background(Color.black)
                                }
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .bottomLeading)
                                .foregroundStyle(.white)
                                .padding()
                                
                                if let rating = restaurant.rating, !showReview {
                                    Text(rating.emoji)
                                        .font(.system(size: 50))
                                        .padding([.bottom, .trailing])
                                }
                            }
                        }
                        .animation(.easeInOut, value: restaurant.rating)
                    }
                
                Text(restaurant.summary)
                    .padding()
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("ADDRESS")
                            .font(.system(.headline, design: .rounded))
                        
                        Text(restaurant.location)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    
                    
                    VStack(alignment: .leading) {
                        Text("PHONE")
                            .font(.system(.headline, design: .rounded))
                        
                        Text(restaurant.phone)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                
                MapView(location: restaurant.location, showMap: $showMap)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding()
                    .onTapGesture {
                        withAnimation {
                            showMap.toggle()
                        }
                    }
                
                Button {
                    self.showReview.toggle()
                } label: {
                    Text("Rate it")
                        .font(.system(.headline, design: .rounded))
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
                .tint(.brown)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 25))
                .controlSize(.large)
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
        }
        .onAppear {
            currentView = "Detail"
        }
        .onDisappear {
            currentView = ""
        }
        .fullScreenCover(isPresented: $showMap) {
            MapView(location: restaurant.location, showMap: $showMap).edgesIgnoringSafeArea(.all)
        }
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }, label: {
                    Text("\(Image(systemName: "chevron.left"))")
                })
                .tint(.white)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    restaurant.isFavorite.toggle()
                } label: {
                    Image(systemName: restaurant.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundStyle(restaurant.isFavorite ? .yellow : .white)
                }

            }
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea()
        .overlay {
            self.showReview 
            ?
            ZStack {
                ReviewView(isDisplayed: $showReview, restaurant: restaurant)
                    .toolbar(.hidden)
            }
            : nil
        }
        .onChange(of: self.restaurant.isFavorite) { _ in
            if self.context.hasChanges {
                try? self.context.save()
            }
        } 
        .onChange(of: self.restaurant.rating) { _ in
            if self.context.hasChanges {
                try? self.context.save()
            }
        }
    }
}

#Preview {
    NavigationStack {
        RestaurantDetailView(currentView: .constant(""), restaurant: (PersistenceController.testData?.first)!)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
