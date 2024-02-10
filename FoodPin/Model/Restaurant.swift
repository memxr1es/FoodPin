//
//  Restaurant.swift
//  BookTraining
//
//  Created by Никита Котов on 13.12.2023.
//

import Combine
import CoreData

public class Restaurant: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var type: String
    @NSManaged var location: String
    @NSManaged var phone: String
    @NSManaged var summary: String
    @NSManaged var image: Data
    @NSManaged var isFavorite: Bool
    @NSManaged var ratingText: String?
}

extension Restaurant {
    enum Rating: String, CaseIterable {
        case awesome
        case good
        case okay
        case bad
        case terrible
        
        var emoji: String {
            switch self {
                case .awesome: return "😍"
                case .good: return "☺️"
                case .okay: return "🙂"
                case .bad: return "😒"
                case .terrible: return "😓"
            }
        }
    }
    
    
    var rating: Rating? {
        get {
            guard let ratingText = ratingText else { return nil }
            
            return Rating(rawValue: ratingText)
        }
        
        set {
            self.ratingText = newValue?.rawValue
        }
    }
}
