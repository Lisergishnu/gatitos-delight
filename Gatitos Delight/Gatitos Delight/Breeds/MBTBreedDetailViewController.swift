//
//  MBTBreedDetailViewController.swift
//  Gatitos Delight
//
//  Created by Marco Benzi Tobar on 4/7/19.
//  Copyright © 2019 MBT. All rights reserved.
//

import UIKit

class MBTBreedDetailViewController: UIViewController {

    @IBOutlet weak var breedNameLabel: UILabel!
    
    var representedBreed : MBTBreedCellModel? {
        didSet{
            populateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - UI functionality
    func populateUI() {
        loadViewIfNeeded()
        
        guard let breed = representedBreed else {
            return
        }
        
        navigationItem.title = breed.name
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
