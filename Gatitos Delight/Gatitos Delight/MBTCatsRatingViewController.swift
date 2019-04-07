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
    
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var catImageView: UIImageView!
    @IBOutlet weak var breedButton: UIButton!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // The label of setCat notifications
    static let SetCat = Notification.Name("setCat")
    
    // This variable is set everytime fillUI is called
    var currentCatID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(setCat(notification:)), name: MBTCatsRatingViewController.SetCat, object: nil)
        
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
    
    func getCat(with imageID:String, completion: (()->())? = nil) {
        Alamofire.request("https://api.thecatapi.com/v1/images/"+imageID, headers: MBTCatAPIHeader.httpHeader).responseSwiftyJSON { response in
            guard let responseValue = response.result.value else {
                debugPrint("Couldn't get a proper API response.")
                return
            }
            self.fillUI(catInfoResponse: JSON(responseValue)) {
                completion?()
            }
        }
    }
    
    func emitVote(with id:String, value:Int, completion: (()->())? = nil) {
        let voteBody : Parameters = [
            "image_id" : id,
            "value": value
        ]
        debugPrint(voteBody)
        Alamofire.request("https://api.thecatapi.com/v1/votes",
                          method: .post,
                          parameters: voteBody,
                          encoding: JSONEncoding.default,
                          headers: MBTCatAPIHeader.httpHeader).responseSwiftyJSON { response in
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
        self.startBannerAnimation(with: UIImage(named: "YayBanner")!)
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
        self.startBannerAnimation(with: UIImage(named: "NayBanner")!)
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
            catImageView.kf.cancelDownloadTask()
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
    
    func startBannerAnimation(with image:UIImage) {
        self.bannerImageView.alpha = 0
        bannerImageView.image = image
        UIView.animate(withDuration: 0.75,
                       delay: 0,
                       options:[.autoreverse,.curveEaseOut],
                       animations: {
                        self.bannerImageView.alpha = 1
                        },
                       completion: { finished in
                        self.bannerImageView.alpha = 0
                })
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
    
    // MARK: - Notification handling
    @objc func setCat(notification: NSNotification) {
        guard let id = notification.userInfo?[MBTBreedDetailViewController.ImageIDKey] as? String else{
            return
        }
        showLoadingUI()
        getCat(with: id) {
            self.hideLoadingUI()
        }
    }
}

