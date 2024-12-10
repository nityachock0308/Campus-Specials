//
//  Venues1+CoreDataProperties.swift
//  Places to Eat & Drink on Campus
//
//  Created by Chockalingam, Nitya on 10/12/2024.
//
//

import Foundation
import CoreData


extension Venues1 {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Venues1> {
        return NSFetchRequest<Venues1>(entityName: "Venues1")
    }

    @NSManaged public var venueName: String?
    @NSManaged public var building: String?
    @NSManaged public var lat: String?
    @NSManaged public var lon: String?
    @NSManaged public var descriptionText: String?
    @NSManaged public var opening_times: String?
    @NSManaged public var amenities: String?
    @NSManaged public var photos: String?
    @NSManaged public var last_modified: String?
    @NSManaged public var isLiked: Bool
    @NSManaged public var url: String?

}

extension Venues1 : Identifiable {

}
