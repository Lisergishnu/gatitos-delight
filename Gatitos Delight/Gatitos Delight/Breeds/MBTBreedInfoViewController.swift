//
//  MBTBreedInfoViewController.swift
//  Gatitos Delight
//
//  Created by Marco Benzi Tobar on 4/7/19.
//  Copyright © 2019 MBT. All rights reserved.
//

import UIKit

class MBTBreedInfoViewController: UIViewController {

    @IBOutlet weak var breedNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var temperamentLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var lifeSpanLabel: UILabel!
    
    var representedBreed : MBTBreedModel? {
        didSet {
            populateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - UI functionality
    func populateUI() {
        loadViewIfNeeded()
        guard let breed = representedBreed else {
            return
        }
        
        breedNameLabel.text = breed.name
        descriptionLabel.text = breed.description
        temperamentLabel.text = breed.temperament
        countryLabel.text = breed.country
        weightLabel.text = breed.weight + " kgs"
        lifeSpanLabel.text = breed.lifeSpan + " average life span"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
