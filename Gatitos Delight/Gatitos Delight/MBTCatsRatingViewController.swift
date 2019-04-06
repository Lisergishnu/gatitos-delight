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
    
    // This variable is set everytime fillUI is called
    var currentCatID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        showLoadingUI()
        getRandomCat() {
            self.hideLoadingUI()
        }
    }
    
    // MARK: - Cat API functionality
    func getRandomCat(completion: (()->())? = nil) {
        Alamofire.request("https://api.thecatapi.com/v1/images/search", headers: MBTCatAPIHeader.httpHeader).responseSwiftyJSON { response in
            guard let responseValue = response.result.value?[0] else {
                debugPrint("Couldn't get a proper API response.")
                return
            }
            self.fillUI(catInfoResponse: JSON(responseValue)) {
                completion?()
            }
        }
    }
    
    func emitVote(with id:String, value:Int, completion: (()->())? = nil) {
        let parameters : Parameters = [
            "image_id" : id,
            "value": value
        ]
        Alamofire.request("https://api.thecatapi.com/v1/votes", method: HTTPMethod.post, parameters: parameters, headers: MBTCatAPIHeader.httpHeader).responseSwiftyJSON { response in
            switch response.result {
            case .success:
                debugPrint(response)
                completion?()
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    // MARK: - Voting handlers
    @IBAction func upvoteCurrentCat(_ sender: Any) {
        guard let id = currentCatID else {
            return
        }
        showLoadingUI()
        emitVote(with: id, value: 1) {
            self.getRandomCat() {
                self.hideLoadingUI()
            }
        }
    }
    
    @IBAction func downvoteCurrentCat(_ sender: Any) {
        guard let id = currentCatID else {
            return
        }
        
        showLoadingUI()
        emitVote(with: id, value: 0) {
            self.getRandomCat() {
                self.hideLoadingUI()
            }
        }
    }
    
    // MARK: - UI Helper functions
    func fillUI(catInfoResponse: JSON, completion: (()->())? = nil) {
        debugPrint(catInfoResponse)
        if let breedName = catInfoResponse["breeds"]["name"].string  {
            breedButton.setTitle(breedName, for: UIControl.State.normal)
        } else {
            breedButton.setTitle("", for: UIControl.State.normal)
        }
        
        if let catID = catInfoResponse["id"].string {
            currentCatID = catID
        }
        
        if let imageURL = catInfoResponse["url"].string {
            let url = URL(string: imageURL)
            catImageView.kf.setImage(with: url) { result in
                switch result {
                case .success(let value):
                    debugPrint(value.image)
                    completion?()
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

