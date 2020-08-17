//
//  ParkingSpotViews.swift
//  MyHeroParking
//
//  Created by Eli Armstrong on 3/30/19.
//  Copyright © 2019 Eli Armstrong. All rights reserved.
//

import Foundation
import MapKit

class ParkingSpotViews: MKMarkerAnnotationView{
    override var annotation: MKAnnotation? {
        willSet {
            
            // 1
            guard let parking = newValue as? ParkingAnnotation else { return }
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 30)))
            mapsButton.setBackgroundImage(UIImage(named: "Maps-icon"), for: UIControl.State())
            rightCalloutAccessoryView = mapsButton
            
            let posterBtn = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 30)))
            posterBtn.setBackgroundImage(UIImage(named: "friends_icon"), for: UIControl.State())
            parking.parkingSpot.poster.image.getDataInBackground { (imageData, error) in
                if let imageData = imageData{
                    posterBtn.setBackgroundImage(UIImage(data: imageData), for: UIControl.State())
                    self.leftCalloutAccessoryView = posterBtn
                } else if let error = error{
                    print(error.localizedDescription)
                }
            }
            
            // 2
            markerTintColor = parking.markerTintColor
            glyphText = "P"
        }
    }
}
