//
//  AddGeoSiteViewController.swift
//  grid
//
//  Created by Konrad Gnat on 2/6/21.
//

import UIKit
import MapKit
import Firebase
import GeoFire
import FirebaseCore
import FirebaseFirestore

class AddGeoSiteViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var zoomButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameTextField: UITextField!
    
    var user: User!
    let geoSiteRef = Database.database().reference(withPath: "geo-sites")
    let userRef = Database.database().reference(withPath: "online")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().addStateDidChangeListener { auth, user in
            guard let user = user else {
                self.dismiss(animated: true, completion: nil)
                return
            }
            self.user = User(authData: user)
            let currentUserRef = self.userRef.child(self.user.uid)
            currentUserRef.setValue(self.user.email)
            currentUserRef.onDisconnectRemoveValue()
        }
        
        mapView.showsUserLocation = true
        
        mapView.zoomToUserLocation()
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onZoomToLocation(_ sender: Any) {
        print("on zoom to location")
        mapView.zoomToUserLocation()
    }
    
    @IBAction func onSaveTapped(_ sender: Any) {
        let coordinate = mapView.centerCoordinate
        let id = NSUUID().uuidString
        let createdByUser = self.user.email
        guard let name = nameTextField.text else {
            return
        }
        print("saving name", name)
        
//        let geoSiteRef = self.geoSiteRef.child(name.lowercased())
        
        // create Geohash
        // Compute the GeoHash for a lat/lng point
        let location = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)

        let geohash = GFUtils.geoHash(forLocation: location)
        print("geohash", geohash)
        print("geohash type", type(of: geohash))

        let db = Firestore.firestore()
        // Add a new document with a generated ID
        var ref: DocumentReference? = nil
        ref = db.collection("geosite").addDocument(data: [
            "name": name,
            "geohash": geohash,
            "latitude": "\(coordinate.latitude)",
            "longitude": "\(coordinate.longitude)",
            "id": id,
            "createdByUser": createdByUser,
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        
        
        dismiss(animated: true, completion: nil)

//        let geoSiteObjc = GeoSite(name: name, geohash: geohash, lat: "\(coordinate.latitude)", lon: "\(coordinate.longitude)", id: id, createdByUser: createdByUser)
//
//        geoSiteRef.setValue(geoSiteObjc.toAnyObject())

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
