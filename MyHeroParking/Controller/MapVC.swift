//
//  ViewController.swift
//  MyHeroParking
//
//  Created by Eli Armstrong on 3/24/19.
//  Copyright © 2019 Eli Armstrong. All rights reserved.
//  Note: del

import UIKit
import MapKit
import CoreLocation
import Parse
import ParseLiveQuery

class MapVC: UIViewController{

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 500
    
    var follow = true
    var dropPin = false
    
    var parkingSpots = [ParkingSpot]()
    var dibbsSpot: ParkingSpot?
    
    var subscriber: ParseLiveQuery.Client!
    var subscription: Subscription<PFObject>?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.register(ParkingSpotViews.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        checkLocationServices()
        startListener()
    }
    
    func startListener(){
        subscriber = ParseLiveQuery.Client()
        subscription = subscriber.subscribe(ParkingSpot.query()!.whereKeyExists("dibbs"))
        
        _ = subscription?.handleEvent({ (_, event) in
            switch event {
            default:
                    print("this happen: \(event)" )
                    self.getparkingSoptData()
                break
            }
        })
    }
    
    func getparkingSoptData(){
        let query = ParkingSpot.query()
        let sw = PFGeoPoint(latitude:mapView.topLeftCoordinate().latitude, longitude:mapView.bottomRightCoordinate().longitude)
        let ne = PFGeoPoint(latitude: mapView.bottomRightCoordinate().latitude, longitude:mapView.topLeftCoordinate().longitude)
        query?.includeKeys(["poster"])
        query!.whereKey("location", withinGeoBoxFromSouthwest: sw, toNortheast: ne)
        query?.findObjectsInBackground(block: { (spots, error) in
            if let error = error{
                print(error.localizedDescription)
            } else{
                self.parkingSpots = spots as! [ParkingSpot]
                self.addAnnotations(parkingSpots: self.parkingSpots)
            }
        })
    }
    
    func addAnnotations(parkingSpots: [ParkingSpot]){
        
        var annotationArray = [MKAnnotation]()
        
        for spot in parkingSpots {
            annotationArray.append(ParkingAnnotation(spot: spot))
            if spot.dibbsUser?.objectId == PFUser.current()?.objectId{
                dibbsSpot = spot
                print("Hello")
            }
        }
        let annotationsToRemove = mapView.annotations.filter { (anno) -> Bool in
            return !annotationArray.contains{ ($0.coordinate.longitude == anno.coordinate.longitude) && ($0.coordinate.latitude == anno.coordinate.latitude)}
        }
        
        mapView.removeAnnotations( mapView.annotations )
        //mapView.removeAnnotations( annotationsToRemove )
        mapView.addAnnotations(annotationArray)
    }
    
    
    
    @IBAction func postSpot(_ sender: Any) {
        let spot = ParkingSpot()
        spot.saveParkingSpot { (success, error) in
            if let error = error{
                print(error.localizedDescription)
            }else{
                print("Spot Saved 😁")
            }
        }
        self.mapView.addAnnotation(ParkingAnnotation(spot: spot))
    }
    
    
    @IBAction func followMePressed(_ sender: Any) {
        self.follow = (follow) ? false : true
        if(follow){
            mapView.isScrollEnabled = false
            mapView.isZoomEnabled = false
        } else{
            mapView.isScrollEnabled = true
            mapView.isZoomEnabled = true
        }
    }
    
    @IBAction func dropPin(_ sender: UITapGestureRecognizer) {
        
        if(dropPin){
            let touchPoint = sender.location(in: mapView)
            let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let newSpot = ParkingSpot()
            newSpot.saveParkingSpot(atLocation: touchMapCoordinate) { (success, error) in
                if let error = error {
                    print("Well shit!!")
                    print(error.localizedDescription)
                } else{
                    print("Awesome we were able to use long press to drop a pin")
                    self.getparkingSoptData()
                }
            }
        }
    }
    
    @IBAction func enableButtonPressed(_ sender: Any) {
        dropPin = (dropPin) ? false : true
        if(dropPin){
            let btn = sender as! UIButton
            btn.tintColor = #colorLiteral(red: 0, green: 0.8640122414, blue: 0, alpha: 1)
        } else{
            let btn = sender as! UIButton
            btn.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        }
    }
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUser(){
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
        } else{
            // Tell user that there location is services is off.
        }
    }
    
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus(){
        case .authorizedAlways:
            fallthrough
        case .authorizedWhenInUse:
            // Do map stuff
            mapView.showsUserLocation = true
            centerViewOnUser()
            locationManager.startUpdatingLocation()
            PFGeoPoint.geoPointForCurrentLocation { (point, error) in
                if let point = point{
                    PFUser.current()?.userLocation = point
                    PFUser.current()?.saveInBackground(block: nil)
                }else{
                    print(error!.localizedDescription)
                }
            }
            break
        case .denied:
            // Show alert that permission was denied
            break
        case .restricted:
            // Show an alert
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        @unknown default:
            fatalError()
        }
    }

    
    func getServerDate(withCompletion completion: @escaping (Date?, Error?) -> ()){
        PFCloud.callFunction(inBackground: "getservertime", withParameters: nil) { (time, error) in
            if let error = error{
                print(error.localizedDescription)
                completion(nil, error)
            } else{
                let serverTime = time as! Int64
                completion(Date(timeIntervalSince1970: TimeInterval(serverTime/1000)), nil)
            }
        }
    }

}

extension MapVC: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (follow) {
            guard let location = locations.last else {return}
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension MapVC: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        getparkingSoptData()
    }
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        // 2
//        guard let annotation = annotation as? ParkingAnnotation else { return nil }
//        // 3
//        let identifier = "marker"
//        var view: MKMarkerAnnotationView
//        // 4
//        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//            as? MKMarkerAnnotationView {
//            dequeuedView.annotation = annotation
//            view = dequeuedView
//        } else {
//            // 5
//            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            view.canShowCallout = true
//            view.calloutOffset = CGPoint(x: -5, y: 5)
//            let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
//                                                    size: CGSize(width: 30, height: 30)))
//            mapsButton.setBackgroundImage(UIImage(named: "Maps-icon"), for: UIControl.State())
//            view.rightCalloutAccessoryView = mapsButton
//            
//        }
//        return view
//    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! ParkingAnnotation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let parkingAnno = view.annotation as! ParkingAnnotation
        
        
        if(parkingAnno.parkingSpot.dibbs == false && parkingAnno.parkingSpot.poster != PFUser.current()){
            
            if dibbsSpot != nil{
                dibbsSpot?.dibbs = false
                dibbsSpot?.dibbsUser = nil
                dibbsSpot?.saveInBackground(block: { (success, error) in
                    if let error = error{
                        print(error.localizedDescription)
                    } else{
                        self.dibbsSpot = parkingAnno.parkingSpot
                        parkingAnno.parkingSpot.dibbs = true
                        parkingAnno.parkingSpot.dibbsUser = PFUser.current()
                        parkingAnno.parkingSpot.saveInBackground { (success, error) in
                            if let error = error{
                                print(error.localizedDescription)
                                print("1")
                            } else{
                                print("The Dibbs was maked.")
                            }
                        }
                    }
                })
            }else{
                self.dibbsSpot = parkingAnno.parkingSpot
                parkingAnno.parkingSpot.dibbs = true
                parkingAnno.parkingSpot.dibbsUser = PFUser.current()
                parkingAnno.parkingSpot.saveInBackground { (success, error) in
                    if let error = error{
                        print(error.localizedDescription)
                        print("2")
                    } else{
                        print("The Dibbs was maked.")
                    }
                }
            }
            
        }

    }
        
    
}

extension MKMapView {
    
    func topLeftCoordinate() -> CLLocationCoordinate2D {
        return convert(.zero, toCoordinateFrom: self)
    }
    
    func bottomRightCoordinate() -> CLLocationCoordinate2D {
        
        var twoDCoordinate = CLLocationCoordinate2D()
        
        DispatchQueue.main.async {
            twoDCoordinate = self.convert(CGPoint(x: self.frame.width, y: self.frame.height), toCoordinateFrom: self)
        }
        return twoDCoordinate
    }
}



