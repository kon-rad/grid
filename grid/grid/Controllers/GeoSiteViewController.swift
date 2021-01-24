//
//  GeoSiteViewController.swift
//  grid
//
//  Created by Konrad Gnat on 1/23/21.
//

import UIKit
import MapKit
import CoreLocation

class GeoSiteViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        print("did ask for auth")
        mapView.zoomToUserLocation()
    }
    
    // Mark: - Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("location manager did change auth called")
        mapView.showsUserLocation = status == .authorizedWhenInUse
    }
    
    @IBAction func didTapLoginButton() {
        print("didTap Login")
        if #available(iOS 13.0, *) {
            let vc = storyboard?.instantiateViewController(identifier: "loginView") as! LoginViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        } else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "loginView") as! LoginViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
        
    }
}
