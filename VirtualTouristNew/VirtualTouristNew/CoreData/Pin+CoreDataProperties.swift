//
//  Pin+CoreDataProperties.swift
//  VirtualTouristNew
//
//  Created by bdoor on 1/25/19.
//  Copyright © 2019 UdacityHS. All rights reserved.
//

import Foundation
import CoreData


extension Pin {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin");
    }
    
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var photos: [Photo]?
    
    
    
    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photo)
    
    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)
    
    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)
    
    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photo)
    
}
