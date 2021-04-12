//
//  SearchByAddressViewController.swift
//  grid
//
//  Created by Konrad Gnat on 4/4/21.
//

import UIKit
import MapKit
import class Contacts.CNPostalAddressFormatter

class SearchByAddressViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var textInputRef: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var addresses: [String] = []
    let cellIdentifier = "AddressCell"
    
    var delegate: SearchByAddressViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    @IBAction func onSearch(_ sender: Any) {
        self.addresses = []
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = textInputRef.text

        let formatter = CNPostalAddressFormatter()
        formatter.style = .mailingAddress

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            let responseAddresses = response?.mapItems.compactMap { item -> String? in
                return item.placemark.postalAddress.flatMap {
                    formatter.string(from: $0).replacingOccurrences(of: "\n", with: ", ")
                }
            }
            self.addresses = responseAddresses ?? []
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AddressCell
            = tableView.dequeueReusableCell(
                withIdentifier: self.cellIdentifier, for: indexPath
            ) as! AddressCell
        
        let addressItem = addresses[indexPath.row]
        
        cell.label.text = addressItem
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.addresses.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if tableView.cellForRow(at: indexPath as IndexPath) != nil {
            guard indexPath.item < self.addresses.count else {
                print("index out of range, Index: \(indexPath.item) items.count: \(self.addresses.count)")
                return
            }
            
            let selectedAddr = addresses[indexPath.item]
            print("selected: ", selectedAddr)
            self.delegate?.setGeoSiteAddress(address: selectedAddr)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

protocol SearchByAddressViewControllerDelegate {
    func setGeoSiteAddress(address: String)
}
