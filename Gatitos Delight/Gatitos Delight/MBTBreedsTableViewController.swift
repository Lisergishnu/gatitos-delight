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

struct MBTBreedCellModel {
    var id: String
    var name: String
    var country: String
}

class MBTBreedsTableViewController: UITableViewController {

    var breedCells: [MBTBreedCellModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        populateArrayOfBreeds()
    }
    
    
    // MARK: - Data Managment
    func populateArrayOfBreeds() {
        Alamofire.request("https://api.thecatapi.com/v1/breeds", headers: MBTCatAPIHeader.httpHeader).responseSwiftyJSON { response in
            guard let responseValue = response.result.value else {
                debugPrint("Couldn't get a proper API response.")
                return
            }
            
            for (_,breed):(String, JSON) in JSON(responseValue) {
                guard let id = breed["id"].string,
                    let name = breed["name"].string,
                    let country = breed["origin"].string else {
                        continue
                }
                let b = MBTBreedCellModel(id: id, name: name, country: country)
                self.breedCells.append(b)
            }
            
            self.tableView.reloadData()
            
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
}

