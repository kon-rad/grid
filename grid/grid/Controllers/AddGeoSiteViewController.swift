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
    @IBOutlet weak var addressRef: UILabel!
    
    var user: User!
    let geoSiteRef = Database.database().reference(withPath: "geo-sites")
    let userRef = Database.database().reference(withPath: "online")
    var address: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.returnKeyType = UIReturnKeyType.done
        
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
    
    @IBAction func textFieldDoneEditing(sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onZoomToLocation(_ sender: Any) {
        print("on zoom to location")
        mapView.zoomToUserLocation()
    }
    
    @IBAction func onSaveTapped(_ sender: Any) {
        if (!self.validateFields()) {
            return;
        }
        let coordinate = mapView.centerCoordinate
        let id = NSUUID().uuidString
        let createdByUser = self.user.email
        let creatorId = Auth.auth().currentUser?.uid
        guard let name = nameTextField.text else {
            return
        }
        
        // create Geohash
        // Compute the GeoHash for a lat/lng point
        let location = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)

        let geohash = GFUtils.geoHash(forLocation: location)
        print("geohash", geohash)

        let db = Firestore.firestore()
        // Add a new document with a generated ID
        var ref: DocumentReference? = nil
        ref = db.collection("geosite").addDocument(data: [
            "name": name,
            "geohash": geohash,
            "latitude": "\(coordinate.latitude)",
            "longitude": "\(coordinate.longitude)",
            "address": address,
            "id": id,
            "createdByUser": createdByUser,
            "creatorId": creatorId
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSearchByAddress(_ sender: UIButton) {
        
        let SearchByAddressVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchByAddressVC") as! SearchByAddressViewController
        SearchByAddressVC.modalPresentationStyle = .popover
        SearchByAddressVC.delegate = self
        
        self.present(SearchByAddressVC, animated: true, completion: nil)
    }
    
    func validateFields() -> Bool {
        let title = "Please complete all required fields"
        var messages: [String] = []
        
        
        if (nameTextField.text == "") {
            messages.append("Geo Site Name")
        }
        
        if (messages.count == 0) {
            return true
        }
        let alert = UIAlertController(title: title, message: messages.joined(separator: "\n"), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))

        self.present(alert, animated: true)
        return false;
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

extension AddGeoSiteViewController: SearchByAddressViewControllerDelegate {
    func setGeoSiteAddress(address: String) {
        self.address = address
        self.addressRef.text = address
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
            else {
                print("No location found for address: ", address)
                return
            }
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
            self.mapView.setRegion(region, animated: true)
        }
    }
}
