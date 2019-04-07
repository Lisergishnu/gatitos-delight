//
//  MBTBreedDetailViewController.swift
//  Gatitos Delight
//
//  Created by Marco Benzi Tobar on 4/7/19.
//  Copyright © 2019 MBT. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON
import Kingfisher

struct MBTBreedImageModel {
    var url: String
    var imageID: String
}

class MBTBreedDetailViewController: UIViewController {

    @IBOutlet weak var catThumbnail1ImageView: UIImageView!
    @IBOutlet weak var catThumbnail2ImageView: UIImageView!
    @IBOutlet weak var catThumbnail3ImageView: UIImageView!
    @IBOutlet weak var catThumbnail4ImageView: UIImageView!
    @IBOutlet weak var catThumbnail5ImageView: UIImageView!
    @IBOutlet weak var catThumbnail6ImageView: UIImageView!
    @IBOutlet weak var catThumbnail7ImageView: UIImageView!
    @IBOutlet weak var catThumbnail8ImageView: UIImageView!
    @IBOutlet weak var catThumbnail9ImageView: UIImageView!
    @IBOutlet weak var breedInfoContainerView: UIView!
    
    var breedInfoViewController: MBTBreedInfoViewController?
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    static let ImageIDKey: String = "imageID"
    
    var representedBreed : MBTBreedModel? {
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
        showLoadingUI()
        navigationItem.title = breed.name
        
        if let infoVC = breedInfoViewController {
            infoVC.representedBreed = breed
        }
        
        getThumbnails(with: breed.id) { imgModels in
            var thumbnailsImageViews = [
             self.catThumbnail1ImageView,
             self.catThumbnail2ImageView,
             self.catThumbnail3ImageView,
             self.catThumbnail4ImageView,
             self.catThumbnail5ImageView,
             self.catThumbnail6ImageView,
             self.catThumbnail7ImageView,
             self.catThumbnail8ImageView,
             self.catThumbnail9ImageView
            ]
            
            var i = 0
            for model in imgModels {
                thumbnailsImageViews[i]?.kf.indicatorType = .activity
                let url = URL(string: model.url)
                thumbnailsImageViews[i]?.kf.setImage(with: url)
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.breedImageTapped(tapGestureRecognizer:)))
                thumbnailsImageViews[i]?.isUserInteractionEnabled = true
                thumbnailsImageViews[i]?.addGestureRecognizer(tap)
                // We store the image id in the accesiblity identifier. A more elegant solution could consider subclassing UIImageView, but I consider it overkill for what we want to do.
                thumbnailsImageViews[i]?.accessibilityIdentifier = model.imageID
                i += 1
            }
            // Remove image views with no images
            if i < 9 {
                for j in (i-1)..<9 {
                    thumbnailsImageViews[j]?.removeFromSuperview()
                }
            }
            
            self.hideLoadingUI()
        }
    }
    
    func showLoadingUI() {
        let thumbnailsImageViews = [
            self.catThumbnail1ImageView,
            self.catThumbnail2ImageView,
            self.catThumbnail3ImageView,
            self.catThumbnail4ImageView,
            self.catThumbnail5ImageView,
            self.catThumbnail6ImageView,
            self.catThumbnail7ImageView,
            self.catThumbnail8ImageView,
            self.catThumbnail9ImageView
        ]
        
        for thumb in thumbnailsImageViews {
            thumb?.isHidden = true
        }
        breedInfoContainerView.isHidden = true
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
    }
    
    func hideLoadingUI() {
        let thumbnailsImageViews = [
            self.catThumbnail1ImageView,
            self.catThumbnail2ImageView,
            self.catThumbnail3ImageView,
            self.catThumbnail4ImageView,
            self.catThumbnail5ImageView,
            self.catThumbnail6ImageView,
            self.catThumbnail7ImageView,
            self.catThumbnail8ImageView,
            self.catThumbnail9ImageView
        ]
        
        for thumb in thumbnailsImageViews {
            thumb?.isHidden = false
        }
        breedInfoContainerView.isHidden = false
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
    }
    
    @objc func breedImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let imageView = tapGestureRecognizer.view as! UIImageView
        guard let imageID = imageView.accessibilityIdentifier else {
            return
        }
        goToCatRating(with: imageID)
    }
    
    // MARK: - API request
    func getThumbnails(with breedID:String, completion: (([MBTBreedImageModel])->())? = nil) {
        let body: Parameters = [
            "mime_types": "jpg,png",
            "breed_ids": breedID,
            "limit": 9,
            "size": "thumb"
        ]
        
        Alamofire.request("https://api.thecatapi.com/v1/images/search",
                          parameters:body,
                          headers: MBTCatAPIHeader.httpHeader).responseSwiftyJSON {
                            response in
                            switch response.result {
                            case .success:
                                debugPrint(response)
                                var breedImageModels : [MBTBreedImageModel] = []
                                guard let responseValue = response.result.value else {
                                    debugPrint("Couldn't get a proper API response.")
                                    return
                                }
                                
                                for (_,img):(String,JSON) in JSON(responseValue) {
                                    guard let strUrl = img["url"].string,
                                        let id = img["id"].string else {
                                        continue
                                    }
                                    let model = MBTBreedImageModel(url: strUrl, imageID: id)
                                    breedImageModels.append(model)
                                }
                                completion?(breedImageModels)
                            case .failure(let error):
                                debugPrint(error)
                            }
        }
    }
    
    // MARK: - Transitions
    // Embedding a view controller is a kind of segue, so we use this function for getting a reference to the breed info VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embeddedInfo" {
            breedInfoViewController = segue.destination as? MBTBreedInfoViewController
        }
    }
    
    func goToCatRating(with imageID:String){
        debugPrint(imageID)
    }
}
