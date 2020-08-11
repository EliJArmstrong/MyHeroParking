//
//  ParkingSpot.swift
//  MyHeroParking
//
//  Created by Eli Armstrong on 3/24/19.
//  Copyright © 2019 Eli Armstrong. All rights reserved.
//

import Foundation
import Parse
import ParseLiveQuery

class ParkingSpot: PFObject, PFSubclassing{
    
    @NSManaged var location: PFGeoPoint
    @NSManaged var poster: PFUser
    @NSManaged var dibbsUser: PFUser?
    @NSManaged var dibbs: Bool
    
    
    static func parseClassName() -> String {
        return "ParkingSpot"
    }
    
    func saveParkingSpot(withCompletion completion: PFBooleanResultBlock?) {
        let spot = ParkingSpot()
        PFGeoPoint.geoPointForCurrentLocation { (point, error) in
            if let point = point {
                spot.location = point
                spot.poster = PFUser.current()!
                spot.dibbs = false
                spot.dibbsUser = nil
                spot.saveInBackground(block: completion)
            }
        }
    }
    
    func saveParkingSpot(atLocation location: CLLocationCoordinate2D, withCompletion completion: PFBooleanResultBlock?){
        let spot = ParkingSpot()
        spot.location = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
        spot.poster = PFUser.current()!
        spot.dibbs = false
        spot.saveInBackground(block: completion)
    }
}
