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
        
        // todo: figure out how to zoom on user location
        print("did ask for auth")
        mapView.zoomToUserLocation()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("view did appear")
        self.renderNavigationBarItems()
    }
    
    @objc func renderNavigationBarItems() {
        print("render navigation bar items")
        // conditionally render login button or else Add button
        if Auth.auth().currentUser != nil {
//
//            let loginButton = self.navigationItem.rightBarButtonItem
            self.navigationItem.rightBarButtonItem = nil
           // code to stay signed in
//            self.navigationItem.rightBarButtonItems?.append(<#T##newElement: UIBarButtonItem##UIBarButtonItem#>)
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
        print("addSite clicked")
    }
    
    @objc func logOutTapped() {
        print("logout tapped")
        do {
            try Auth.auth().signOut()
        } catch {
            print("Already logged out")
        }
        self.renderNavigationBarItems()
    }
    
    @objc func logInTapped() {
        print("login tapped")
//        let storyB = UIStoryboard(name: "Main", bundle: nil)
//         let loginVC = storyB.instantiateViewController(withIdentifier:
//         "loginVC") as! LoginViewController
//        let loginVC = LoginViewController();
//         self.present(loginVC, animated: true, completion: nil)
//        loginVC.modalPresentationStyle = .fullScreen
        
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        loginVC.modalPresentationStyle = .fullScreen
        self.present(loginVC, animated: true, completion: nil)
    }
    
    // Mark: - Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("location manager did change auth called")
        mapView.showsUserLocation = status == .authorizedWhenInUse
    }
    
}
