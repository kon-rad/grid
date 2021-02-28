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
    
    @IBOutlet weak var editButton: UIButton!
    
    var path: Path? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateData()
    }
    
    func updateData() {
        
        pathTitle.text = self.path?.name
        pathDescription.text = self.path?.description
        
    }
    
    @IBAction func onTouchEnterARPath(_ sender: Any) {
        print("touch enter ar path")
        let ARPathCreatorVC = self.storyboard?.instantiateViewController(withIdentifier: "ARPathCreatorVC") as! ARPathCreatorViewController
        ARPathCreatorVC.modalPresentationStyle = .fullScreen
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

