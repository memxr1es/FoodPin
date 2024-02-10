//
//  NevRestaurantView.swift
//  BookTraining
//
//  Created by Никита Котов on 16.12.2023.
//

import SwiftUI

struct FormTextField: View {
    let label: String
    var placeholder: String = ""
    
    @Binding var value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label.uppercased())
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color(.darkGray))
            
            TextField(placeholder, text: $value)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .padding(.horizontal)
                .padding(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                }
            .   padding(.vertical, 10)
        }
        .toolbarBackground(Color.white, for: .navigationBar)
    }
    
}

struct FormTextView: View {
    
    let label: String
    
    @Binding var value: String
    
    var height: CGFloat = 200.0
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label.uppercased())
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color(.darkGray))
            
            TextEditor(text: $value)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .padding(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                }
                .padding(.top, 10)
        }
    }
}

enum PhotoSource: Identifiable {
    case photoLibrary
    case camera
    
    var id: Int {
        hashValue
    }
}

struct NewRestaurantView: View {
    
    @State var restaurantName: String = ""
    @State private var showPhotoOptions = false
    
    @State private var photoSource: PhotoSource?
    
    @ObservedObject private var restaurantFormViewModel: RestaurantFormViewModel
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) var context
    
    init() {
        let viewModel = RestaurantFormViewModel()
        viewModel.image = UIImage(named: "newphoto")!
        restaurantFormViewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Image(uiImage: restaurantFormViewModel.image)
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 200)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.bottom)
                        .onTapGesture {
                            self.showPhotoOptions.toggle()
                        }
                    
                    FormTextField(label: String(localized: "NAME", comment: "NAME"), placeholder: "Fill in the restaurant name...", value: $restaurantFormViewModel.name)
                    FormTextField(label: String(localized: "TYPE", comment: "TYPE"), placeholder: "Fill in the restaurant type...", value: $restaurantFormViewModel.type)
                    FormTextField(label: String(localized: "ADDRESS", comment: "ADDRESS"), placeholder: "Fill in the restaurant address...", value: $restaurantFormViewModel.location)
                    FormTextField(label: String(localized: "PHONE", comment: "PHONE"), placeholder: "Fill in the restaurant phone...", value: $restaurantFormViewModel.phone)
                    
                    FormTextView(label: String(localized: "DESCRIPTION", comment: "DESCRIPTION"), value: $restaurantFormViewModel.description, height: 100)
                }
                .padding()
            }
            .navigationTitle("New Restaurant")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        save()
                        dismiss()
                    } label: {
                        Text("Save")
                            .font(.headline)
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
        .confirmationDialog("Choose your photo source", isPresented: $showPhotoOptions) {
            Button {
                self.photoSource = .camera
            } label: {
                Text("Camera")
            }
            
            Button {
                self.photoSource = .photoLibrary
            } label: {
                Text("Photo Library")
            }
        }
        .fullScreenCover(item: $photoSource) { source in
            switch source {
                case .photoLibrary: ImagePicker(sourceType: .photoLibrary, selectedImage: $restaurantFormViewModel.image).ignoresSafeArea()
                case .camera: ImagePicker(sourceType: .camera, selectedImage: $restaurantFormViewModel.image).ignoresSafeArea()
            }
        }
    }
    
    private func save() {
        let restaurant = Restaurant(context: context)
        
        restaurant.name = restaurantFormViewModel.name
        restaurant.type = restaurantFormViewModel.type
        restaurant.location = restaurantFormViewModel.location
        restaurant.phone = restaurantFormViewModel.phone
        restaurant.image = restaurantFormViewModel.image.pngData()!
        restaurant.summary = restaurantFormViewModel.description
        restaurant.isFavorite = false
        
        do {
            try context.save()
            print("OK")
        } catch {
            print("Failed to save the records...")
            print(error.localizedDescription)
        }
    }
}

#Preview {
    NewRestaurantView()
        .environment(\.locale, .init(identifier: "ru"))
}
