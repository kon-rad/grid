//
//  GeoSiteViewController.swift
//  grid
//
//  Created by Konrad Gnat on 1/23/21.
//

import UIKit
import Firebase
import MapKit
import CoreLocation
import GeoFire
import FirebaseCore
import FirebaseFirestore

class GeoSiteViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var searchHereButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let geoSiteRef = Database.database().reference(withPath: "geo-sites")
    
    fileprivate let locationManager = CLLocationManager()
    
    let annotationViewIdentifier = "geositeAnnotation"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        mapView.delegate = self;
        mapView.showsUserLocation = true
        searchHereButton.isHidden = true
        
        mapView.zoomToUserLocation()
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.renderNavigationBarItems()
        locationManager.requestLocation()
        mapView.zoomToUserLocation()
    }
    
    @IBAction func searchHereButtonPressed(_ sender: Any) {
        let mapViewCoordinate = mapView.centerCoordinate
        self.showNearbyMarkers(latitude: mapViewCoordinate.latitude, longitude: mapViewCoordinate.longitude)
    }
    
    @objc func showNearbyMarkers(latitude: Double, longitude: Double) {
        print("coordinate user latitude", latitude)
        print("coordinate user longitude", longitude)
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        searchHereButton.isHidden = true
        
//      Find geosites within 500km, the geohash method is not very precise, so having a larger search area is needed
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let radiusInKilometers: Double = 500

        let db = Firestore.firestore()
        // Each item in 'bounds' represents a startAt/endAt pair. We have to issue
        // a separate query for each pair. There can be up to 9 pairs of bounds
        // depending on overlap, but in most cases there are 4.
        let queryBounds = GFUtils.queryBounds(forLocation: center,
                                              withRadius: radiusInKilometers)
        let queries = queryBounds.compactMap { (any) -> Query? in
            guard let bound = any as? GFGeoQueryBounds else { return nil }
            return db.collection("geosite")
                .order(by: "geohash")
                .start(at: [bound.startValue])
                .end(at: [bound.endValue])
        }
        
        
        var matchingDocs = [QueryDocumentSnapshot]()
        // Collect all the query results together into a single list
        func getDocumentsCompletion(snapshot: QuerySnapshot?, error: Error?) -> () {
            guard let documents = snapshot?.documents else {
                print("Unable to fetch snapshot data. \(String(describing: error))")
                return
            }
            print("documents", documents)

            for document in documents {
                if (document.data()["latitude"] != nil && document.data()["longitude"] != nil) {
                    
                    let lat = NSString(string: document.data()["latitude"] as! String).doubleValue
                    let lng = NSString(string: document.data()["longitude"] as! String).doubleValue
                    let name = document.data()["name"] as! String
                    let createdByUser = document.data()["createdByUser"] as! String
                    let id = document.data()["id"] as! String
                    let creatorId = document.data()["creatorId"] as! String
                     
                    let coordinates = CLLocation(latitude: lat, longitude: lng)
                    let centerPoint = CLLocation(latitude: center.latitude, longitude: center.longitude)
                    // We have to filter out a few false positives due to GeoHash accuracy, but
                    // most will match
                    let distance = GFUtils.distance(from: centerPoint, to: coordinates)
                    if distance <= radiusInKilometers {
                        matchingDocs.append(document)
                        // set new pin on map
                        let newAnnotation = GeoSiteAnnotation(
                            coordinate: coordinates.coordinate,
                            name: name,
                            createdByUser: createdByUser,
                            geoSiteId: id,
                            creatorId: creatorId
                        )
                        mapView.addAnnotation(newAnnotation)
                    }
                    print("matchingDocs post", matchingDocs)
                }
            }
        }
        for query in queries {
            query.getDocuments(completion: getDocumentsCompletion)
        }
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        UIApplication.shared.endIgnoringInteractionEvents()
        searchHereButton.isHidden = false
    }
    
    @objc func renderNavigationBarItems() {
        print("render navigation bar items")
        // conditionally render login button or else Add and Logout buttons
        if Auth.auth().currentUser != nil {
            print("user IS logged in")
            let logOut = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.logOutTapped))
            let addSite = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(self.addSiteTapped))
            self.navigationItem.rightBarButtonItems = [logOut, addSite]
        } else {
            print("user not logged in")
            let logIn = UIBarButtonItem(title: "Login/Sign Up", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.logInTapped))
            self.navigationItem.rightBarButtonItems = [logIn]
        }
    }
    
    @objc func addSiteTapped() {
        let addGeoSiteVC = self.storyboard?.instantiateViewController(withIdentifier: "addGeoSiteVC") as! AddGeoSiteViewController
        addGeoSiteVC.modalPresentationStyle = .fullScreen
        self.present(addGeoSiteVC, animated: true, completion: nil)
    }
    
    @objc func logOutTapped() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Already logged out")
        }
        self.renderNavigationBarItems()
    }
    
    @objc func logInTapped() {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        loginVC.modalPresentationStyle = .fullScreen
        self.present(loginVC, animated: true, completion: nil)
    }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.first {
        print("Found user's location: \(location)")
        let mUserLocation:CLLocation = locations[0] as CLLocation

        let center = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
        print("center", center)
        print("mUserLocation.coordinate.latitude", mUserLocation.coordinate.latitude)
        print("mUserLocation.coordinate.longitude", mUserLocation.coordinate.longitude)
        UIApplication.shared.endIgnoringInteractionEvents()
        self.showNearbyMarkers(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
    }
  }
    
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    mapView.showsUserLocation = status == .authorizedAlways
  }
  
  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    print("Monitoring failed for region with identifier: \(region!.identifier)")
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location Manager failed with the following error: \(error)")
  }
}

// MARK: MapView Delegate
extension GeoSiteViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        print("annotation mapView viewFor method called -------------------------- ", annotation)
        guard !annotation.isKind(of: MKUserLocation.self) else {
            // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
            return nil
        }
        let identifier = "geositeAnnotation"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(
          withIdentifier: identifier) as? MKMarkerAnnotationView {
          dequeuedView.annotation = annotation
          view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(
                annotation: annotation,
                reuseIdentifier: identifier)
            view.canShowCallout = true
            let goButton = UIButton(type: .system)
            goButton.frame = CGRect(x: 0, y: 0, width: 50, height: 23)
            goButton.setTitle("Enter", for: .normal)
            view.rightCalloutAccessoryView = goButton
        }
            
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("tapped call out")
        let geoSiteAnnotation = view.annotation as! GeoSiteAnnotation
        print("geoSiteAnnotation: ", geoSiteAnnotation)
        let ListPathsVC = self.storyboard?.instantiateViewController(withIdentifier: "ListPathsVC") as! ListPathsViewController
        ListPathsVC.modalPresentationStyle = .fullScreen
        ListPathsVC.name = geoSiteAnnotation.name
        ListPathsVC.createdByUser = geoSiteAnnotation.createdByUser
        ListPathsVC.geoSiteId = geoSiteAnnotation.geoSiteId
        ListPathsVC.creatorId = geoSiteAnnotation.creatorId
        self.present(ListPathsVC, animated: true, completion: nil)
    }
}
