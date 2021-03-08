//
//  ListPathsViewController.swift
//  grid
//
//  Created by Konrad Gnat on 2/21/21.
//

import UIKit
import Firebase

class ListPathsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var name: String = "GeoSite Paths"
    var createdByUser: String = "Created By 2"
    var geoSiteId: String = ""
    var creatorId: String = ""
    var items: [Path] = []
    let cellIdentifier = "PathCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    var db = Firestore.firestore()
    
    @IBOutlet weak var addPathButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var createdByLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ListPathsVC did load, creatorId:", creatorId)
        titleLabel.text = self.name
        createdByLabel.text = "Created by \(self.createdByUser)"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        conditionallyDisplayAddButton()
        displayListOfPaths()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        displayListOfPaths()
    }
    
    func  conditionallyDisplayAddButton() {
        let currentUserId = Auth.auth().currentUser?.uid
        print("current user id", currentUserId!)
        if (currentUserId == creatorId) {
            print("current user is author")
            // may need to do some logic
        } else {
            self.addPathButton.isHidden = true;
        }
    }
    
    func displayListOfPaths() {
        self.items.removeAll()
        self.getAllPaths() {
            print("loaded paths: ", self.items)
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
                    print(name, pathId, description)
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
        print("add path pressed")
        let AddPathVC = self.storyboard?.instantiateViewController(withIdentifier: "AddPathVC") as! AddPathViewController
        AddPathVC.modalPresentationStyle = .fullScreen
        AddPathVC.geoSiteId = self.geoSiteId
        AddPathVC.delegate = self
        self.present(AddPathVC, animated: true, completion: nil)
    }
    
    @IBAction func onGoBack(_ sender: Any) {
        print("go back pressed")
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
        print("canEditRowAt", indexPath)
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
            print("path clicked: ", self.items[indexPath.item])
            
            self.present(PathVC, animated: true, completion: nil)
        }
    }
    
}

extension ListPathsViewController: AddPathViewControllerDelegate {
    func completedUpdate(path: Path) {
    }
    
    func completedSaveOrUpdate() {
        dismiss(animated: true, completion: nil)
    }
}
