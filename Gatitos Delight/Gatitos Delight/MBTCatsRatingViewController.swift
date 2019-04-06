//
//  MBTCatsRatingViewController.swift
//  Gatitos Delight
//
//  Created by Marco Benzi Tobar on 4/6/19.
//  Copyright © 2019 MBT. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON
import Kingfisher

class MBTCatsRatingViewController: UIViewController {
    
    
    @IBOutlet weak var catImageView: UIImageView!
    @IBOutlet weak var breedButton: UIButton!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getRandomCat()
    }
    
    // MARK: - Cat functionality
    func getRandomCat() {
        showLoadingUI()
        Alamofire.request("https://api.thecatapi.com/v1/images/search", headers: MBTCatAPIHeader.httpHeader).responseSwiftyJSON { response in
            guard let responseValue = response.result.value?[0] else {
                debugPrint("Couldn't get a proper API response.")
                return
            }
            self.fillUI(catInfoResponse: JSON(responseValue))
        }
    }
    
    // MARK: - UI Helper functions
    func fillUI(catInfoResponse: JSON) {
        debugPrint(catInfoResponse)
        if let breedName = catInfoResponse["breeds"]["name"].string  {
            breedButton.setTitle(breedName, for: UIControl.State.normal)
        } else {
            breedButton.setTitle("", for: UIControl.State.normal)
        }
        
        if let imageURL = catInfoResponse["url"].string {
            let url = URL(string: imageURL)
            catImageView.kf.setImage(with: url) { result in
                switch result {
                case .success(let value):
                    debugPrint(value.image)
                    self.hideLoadingUI()
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            debugPrint("Cat image couldn't be loaded.")
        }
    }
    
    func showLoadingUI() {
        catImageView.isHidden = true
        breedButton.isHidden = true
        upvoteButton.isHidden = true
        downvoteButton.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingUI() {
        catImageView.isHidden = false
        breedButton.isHidden = false
        upvoteButton.isHidden = false
        downvoteButton.isHidden = false
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}

