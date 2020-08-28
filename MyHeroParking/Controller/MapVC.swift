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

    @IBOutlet weak var mapView: MKMapView! // The map the user sees
    
    let locationManager = CLLocationManager() // Helps the app with phone GPS and map data
    let regionInMeters: Double = 500 // The size of the map to be displayed
    
    var follow = true // a bool to help with development. If false then the map will not follow the user
    var dropPin = false // if this is true then wherever the map is touch a pin will drop there.
    
    var parkingSpots = [ParkingSpot]() // an array of parking spots to be displayed on the map
    var dibsSpot: ParkingSpot? // keeps track of the spot the user dibs
    var selectedSpot: ParkingSpot? // keep track of the spot the user selected on the map. this might not be the dibs spot.
    
    var subscriber: ParseLiveQuery.Client! // this creates a link to get notified when something happens to a spot near by
    var subscription: Subscription<PFObject>? // Help with the link to get notified when a spot is created, deleted, or changed
    
    
    // Code that is executed before the view is shown to the user.
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.register(ParkingSpotViews.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        checkLocationServices()
        startListener()
    }
    
    /// Starts the link to get notified when a spot is created, deleted, or changed.
    func startListener(){
        subscriber = ParseLiveQuery.Client()
        subscription = subscriber.subscribe(ParkingSpot.query()!.whereKeyExists("dibs"))
        
        _ = subscription?.handleEvent({ (_, event) in
            switch event {
            default:
                    print("this happen: \(event)" )
                    self.getParkingSpotData()
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
    
    /// Get the data for near by parking spots and stores them in the parkingSpots array
    func getParkingSpotData(){
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
    
    
    /// Adds the annotations based of the parking spots passed into the function via a parking spot array.
    /// - Parameter parkingSpots: parking spot array to get geo data
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
    
    
    
    
    /// This function is called when the user hits the drop spot button
    /// - Parameter sender: The object that sent called the function
    /// - Note: button image from --> <a href="https://www.freepik.com/vectors/button">Button vector created by starline - www.freepik.com</a>
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
    
    
    /// Used to test the app. this function will make the app scrollable and zoomable based of the follow variable.
    /// - Parameter sender: the button that called this function
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
    
    /// The action that happens when the nil button is pressed. In this case the dibsSpot is set to nil when touched.
    @IBAction func nilBtnHit(_ sender: Any) {
        self.dibsSpot = nil
    }
    
    
    /// Allows for a spot to be dropped by touching an area of the map
    /// - Parameter sender: the button that called the app.
    @IBAction func dropPin(_ sender: UITapGestureRecognizer) {
        
        if(dropPin){
            let touchPoint = sender.location(in: mapView)
            let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let newSpot = ParkingSpot()
            newSpot.saveParkingSpot(atLocation: touchMapCoordinate) { (success, error) in
                if let error = error {
                    print("Well sh*t!! 💩")
                    print(error.localizedDescription)
                } else{
                    print("Awesome we were able to use long press to drop a pin")
                    self.getParkingSpotData()
                }
            }
        }
    }
    
    
    /// changes  the color of a button to indicate if the action behind the button is on or off
    /// - Parameter sender: the button
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
    
    
    /// Sets up the  location manager
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    /// When this function is called the map is set to be centered on the user
    func centerViewOnUser(){
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    /// Checks to see if the location services access is allowed by the user
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
        } else{
            // Tell user that their location is services is off.
        }
    }
    
    
    /// Check the authorization Status of location services allowed by the user.
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

    
    /// The function get the time of the server
    /// - Parameter completion: the data returned from a success or error from getting the data from the server
    /// - Returns: the time if getting the data was a success or an error from there was a problem
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
    
    
    /// Notifies the view controller that a segue is about to be performed.
    /// - Parameters:
    ///   - segue: The segue object containing information about the view controllers involved in the segue.
    ///   - sender: The object that initiated the segue. You might use this parameter to perform different actions based on which control (or other object) initiated the segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFriendVC"{
            let friendVC = segue.destination as? FriendsVC
            friendVC?.friend = selectedSpot?.poster
        }
    }

}



// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

extension MapVC: CLLocationManagerDelegate{
    
    
    /// Tells the delegate that new location data is available.
    /// - Parameters:
    ///   - manager: The location manager object that generated the update event.
    ///   - locations: An array of CLLocation objects containing the location data. This array always contains at least one object representing the current location. If updates were deferred or if multiple locations arrived before they could be delivered, the array may contain additional entries. The objects in the array are organized in the order in which they occurred. Therefore, the most recent location update is at the end of the array.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (follow) {
            guard let location = locations.last else {return}
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    /// Tells the delegate its authorization status when the app creates the location manager and when the authorization status changes.
    /// - Parameters:
    ///   - manager: The location manager object reporting the event.
    ///   - status: The authorization status for the app.
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
        getParkingSpotData()
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
        
        // checks to see which accessory view is the button is pressed
        if control == view.rightCalloutAccessoryView {
            let location = view.annotation as! ParkingAnnotation
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            location.mapItem().openInMaps(launchOptions: launchOptions)
        } else if control == view.leftCalloutAccessoryView{
            let parkingAnno = view.annotation as! ParkingAnnotation
            let button = view.leftCalloutAccessoryView as? UIButton
            parkingAnno.parkingSpot.poster.image.getDataInBackground { (imageData, error) in
                if let imageData = imageData {
                    button?.setBackgroundImage(UIImage(data: imageData), for: UIControl.State())
                } else if let error = error{
                    print(error.localizedDescription)
                }
            }
            if parkingAnno.parkingSpot.poster.objectId == PFUser.current()?.objectId{
                // move to the tab bar 1 index
                tabBarController?.selectedIndex = 1
            } else{
                // move to the selected (user that droped the spots) profile.
                self.selectedSpot = parkingAnno.parkingSpot
                performSegue(withIdentifier: "toFriendVC", sender: nil)
            }
            print("😜 left control 🤪")
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
            } else{
                self.selectedSpot = parkingAnno.parkingSpot
            }
        }
        
        print(parkingSpots.count)

    }
    
    
    /// Creates a button that can be clicked to delete a parking spot
    /// - Returns: a UI button
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
    
    
    /// Deletes the spot that is connected to the selectedSpot variable
    @objc func deleteSpot(){
        self.selectedSpot?.deleteInBackground(block: { (success, error) in
            if let error = error{
                print(error.localizedDescription)
            } else{
                print("deleted spot")
            }
        })
    }
    
    
    /// Creates a undibs button that is used in the parking anno
    /// - Returns: A UIButton
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
    
    
    /// When this function is called the spot the user has dibs is undibs
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


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

extension MKMapView {
    
    
    /// Gets the top left coordinate of the map that is on the screen
    /// - Returns: a 2D coordinate
    func topLeftCoordinate() -> CLLocationCoordinate2D {
        return convert(.zero, toCoordinateFrom: self)
    }
    
    
    /// Gets the bottom right coordinate of the map that is on the screen
    /// - Returns: a 2D coordinate
    func bottomRightCoordinate() -> CLLocationCoordinate2D {
        
        var twoDCoordinate = CLLocationCoordinate2D()
        
        DispatchQueue.main.async {
            twoDCoordinate = self.convert(CGPoint(x: self.frame.width, y: self.frame.height), toCoordinateFrom: self)
        }
        return twoDCoordinate
    }
}



