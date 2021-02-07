//
//  AddGeoSiteViewController.swift
//  grid
//
//  Created by Konrad Gnat on 2/6/21.
//

import UIKit
import MapKit

class AddGeoSiteViewController: UIViewController {

    @IBOutlet weak var zoomButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        saveButton.isEnabled = false
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onNameTextFieldChange(_ sender: Any) {
        saveButton.isEnabled = !nameTextField.isEmpty
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
