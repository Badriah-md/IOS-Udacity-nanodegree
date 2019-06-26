//
//  Photo+CoreDataProperties.swift
//  VirtualTouristNew
//
//  Created by bdoor on 1/25/19.
//  Copyright © 2019 UdacityHS. All rights reserved.
//

import Foundation
import CoreData



extension Photo {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }
    
    @NSManaged public var photoID: String?
    @NSManaged public var image: Data?
    @NSManaged public var imageURL: String?
    @NSManaged public var photoTitle: String?
    @NSManaged public var pin: Pin?
    
}
