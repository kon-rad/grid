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

class GeoSiteViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    let geoSiteRef = Database.database().reference(withPath: "geo-sites")
    
    fileprivate let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        
        mapView.zoomToUserLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.renderNavigationBarItems()
        mapView.zoomToUserLocation()
    }
    
    @objc func showNearbyMarkers(latitude: Double, longitude: Double) {
        print("coordinate user latitude", latitude)
        print("coordinate user longitude", longitude)
//         Find cities within 50km of London
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let radiusInKilometers: Double = 0.5

        // Each item in 'bounds' represents a startAt/endAt pair. We have to issue
        // a separate query for each pair. There can be up to 9 pairs of bounds
        // depending on overlap, but in most cases there are 4.
        let queryBounds = GFUtils.queryBounds(forLocation: center,
                                              withRadius: radiusInKilometers)
        let queries = queryBounds.compactMap { (any) -> Query? in
            guard let bound = any as? GFGeoQueryBounds else { return nil }
            return db.collection("geo-sites")
                .order(by: "geohash")
                .start(at: [bound.startValue])
                .end(at: [bound.endValue])
        }

//        var matchingDocs = [QueryDocumentSnapshot]()
//        // Collect all the query results together into a single list
//        func getDocumentsCompletion(snapshot: QuerySnapshot?, error: Error?) -> () {
//            guard let documents = snapshot?.documents else {
//                print("Unable to fetch snapshot data. \(String(describing: error))")
//                return
//            }
//
//            for document in documents {
//                let lat = document.data()["lat"] as? Double ?? 0
//                let lng = document.data()["lng"] as? Double ?? 0
//                let coordinates = CLLocation(latitude: lat, longitude: lng)
//                let centerPoint = CLLocation(latitude: center.latitude, longitude: center.longitude)
//
//                // We have to filter out a few false positives due to GeoHash accuracy, but
//                // most will match
//                let distance = GFUtils.distance(from: centerPoint, to: coordinates)
//                if distance <= radiusInKilometers {
//                    matchingDocs.append(document)
//                }
//            }
//        }
//
//        // After all callbacks have executed, matchingDocs contains the result. Note that this
//        // sample does not demonstrate how to wait on all callbacks to complete.
//        for query in queries {
//            query.getDocuments(completion: getDocumentsCompletion)
//        }
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
    let mUserLocation:CLLocation = locations[0] as CLLocation

    let center = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
    print("center", center)
    print("mUserLocation.coordinate.latitude", mUserLocation.coordinate.latitude)
    print("mUserLocation.coordinate.longitude", mUserLocation.coordinate.longitude)
    self.showNearbyMarkers(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
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
