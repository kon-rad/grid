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
    var isEdit: Bool = false
    var path: Path? = nil
    var documentID: String? = nil
    var db = Firestore.firestore()
    var pathId: String?
    
    var delegate: AddPathViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("add path VC loaded")
        renderEditView()
        if (!self.isEdit) {
            self.pathId = NSUUID().uuidString
        } else {
            self.pathId = self.path?.pathId
        }
    }
    
    func renderEditView() {
        if (!self.isEdit) {
            return
        }
        self.nameTextField.text = self.path?.name
        self.descriptionTextField.text = self.path?.description
    }

    
    @IBAction func onCancel(_ sender: Any) {
        print("AddPathVC cancel pressed")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSave(_ sender: Any) {
        print("AddPathVC save pressed")
        if (self.isEdit) {
            onUpdate()
            return
        }
        let creatorEmail = Auth.auth().currentUser?.email
        let creatorId = Auth.auth().currentUser?.uid
        guard let name = nameTextField.text else {
            return
        }
        let description = descriptionTextField.text ?? ""
        
        // Add a new document with a generated ID
        var ref: DocumentReference? = nil
        ref = self.db.collection("paths").addDocument(data: [
            "name": name,
            "pathId": self.pathId!,
            "description": description,
            "creatorEmail": creatorEmail!,
            "creatorId": creatorId!,
            "geoSiteId": self.geoSiteId
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                self.documentID = ref!.documentID
            }
        }
        
        delegate?.completedSaveOrUpdate()
    }
    func onUpdate() {
        print("on update, path: ", self.path!)
        
        guard let name = nameTextField.text else {
            return
        }
        let description = descriptionTextField.text ?? ""
        
        let pathRef = db.collection("paths").document(self.path!.documentID)
        pathRef.updateData([
            "name": name,
            "description": description
        ])
        self.path?.name = name
        self.path?.description = description
        delegate?.completedUpdate(path: self.path!)
    }
    
    
    
    @IBAction func onCreateARPathPressed(_ sender: Any) {
        print("AddPathVC onCreateARPathPressed")
        let ARPathCreatorVC = self.storyboard?.instantiateViewController(withIdentifier: "ARPathCreatorVC") as! ARPathCreatorViewController
        ARPathCreatorVC.modalPresentationStyle = .fullScreen
        self.present(ARPathCreatorVC, animated: true, completion: nil)
    }
}

protocol AddPathViewControllerDelegate {
    func completedSaveOrUpdate()
    func completedUpdate(path: Path)
}
