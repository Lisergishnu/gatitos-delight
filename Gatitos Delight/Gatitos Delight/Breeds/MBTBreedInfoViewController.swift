//
//  MBTBreedInfoViewController.swift
//  Gatitos Delight
//
//  Created by Marco Benzi Tobar on 4/7/19.
//  Copyright © 2019 MBT. All rights reserved.
//

import UIKit

// A view controller for displaying breed details.
class MBTBreedInfoViewController: UIViewController {

    @IBOutlet private weak var breedNameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var temperamentLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var weightLabel: UILabel!
    @IBOutlet private weak var lifeSpanLabel: UILabel!
    
    /// The represented breed shown in the view. Setting this will refresh the UI.
    var representedBreed : MBTBreedModel? {
        didSet {
            populateUI()
        }
    }
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - UI functionality
    /// Refreshes the UI of the controlled view with the represented breed data.
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
}
