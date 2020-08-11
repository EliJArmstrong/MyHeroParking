//
//  parkingAnnotation.swift
//  MyHeroParking
//
//  Created by Eli Armstrong on 3/24/19.
//  Copyright © 2019 Eli Armstrong. All rights reserved.
//

import Foundation
import MapKit
import Contacts

class ParkingAnnotation: NSObject, MKAnnotation {
    
    
    var parkingSpot: ParkingSpot
    var coordinate: CLLocationCoordinate2D
    var dibs: Bool

    var markerTintColor: UIColor  {
        switch dibs {
            case true:
                return .red
            case false:
                return .green
        }
    }
    
    init(spot: ParkingSpot) {
        self.coordinate = CLLocationCoordinate2D(latitude: spot.location.latitude, longitude: spot.location.longitude)
        self.dibs = spot.dibs
        self.parkingSpot = spot
    }
    
    var title: String? {
        return "Parking Spot"
    }
    
    // Annotation right callout accessory opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
//         [CNPostalAddressStreetKey: title!]
        let addressDict = [CNPostalAddressStreetKey: "Cool"]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "MapCordBtn"
        return mapItem
    }
    
    
}
