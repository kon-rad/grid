//
//  PathViewController.swift
//  grid
//
//  Created by Konrad Gnat on 2/27/21.
//

import UIKit
import Firebase
import FirebaseStorage

class PathViewController: UIViewController {

    @IBOutlet weak var pathTitle: UILabel!
    @IBOutlet weak var pathDescription: UILabel!
    
    @IBOutlet weak var enterARPathButton: UIButton!
    @IBOutlet weak var notCreatedLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var startImageRef: UIImageView!
    @IBOutlet weak var startLabelRef: UILabel!
    @IBOutlet weak var endImageRef: UIImageView!
    @IBOutlet weak var endLabelRef: UILabel!
    @IBOutlet weak var startImageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var endImageActivityIndicator: UIActivityIndicatorView!
    
    var path: Path? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startImageActivityIndicator.isHidden = true
        endImageActivityIndicator.isHidden = true
        updateData()
        conditionallyDisplayEditButton()
    }
    
    func updateData() {
        pathTitle.text = self.path?.name
        pathDescription.text = self.path?.description
        if (self.path?.worldMapDownloadURL == "") {
            self.enterARPathButton.isHidden = true
        } else {
            self.notCreatedLabel.isHidden = true
        }
        if (self.path?.startImageDownloadURL != "") {
            self.startImageActivityIndicator.isHidden = false
            self.startImageActivityIndicator.startAnimating()
            self.downloadStartImage()
            self.startLabelRef.isHidden = false
        } else {
            self.startLabelRef.isHidden = true
        }
        if (self.path?.endImageDownloadURL != "") {
            self.endImageActivityIndicator.isHidden = false
            self.endImageActivityIndicator.startAnimating()
            self.downloadEndImage()
            self.endLabelRef.isHidden = false
        } else {
            self.endLabelRef.isHidden = true
        }
    }
    
    func downloadStartImage() {
        let storage = Storage.storage()
        let storageRef = storage.reference(withPath: "pathStartImage/\(self.path?.pathId ?? "")")
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
          if let error = error {
            print("Error downloading start image:", error)
          } else {
            self.startImageRef.image = UIImage(data: data!)
            self.startImageActivityIndicator.isHidden = true
            self.startImageActivityIndicator.stopAnimating()
          }
        }
    }
    func downloadEndImage() {
        let storage = Storage.storage()
        let storageRef = storage.reference(withPath: "pathEndImage/\(self.path?.pathId ?? "")")
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
          if let error = error {
            print("Error downloading end image:", error)
          } else {
            self.endImageRef.image = UIImage(data: data!)
            self.endImageActivityIndicator.isHidden = true
            self.endImageActivityIndicator.stopAnimating()
          }
        }
        
    }
    func conditionallyDisplayEditButton() {
        let currentUserId = Auth.auth().currentUser?.uid
        print("current user id", currentUserId!)
        if (currentUserId == path?.creatorId) {
            print("current user is author")
            // may need to do some logic
        } else {
            self.editButton.isHidden = true;
            self.deleteButton.isHidden = true;
        }
    }
    
    @IBAction func onTouchEnterARPath(_ sender: Any) {
        print("touch enter ar path")
        let ARPathCreatorVC = self.storyboard?.instantiateViewController(withIdentifier: "ARPathCreatorVC") as! ARPathCreatorViewController
        ARPathCreatorVC.modalPresentationStyle = .fullScreen
        // TODO: enable edit mode?
        ARPathCreatorVC.pathId = self.path?.pathId
        ARPathCreatorVC.isCreatingPath = false
        self.present(ARPathCreatorVC, animated: true, completion: nil)
    }
    
    @IBAction func onTouchEdit(_ sender: Any) {
        print("touch edit")
        let AddPathVC = self.storyboard?.instantiateViewController(withIdentifier: "AddPathVC") as! AddPathViewController
        AddPathVC.modalPresentationStyle = .fullScreen
        AddPathVC.path = self.path!
        AddPathVC.isEdit = true
        AddPathVC.startImageFromView = self.startImageRef.image
        AddPathVC.endImageFromView = self.endImageRef.image
        AddPathVC.delegate = self
        
        self.present(AddPathVC, animated: true, completion: nil)
    }
    @IBAction func onTouchDelete(_ sender: Any) {
        
        let alert = UIAlertController(title: "Delete Path?", message: "Once deleted, you will not be able to restore it.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:  { action in
            self.deletePath()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler:  { action in
            print("Delete of path was cancelled by user.")
        }))

        self.present(alert, animated: true)
    }
    
    func deletePath() {
        let db = Firestore.firestore()
        guard ((self.path?.pathId) != nil) else { return }
        db.collection("paths").whereField("pathId", isEqualTo: self.path?.pathId ?? "").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting document prior to delete: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    document.reference.delete()
                }
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func onTouchBackButton(_ sender: Any) {
        print("AddPathVC cancel pressed")
        dismiss(animated: true, completion: nil)
    }
}

extension PathViewController: AddPathViewControllerDelegate {
    func completedSaveOrUpdate() {}
    
    func completedUpdate(path: Path) {
        self.path = path
        self.updateData()
        dismiss(animated: true, completion: nil)
    }
}

