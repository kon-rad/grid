//
//  AddPathViewController.swift
//  grid
//
//  Created by Konrad Gnat on 2/21/21.
//

import UIKit
import Firebase

class AddPathViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    var geoSiteId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("add path VC loaded")
    }

    
    @IBAction func onCancel(_ sender: Any) {
        print("AddPathVC cancel pressed")
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onSave(_ sender: Any) {
        print("AddPathVC save pressed")
        let pathId = NSUUID().uuidString
        let creatorEmail = Auth.auth().currentUser?.email
        let creatorId = Auth.auth().currentUser?.uid
        guard let name = nameTextField.text else {
            return
        }
        let description = descriptionTextField.text ?? ""
        
        let db = Firestore.firestore()
        // Add a new document with a generated ID
        var ref: DocumentReference? = nil
        ref = db.collection("paths").addDocument(data: [
            "name": name,
            "pathId": pathId,
            "description": description,
            "creatorEmail": creatorEmail!,
            "creatorId": creatorId!,
            "geoSiteId": self.geoSiteId
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onCreateARPathPressed(_ sender: Any) {
        print("AddPathVC onCreateARPathPressed")
    }
}
