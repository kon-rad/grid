//
//  AddPathViewController.swift
//  grid
//
//  Created by Konrad Gnat on 2/21/21.
//

import UIKit
import Firebase
import FirebaseStorage

class AddPathViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    var geoSiteId: String = ""
    var isEdit: Bool = false
    var path: Path? = nil
    var documentID: String? = nil
    var db = Firestore.firestore()
    var pathId: String?
    var worldMapData: Data?
    var downloadURL: String?
    
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
        
        if (self.worldMapData != nil) {
            self.uploadMapData() {
                self.savePath()
            }
        } else {
            self.savePath()
        }
    }
    
    func onUpdate() {
        print("on update, path: ", self.path!)
        
        if (self.worldMapData != nil) {
            self.uploadMapData() {
                self.updatePath()
            }
        } else {
            self.updatePath()
        }
    }
    
    func savePath() {
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
            "geoSiteId": self.geoSiteId,
            "worldMapDownloadURL": self.downloadURL ?? ""
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
    
    func updatePath() {
        
        guard let name = nameTextField.text else {
            return
        }
        let description = descriptionTextField.text ?? ""
        
        let pathRef = db.collection("paths").document(self.path!.documentID)
        pathRef.updateData([
            "name": name,
            "description": description,
            "worldMapDownloadURL": self.downloadURL ?? ""
        ])
        self.path?.name = name
        self.path?.description = description
        self.path?.downloadURL = self.downloadURL
        delegate?.completedUpdate(path: self.path!)
    }
    
    func uploadMapData(completion: @escaping () -> Void) {
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()

        // Create a storage reference from our storage service
        let storageRef = storage.reference()

        var worldMapRef = storageRef.child("worldMaps/\(self.pathId)")

        // Upload the data to the path "worldMaps/pathId"
        let uploadTask = worldMapRef.putData(self.worldMapData, metadata: nil) { (metadata, error) in
          guard let metadata = metadata else {
            // Uh-oh, an error occurred!
            print("Error uploading worldmap data, error:", error)
            completion()
            return
          }
          // Metadata contains file metadata such as size, content-type.
          let size = metadata.size
          // You can also access to download URL after upload.
          worldMapRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
                print("downloadURL not available")
              // Uh-oh, an error occurred!
                completion()
              return
            }
            print("upload complete!!! *** download URL is ", downloadURL)
            self.downloadURL = downloadURL
            completion()
          }
        }
    }
    
    @IBAction func onCreateARPathPressed(_ sender: Any) {
        print("AddPathVC onCreateARPathPressed")
        let ARPathCreatorVC = self.storyboard?.instantiateViewController(withIdentifier: "ARPathCreatorVC") as! ARPathCreatorViewController
        ARPathCreatorVC.modalPresentationStyle = .fullScreen
        ARPathCreatorVC.delegate = self
        self.present(ARPathCreatorVC, animated: true, completion: nil)
    }
}

protocol AddPathViewControllerDelegate {
    func completedSaveOrUpdate()
    func completedUpdate(path: Path)
}

extension AddPathViewController: ARPathCreatorViewControllerDelegate {
    
    func completedARWorldMapCreation(worldMapData: Data) {
        self.worldMapData = worldMapData
        print("saved worldmap", self.worldMapData)
        dismiss(animated: true, completion: nil)
    }
}
