//
//  SimpleList.swift
//  BookTraining
//
//  Created by Никита Котов on 11.12.2023.
//

import SwiftUI

struct RestaurantListView: View {
    @Environment(\.managedObjectContext) var context
    @AppStorage("hasViewedWalkthrough") var hasViewedWalkthrough: Bool = false
    @State private var currentView: String = ""
    
    @FetchRequest(entity: Restaurant.entity(), sortDescriptors: [])
    var restaurants: FetchedResults<Restaurant>
    
    @State private var showNewRestaurant = false
    @State private var searchText = ""
    @State private var showWalkthrough = false
    
    var body: some View {
        NavigationStack {
            List {
                if restaurants.count == 0 {
                    Image("emptydata")
                        .resizable()
                        .scaledToFit()
                } else {
                    ForEach(restaurants.indices, id: \.self) { index in
                        ZStack(alignment: .leading) {
                            NavigationLink(destination: RestaurantDetailView(currentView: $currentView, restaurant: restaurants[index])) {
                                EmptyView()
                            }
                            .opacity(0)
                            
                            BasicTextImageRow(restaurant: restaurants[index])
                        }
                    }
                    .onDelete(perform: deleteRecord)
                    .listRowSeparator(.hidden)
                }
            }
            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                Button {
                    
                } label: {
                    Image(systemName: "heart.fill")
                }
                .tint(.green)
                
                Button {
                    
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .tint(.orange)
            }
            .listStyle(.plain)
            .navigationTitle("FoodPin")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                Button {
                    showNewRestaurant.toggle()
                } label: {
                    Image(systemName: "plus")
                        .tint(.primary)
                }
            }
            .toolbarBackground(Color.clear, for: .navigationBar)
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search restaurants...")
        .sheet(isPresented: $showNewRestaurant, content: {
            NewRestaurantView()
                .environment(\.managedObjectContext, context)
        })
        .sheet(isPresented: $showWalkthrough, content: {
            TutorialView()
        })
        .onChange(of: searchText) { searchText in
            
            let firstPredicate = NSPredicate(format: "name CONTAINS[c] %@", searchText)
            let secondPredicate = NSPredicate(format: "location CONTAINS[c] %@", searchText)
            
            let predicate = searchText.isEmpty ? NSPredicate(value: true) : NSCompoundPredicate(type: .or, subpredicates: [firstPredicate, secondPredicate])
            
            restaurants.nsPredicate = predicate
        }
        .onAppear {
            showWalkthrough = hasViewedWalkthrough ? false : true
        }
        .onOpenURL(perform: { url in
            switch url.path {
            case "/NewRestaurant": showNewRestaurant = true
            default: return
            }
        })
        .task {
            prepareNotification()
        }
    }
    
    private func deleteRecord(indexSet: IndexSet) {
        for index in indexSet {
            let itemToDelete = restaurants[index]
            context.delete(itemToDelete)
        }
        
        DispatchQueue.main.async {
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }
    
    private func prepareNotification() {
        if restaurants.count <= 0 {
            return
        }
        
        let randomNum = Int.random(in: 0 ..< restaurants.count)
        let suggestedRestaurant = restaurants[randomNum]
        
        let content = UNMutableNotificationContent()
        content.title = "Restaurant Recommendation"
        content.subtitle = "Try new food today"
        content.body = "I recommend you to check out \(suggestedRestaurant.name). The restaurant is one of your favorites. is located at \(suggestedRestaurant.location). Would you like to give it a try?"
        content.userInfo = ["phone": suggestedRestaurant.phone]
        content.sound = UNNotificationSound.default
        
        let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let tempFileURL = tempDirURL.appendingPathComponent("suggested-restaurant.jpg")
        
        if let image = UIImage(data: suggestedRestaurant.image as Data) {
            try? image.jpegData(compressionQuality: 1.0)?.write(to: tempFileURL)
            if let restaurantImage = try? UNNotificationAttachment(identifier: "restaurantImage", url: tempFileURL) {
                content.attachments = [restaurantImage]
            }
        }
        
        let categoryIdentifier = "booktraining.restaurantaction"
        let makeReservationAction = UNNotificationAction(identifier: "booktraining.makeReservation", title: "Reserve a table", options: [.foreground])
        let cancelAction = UNNotificationAction(identifier: "booktraining.cancel", title: "Later")
        let category = UNNotificationCategory(identifier: categoryIdentifier, actions: [makeReservationAction, cancelAction], intentIdentifiers: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = categoryIdentifier
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "booktraining.restaurantSuggestion", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

struct BasicTextImageRow: View {
    
    @State private var showOptions = false
    @State private var showError = false
    
    @ObservedObject var restaurant: Restaurant
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            Image(uiImage: UIImage(data: restaurant.image) ?? UIImage())
                .resizable()
                .frame(width: 120, height: 118)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            VStack(alignment: .leading) {
                Text(restaurant.name)
                    .font(.system(.title2, design: .rounded))
                
                Text(restaurant.type)
                    .font(.system(.body, design: .rounded))
                
                Text(restaurant.location)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.gray)
            }
            
            if restaurant.isFavorite {
                Spacer()
                
                Image(systemName: "heart.fill")
                    .foregroundStyle(.yellow)
                    .onTapGesture {
                        restaurant.isFavorite.toggle()
                    }
            }
        }
        .listRowSeparator(.hidden)
        .contextMenu(ContextMenu(menuItems: {
            Button(action: {
                self.showError.toggle()
            }, label: {
                HStack {
                    Text("Reserve a table")
                    Image(systemName: "phone")
                }
            })
            
            Button(action: {
                self.restaurant.isFavorite.toggle()
            }, label: {
                HStack {
                    Text(restaurant.isFavorite ? "Remove from favorites" : "Mark's favorite")
                    Image(systemName: "heart")
                }
            })
            
            Button(action: {
                self.showOptions.toggle()
            }, label: {
                Text("Share")
                Image(systemName: "square.and.arrow.up")
            })
        }))
        .alert("Not yet available", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text("Sorry, this feature is not available yet. Please retry later.")
        }
        .sheet(isPresented: $showOptions, content: {
            let defaultText = "Just checking in at \(restaurant.name)"
            
            if let imageToShare = UIImage(data: restaurant.image) {
                ActivityView(activityItems: [defaultText, imageToShare])
            } else {
                ActivityView(activityItems: [defaultText])
            }
        })
    }
}

struct FullImageRow: View {
    
    @State private var showOptions = false
    @State private var showError = false
    
    @Binding var restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Image(uiImage: UIImage(data: restaurant.image) ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(restaurant.name)
                        .font(.system(.title2, design: .rounded))
                    
                    Text(restaurant.type)
                        .font(.system(.body, design: .rounded))
                    
                    Text(restaurant.location)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.gray)
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                if restaurant.isFavorite {
                    Spacer()
                    
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.yellow)
                        .padding(.top, 5)
                        .onTapGesture {
                            withAnimation(.bouncy) { restaurant.isFavorite.toggle() }
                        }
                }
            }
        }
        .listRowSeparator(.hidden)
        .onTapGesture {
            showOptions.toggle()
        }
        .confirmationDialog("What do you want to do?", isPresented: $showOptions, titleVisibility: .visible) {
            
            Button("Reserve a table") {
                showError.toggle()
            }
            
            Button(restaurant.isFavorite ? "Remove from favorites" : "Mark as favorite") {
                withAnimation(.bouncy) { restaurant.isFavorite.toggle() }
            }
        }
        .alert("Not yet available", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text("Sorry, this feature is not available yet. Please retry later.")
        }
    }
}

#Preview {
    RestaurantListView()
}
