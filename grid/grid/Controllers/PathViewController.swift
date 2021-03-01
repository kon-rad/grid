//
//  PathViewController.swift
//  grid
//
//  Created by Konrad Gnat on 2/27/21.
//

import UIKit
import Firebase

class PathViewController: UIViewController {

    @IBOutlet weak var pathTitle: UILabel!
    @IBOutlet weak var pathDescription: UILabel!
    
    @IBOutlet weak var enterARPathButton: UIButton!
    @IBOutlet weak var notCreatedLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    var path: Path? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateData()
    }
    
    func updateData() {
        pathTitle.text = self.path?.name
        pathDescription.text = self.path?.description
        if (self.path?.worldMapDownloadURL == "") {
            self.enterARPathButton.isHidden = true
        } else {
            self.notCreatedLabel.isHidden = true
        }
    }
    
    func  conditionallyDisplayEditButton() {
        let currentUserId = Auth.auth().currentUser?.uid
        //        guard let currentUserId = Auth.auth().currentUser.uid? else { return }
        print("current user id", currentUserId!)
        if (currentUserId == path?.creatorId) {
            print("current user is author")
            // may need to do some logic
        } else {
            self.editButton.isHidden = true;
        }
    }
    
    @IBAction func onTouchEnterARPath(_ sender: Any) {
        print("touch enter ar path")
        let ARPathCreatorVC = self.storyboard?.instantiateViewController(withIdentifier: "ARPathCreatorVC") as! ARPathCreatorViewController
        ARPathCreatorVC.modalPresentationStyle = .fullScreen
//        ARPathCreatorVC.delegate = self
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
        AddPathVC.delegate = self
        
        self.present(AddPathVC, animated: true, completion: nil)
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
