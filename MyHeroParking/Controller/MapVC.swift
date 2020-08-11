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
    var dibsSpot: ParkingSpot?
    var selectedSpot: ParkingSpot?
    
    var subscriber: ParseLiveQuery.Client!
    var subscription: Subscription<PFObject>?
    
    @IBAction func nilBtnHit(_ sender: Any) {
        self.dibsSpot = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.register(ParkingSpotViews.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        checkLocationServices()
        startListener()
    }
    
    func startListener(){
        subscriber = ParseLiveQuery.Client()
        subscription = subscriber.subscribe(ParkingSpot.query()!.whereKeyExists("dibs"))
        
        _ = subscription?.handleEvent({ (_, event) in
            switch event {
            default:
                    print("this happen: \(event)" )
                    self.getparkingSoptData()
                    var dibsFound = false
                    for spot in self.parkingSpots {
                        if spot.objectId == self.dibsSpot?.objectId{
                            dibsFound = true
                        }
                    }
                    if(dibsFound == false){
                        self.dibsSpot = nil
                    }
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
            if spot.dibsUser?.objectId == PFUser.current()?.objectId{
                dibsSpot = spot
                // print("Hello")
            }
        }
//        let annotationsToRemove = mapView.annotations.filter { (anno) -> Bool in
//            return !annotationArray.contains{ ($0.coordinate.longitude == anno.coordinate.longitude) && ($0.coordinate.latitude == anno.coordinate.latitude)}
//        }
        
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
                    print("Well shit!! 💩")
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



// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// This extension is used for dealing with the map View
extension MapVC: MKMapViewDelegate{
    
    
    /// Tells the delegate that the region displayed by the map view just changed.
    /// Dev note: When the map is moved either from user scroll or map following the user this function is called
    /// - Parameters:
    ///   - mapView: The map view whose visible region changed.
    ///   - animated: If true, the change to the new region was animated
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
    
    
    
    /// Tells the delegate that the user tapped one of the annotation view’s accessory buttons.
    /// - Parameters:
    ///   - mapView: The map view containing the specified annotation view.
    ///   - view: The annotation view whose button was tapped.
    ///   - control: The control that was tapped.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        
        // the right accessort view is the map button
        if control == view.rightCalloutAccessoryView {
            let location = view.annotation as! ParkingAnnotation
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            location.mapItem().openInMaps(launchOptions: launchOptions)
        }
    }
    
    
    
    /// Tells the delegate that one of its annotation views was selected.
    /// - Parameters:
    ///   - mapView: The map view containing the annotation view.
    ///   - view: The annotation view that was selected.
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        
        
        if let parkingAnno = view.annotation as? ParkingAnnotation{
            
            //print("Anno is poster is current user: \(parkingAnno.parkingSpot.poster.objectId == PFUser.current()?.objectId)")

            if(parkingAnno.parkingSpot.dibs == false && parkingAnno.parkingSpot.poster.objectId != PFUser.current()?.objectId){
                
                // Checks if this user currently has a dibs on a spot.
                if dibsSpot != nil{
                    dibsSpot?.dibs = false
                    dibsSpot?.dibsUser = nil
                    dibsSpot?.saveInBackground(block: { (success, error) in
                        if let error = error{
                            print("problem 1")
                            print(error.localizedDescription)
                        } else{
                            self.dibsSpot = parkingAnno.parkingSpot
                            parkingAnno.parkingSpot.dibs = true
                            parkingAnno.parkingSpot.dibsUser = PFUser.current()
                            parkingAnno.parkingSpot.saveInBackground { (success, error) in
                                if let error = error{
                                    print(error.localizedDescription)
                                    print("1")
                                } else{
                                    print("The Dibs was maked.")
                                }
                            }
                        }
                    })
                }else{
                    self.dibsSpot = parkingAnno.parkingSpot
                    parkingAnno.parkingSpot.dibs = true
                    parkingAnno.parkingSpot.dibsUser = PFUser.current()
                    parkingAnno.parkingSpot.saveInBackground { (success, error) in
                        if let error = error{
                            print(error.localizedDescription)
                            print("2")
                        } else{
                            print("The Dibs was maded.")
                        }
                    }
                }
            }
            
            if parkingAnno.parkingSpot.dibsUser?.objectId == PFUser.current()?.objectId {
                self.dibsSpot = parkingAnno.parkingSpot
                view.detailCalloutAccessoryView = createUndibsBtn()
            } else if parkingAnno.parkingSpot.poster.objectId == PFUser.current()?.objectId {
                self.selectedSpot = parkingAnno.parkingSpot
                view.detailCalloutAccessoryView = createDeleteParkingBtn()
            }
        }
        
        print(parkingSpots.count)

    }
    
    func createDeleteParkingBtn() -> UIButton{
        let width = 250
        let height = 250
        let deleteBtn = UIButton(frame: CGRect(x: 0, y: height - 35, width: width / 2 - 5, height: 35))
        deleteBtn.setTitle("Delete Parking Spot", for: .normal)
        deleteBtn.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        deleteBtn.layer.cornerRadius = 5
        deleteBtn.layer.borderWidth = 1
        deleteBtn.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) // There is a color is just black
        deleteBtn.addTarget(self, action: #selector(self.deleteSpot), for: .touchDown)
        return deleteBtn
    }
    
    @objc func deleteSpot(){
        self.selectedSpot?.deleteInBackground(block: { (success, error) in
            if let error = error{
                print(error.localizedDescription)
            } else{
                print("deleted spot")
            }
        })
    }
    
    func createUndibsBtn() -> UIButton{
        let width = 250
        let height = 250
        let unDibsBtn = UIButton(frame: CGRect(x: 0, y: height - 35, width: width / 2 - 5, height: 35))
        unDibsBtn.setTitle("Un-Dibs", for: .normal)
        unDibsBtn.backgroundColor = UIColor.darkGray
        unDibsBtn.layer.cornerRadius = 5
        unDibsBtn.layer.borderWidth = 1
        unDibsBtn.layer.borderColor = UIColor.black.cgColor
        unDibsBtn.addTarget(self, action: #selector(self.unDibsSpot), for: .touchDown)
        
        return unDibsBtn
    }
    
    @objc func unDibsSpot(){
        self.dibsSpot?.dibsUser = nil
        self.dibsSpot?.dibs = false
        self.dibsSpot?.saveInBackground(block: { (success, error) in
            if let error = error{
                print(error.localizedDescription)
            } else{
                print("Undibs happen")
                self.dibsSpot = nil
            }
        })
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



