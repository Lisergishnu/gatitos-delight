//
//  MBTCatPhotoDetailViewController.swift
//  Gatitos Delight
//
//  Created by Marco Benzi Tobar on 4/7/19.
//  Copyright © 2019 MBT. All rights reserved.
//

import UIKit
import Kingfisher

class MBTCatPhotoDetailViewController: UIViewController {

    var photoURL: URL? {
        didSet {
            populateUI()
        }
    }
    
    @IBOutlet weak var photoDetailImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - UI functionality
    func populateUI() {
        loadViewIfNeeded()
        guard let url = photoURL else {
            return
        }
        
        photoDetailImageView.kf.indicatorType = .activity
        photoDetailImageView.kf.setImage(with: url)
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
