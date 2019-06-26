//
//  ModelDataArray.swift
//  On The Map
//
//  Created by Bdoor on 26/04/1440 AH.
//  Copyright © 1440 badriah. All rights reserved.
//

import Foundation

class ModelDataArray {
    static let shared = ModelDataArray()
    
    var usersDataArray = [Any?]()
    
    private init() { }
}
