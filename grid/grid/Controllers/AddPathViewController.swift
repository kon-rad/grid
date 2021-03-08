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
    @IBOutlet weak var snapshotImageRefrence: UIImageView!
    
    var geoSiteId: String = ""
    var isEdit: Bool = false
    var path: Path? = nil
    var documentID: String? = nil
    var db = Firestore.firestore()
    var pathId: String?
    var worldMapData: Data?
    var downloadURL: String?
    var pathStartSnapshot: UIImage?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var delegate: AddPathViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("add path VC loaded")
        activityIndicator.isHidden = true
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
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
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
        
        activityIndicator.stopAnimating()
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
        self.path?.worldMapDownloadURL = self.downloadURL ?? ""
        
        activityIndicator.stopAnimating()
        delegate?.completedUpdate(path: self.path!)
    }
    
    func uploadMapData(completion: @escaping () -> Void) {
        guard self.worldMapData != nil else {
            completion()
            return
        }
        // TODO: add saving progress indicator
        // TODO: delete existing world map if updating
        
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()

        // Create a storage reference from our storage service
        let storageRef = storage.reference()

        let worldMapRef = storageRef.child("worldMaps/\(self.pathId ?? "")")

        // Upload the data to the path "worldMaps/pathId"
        worldMapRef.putData(self.worldMapData!, metadata: nil) { (metadata, error) in
          guard let metadata = metadata else {
            // Uh-oh, an error occurred!
            print("Eror uploading worldmap data, error:", error ?? " error not available")
            completion()
            return
          }
          // Metadata contains file metadata such as size, content-type.
          let size = metadata.size
          print("upload size: ", size)
          // You can also access to download URL after upload.
          worldMapRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
                print("downloadURL not available")
              // Uh-oh, an error occurred!
                completion()
              return
            }
            print("upload complete!!! *** download URL is ", downloadURL)
            self.downloadURL = downloadURL.absoluteString
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
//        self.pathStartSnapshot = snapshot
        print("saved worldmap", self.worldMapData ?? " worldMapData not available")
        dismiss(animated: true, completion: nil)
    }
}
