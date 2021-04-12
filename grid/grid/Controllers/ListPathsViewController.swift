//
//  ListPathsViewController.swift
//  grid
//
//  Created by Konrad Gnat on 2/21/21.
//

import UIKit
import Firebase
import FirebaseStorage

class ListPathsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var name: String = "GeoSite Paths"
    var createdByUser: String = "Created By 2"
    var geoSiteId: String = ""
    var creatorId: String = ""
    var items: [Path] = []
    let cellIdentifier = "PathCell"
    var delegate: ListPathsViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    var db = Firestore.firestore()
    
    @IBOutlet weak var addPathButton: UIButton!
    @IBOutlet weak var editPathButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var createdByLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = self.name
        createdByLabel.text = "Created by \(self.createdByUser)"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        conditionallyDisplayButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        displayListOfPaths()
    }
    
    func  conditionallyDisplayButtons() {
        let currentUserId = Auth.auth().currentUser?.uid
        if (currentUserId == creatorId) {
            print("current user is author")
        } else {
            self.addPathButton.isHidden = true;
            self.editPathButton.isHidden = true;
            self.deleteButton.isHidden = true;
        }
    }
    
    func displayListOfPaths() {
        self.items.removeAll()
        self.getAllPaths() {
            self.tableView.reloadData()
        }
    }
    
    func getAllPaths(completion: @escaping () -> Void) {
        self.db.collection("paths").whereField("geoSiteId", isEqualTo: self.geoSiteId).getDocuments { (snapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in snapshot!.documents {
                    let name = document.get("name") as! String
                    let description = document.get("description") as! String
                    let pathId = document.get("pathId") as! String
                    let creatorEmail = document.get("creatorEmail") as! String
                    let creatorId = document.get("creatorId") as! String
                    let documentID = document.documentID
                    let worldMapDownloadURL = document.get("worldMapDownloadURL") ?? ""
                    let startImageDownloadURL = document.get("startImageDownloadURL") ?? ""
                    let endImageDownloadURL = document.get("endImageDownloadURL") ?? ""
                    let path = Path(
                        name: name,
                        description: description,
                        geoSiteId: self.geoSiteId,
                        creatorEmail: creatorEmail,
                        creatorId: creatorId,
                        pathId: pathId,
                        documentID: documentID,
                        worldMapDownloadURL: worldMapDownloadURL as! String,
                        startImageDownloadURL: startImageDownloadURL as! String,
                        endImageDownloadURL: endImageDownloadURL as! String
                    )
                    self.items.append(path)
                    
                }
            }
            completion()
        }
    }
    
    @IBAction func onAddPath(_ sender: Any) {
        let AddPathVC = self.storyboard?.instantiateViewController(withIdentifier: "AddPathVC") as! AddPathViewController
        AddPathVC.modalPresentationStyle = .fullScreen
        AddPathVC.geoSiteId = self.geoSiteId
        AddPathVC.delegate = self
        self.present(AddPathVC, animated: true, completion: nil)
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        let EditGeoSiteVC = self.storyboard?.instantiateViewController(withIdentifier: "EditGeoSiteVC") as! EditGeoSiteViewController
        EditGeoSiteVC.modalPresentationStyle = .fullScreen
        EditGeoSiteVC.name = self.name
        EditGeoSiteVC.geoSiteId = self.geoSiteId
        EditGeoSiteVC.delegate = self
        
        delegate?.refreshSearch()
        self.present(EditGeoSiteVC, animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        for item in items {
            let storage = Storage.storage()
            let startImageRef = storage.reference(withPath: "pathStartImage/\(item.pathId )")
            
            startImageRef.delete() { error in
                if let error = error {
                    print("error deleting start image: ", error)
                } else {
                    print("Successfully deleted start image")
                }
            }
            let endImageRef = storage.reference(withPath: "pathEndImage/\(item.pathId )")
            
            endImageRef.delete() { error in
                if let error = error {
                    print("error deleting end image: ", error)
                } else {
                    print("Successfully deleted end image")
                }
            }
            let mapRefrence = storage.reference(withPath: "worldMaps/\(item.pathId)")
            mapRefrence.delete() { error in
                if let error = error {
                    print("error deleting worldMap: ", error)
                } else {
                    print("Successfully deleted worldMap")
                }
            }
        }
        
        db.collection("geosite")
            .whereField("id", isEqualTo: self.geoSiteId)
            .getDocuments() { (querySnapshot, error) in
                if let error = error {
                    print("Error occured while deleting geoSite: ", error)
                } else if querySnapshot!.documents.count != 1 {
                    print("error while deleting geosite: more than one document found with id: ", self.geoSiteId)
                } else {
                    let doc = querySnapshot!.documents.first
                    doc!.reference.delete()
                }
            }
        
        delegate?.refreshSearch()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onGoBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: UITableView Delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PathCell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! PathCell
        let pathItem = items[indexPath.row]
        
        cell.nameLabel?.text = pathItem.name
        cell.descriptionLabel?.text = pathItem.description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let subjectCell = tableView.cellForRow(at: indexPath as IndexPath) {
            print(indexPath, subjectCell)
            
            guard indexPath.item < self.items.count else {
                print("index out of range, Index: \(indexPath.item) items.count: \(self.items.count)")
                return
            }
            
            let PathVC = self.storyboard?.instantiateViewController(withIdentifier: "PathVC") as! PathViewController
            PathVC.modalPresentationStyle = .fullScreen
            PathVC.path = self.items[indexPath.item]
            
            self.present(PathVC, animated: true, completion: nil)
        }
    }
}

extension ListPathsViewController: EditGeoSiteViewControllerDelegate {
    func completeUpdate(name: String) {
        titleLabel.text = name
        self.name = name
    }
}

extension ListPathsViewController: AddPathViewControllerDelegate {
    func completedUpdate(path: Path) {
    }
    
    func completedSaveOrUpdate() {
        dismiss(animated: true, completion: nil)
    }
}

protocol ListPathsViewControllerDelegate {
    func refreshSearch()
}
