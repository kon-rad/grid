//
//  EditGeoSiteViewController.swift
//  grid
//
//  Created by Konrad Gnat on 4/3/21.
//

import UIKit
import FirebaseFirestore

class EditGeoSiteViewController: UIViewController {

    var name: String = ""
    var geoSiteId: String = ""
    
    @IBOutlet weak var nameTextField: UITextField!
    
    var delegate: EditGeoSiteViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameTextField.text = name
        
    }
    
    @IBAction func onSave(_ sender: UIButton) {
        
        if (!self.validateFields()) {
            return;
        }

        let db = Firestore.firestore()
        
        db.collection("geosite")
            .whereField("id", isEqualTo: self.geoSiteId)
            .getDocuments() { (querySnapshot, error) in
                if let error = error {
                    print("error while updating geosite: ", error)
                } else if querySnapshot!.documents.count != 1 {
                    print("error while updating geosite: more than one document found with id: ", self.geoSiteId)
                } else {
                    let document = querySnapshot!.documents.first
                    document!.reference.updateData([
                        "name": self.nameTextField.text!
                    ])
                }
            }
        
        delegate?.completeUpdate(name: self.nameTextField.text!)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textFieldDoneEditing(sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    func validateFields() -> Bool {
        let title = "Please complete all required fields"
        var messages: [String] = []
        
        
        if (nameTextField.text == "") {
            messages.append("GeoSite Name")
        }
        
        if (messages.count == 0) {
            return true
        }
        let alert = UIAlertController(title: title, message: messages.joined(separator: "\n"), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))

        self.present(alert, animated: true)
        return false;
    }
}

protocol EditGeoSiteViewControllerDelegate {
    func completeUpdate(name: String)
}
