//
//  MBTBreedsTableViewController.swift
//  Gatitos Delight
//
//  Created by Marco Benzi Tobar on 4/6/19.
//  Copyright © 2019 MBT. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON

/// A view controller that lists the whole list of breeds from the Cat API.
class MBTBreedsTableViewController: UITableViewController {

    /// Array containing all the breed descriptions returned by the service.
    var breedCells: [MBTCatAPIBreedModel] = []
    
    /// Notification name for setting the breed on the table.
    ///
    /// When recieved, the view controller will load the recieved breed name in the detail view. An example of how to emit the event:
    ///
    ///     let userInfo: [String:String] = [MBTBreedsTableViewController.BreedNameKey:"Breed Name"]
    ///     NotificationCenter.default.post(name: MBTBreedsTableViewController.SetBreed, object: nil, userInfo: userInfo)
    static let SetBreed = Notification.Name("setBreed")
    /// Constant string for identifing the breed name data when passing a SetBreed notification.
    /// - SeeAlso: MBTCatsRatingViewController.SetCat
    static let BreedNameKey: String = "breedName"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setBreed(notification:)), name: MBTBreedsTableViewController.SetBreed, object: nil)
        
        populateArrayOfBreeds()
    }
    
    
    // MARK: - Data Managment
    
    /// Fills the internal array with breed data from the Cat API.
    func populateArrayOfBreeds() {
        Alamofire.request("https://api.thecatapi.com/v1/breeds", headers: MBTCatAPIHeader.httpHeader).responseSwiftyJSON { response in
            guard let responseValue = response.result.value else {
                debugPrint("Couldn't get a proper API response.")
                return
            }
            
            for (_,breed):(String, JSON) in JSON(responseValue) {
                guard let id = breed["id"].string,
                    let name = breed["name"].string,
                    let country = breed["origin"].string,
                    let lifeSpan = breed["life_span"].string,
                    let temperament = breed["temperament"].string,
                    let description = breed["description"].string,
                    let weight = breed["weight"]["metric"].string else {
                        continue
                }
                let b = MBTCatAPIBreedModel(id: id,
                                          name: name,
                                          country: country,
                                          lifeSpan: lifeSpan,
                                          temperament: temperament,
                                          description: description,
                                          weight: weight)
                self.breedCells.append(b)
            }
            
            self.tableView.reloadData()
        }
    }
    
    /// Selects a breed from the table based on its name.
    ///
    /// - Parameter name: Name of the breed as returned by the Cat API.
    func selectBreed(with name:String) {
        loadViewIfNeeded()
        if let selectedBreedIndex = breedCells.firstIndex(where: {$0.name == name}) {
            tableView.selectRow(at: IndexPath(row: selectedBreedIndex, section: 0), animated: true, scrollPosition: UITableView.ScrollPosition.none)
        } else {
            debugPrint("Couldn't find breed \(name)")
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return breedCells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BreedCell", for: indexPath)
        
        cell.textLabel?.text = breedCells[indexPath.row].name
        cell.detailTextLabel?.text = breedCells[indexPath.row].country
        
        return cell
    }
    
    // MARK: - Transitions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBreedDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let breed = breedCells[indexPath.row]
                let controller = segue.destination as! MBTBreedDetailViewController
                
                controller.representedBreed = breed
            }
        }
    }
    
    // MARK: - Notification handling
    
    /// Objective-C compilant function that is binded to the NotificationCenter with the SetBreed Notification.
    ///
    /// - Parameter notification: Notification recieved.
    @objc func setBreed(notification: NSNotification) {
        guard let breedName = notification.userInfo?[MBTBreedsTableViewController.BreedNameKey] as? String else {
            return
        }
        selectBreed(with: breedName)
    }
}

