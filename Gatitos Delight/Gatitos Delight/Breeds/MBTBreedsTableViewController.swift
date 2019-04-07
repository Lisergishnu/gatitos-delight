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

class MBTBreedsTableViewController: UITableViewController {

    var breedCells: [MBTBreedModel] = []
    
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
                    let country = breed["origin"].string,
                    let lifeSpan = breed["life_span"].string,
                    let temperament = breed["temperament"].string,
                    let description = breed["description"].string,
                    let weight = breed["weight"]["metric"].string else {
                        continue
                }
                let b = MBTBreedModel(id: id,
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBreedDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let breed = breedCells[indexPath.row]
                let controller = segue.destination as! MBTBreedDetailViewController
                
                controller.representedBreed = breed
            }
        }
    }
}
