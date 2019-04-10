//
//  User.swift
//  MyHeroParking
//
//  Created by Eli Armstrong on 3/24/19.
//  Copyright © 2019 Eli Armstrong. All rights reserved.
//

import Foundation
import Parse

extension PFUser{
    @NSManaged var userLocation: PFGeoPoint
    @NSManaged var experincePoints: Int64
}
