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

/// A view controller for showing the breed details with some example images.
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
    
    /// Reference to the embedded breed info view controller.
    var breedInfoViewController: MBTBreedInfoViewController?
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    
    /// Constant string for identifing the imageID data when passing a SetCat notification.
    /// - SeeAlso: MBTCatsRatingViewController.SetCat
    static let ImageIDKey: String = "imageID"
    
    /// The represented breed shown in the view. Setting this will refresh the UI.
    var representedBreed : MBTBreedModel? {
        didSet{
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
                let url = URL(string: model.url)
                let processor = DownsamplingImageProcessor(size: thumbnailsImageViews[i]!.bounds.size)
                thumbnailsImageViews[i]?.kf.indicatorType = .activity
                thumbnailsImageViews[i]?.kf.setImage(
                    with: url,
                    options: [
                        .processor(processor),
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(1)),
                        .cacheOriginalImage])
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
    
    /// Shows an spinning activity indicator, hiding all the rest of the UI.
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
    
    /// Hides the spinning activity indicator, showing the informational UI.
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
    
    /// Objective-C compilant function that listens when the user taps one of the thumbnails.
    ///
    /// - Note: This function uses the UIImageView accesibilityIdentifier property to retrieve the image ID.
    /// - Parameter tapGestureRecognizer: The sender of the event.
    @objc func breedImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let imageView = tapGestureRecognizer.view as! UIImageView
        guard let imageID = imageView.accessibilityIdentifier else {
            return
        }
        goToCatRating(with: imageID)
    }
    
    // MARK: - API request
    
    /// Performs an Cat API request for 9 or less cat images.
    ///
    /// - Parameters:
    ///   - breedID: Cat API breed ID to search.
    ///   - completion: Closure capturing an array of MBTBreedImageModel with the URLs of the images. Called upon request success.
    /// - SeeAlso: MBTBreedImageModel
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
    
    
    /// Switches to the Cats tab and shows an specific image there.
    ///
    /// - Parameter imageID: Cat API image ID to show in the Cats tab.
    func goToCatRating(with imageID:String){
        debugPrint(imageID)
        // Using the notification center to keep things decoupled
        let userInfo: [String: String] = [MBTBreedDetailViewController.ImageIDKey:imageID]
        NotificationCenter.default.post(name: MBTCatsRatingViewController.SetCat, object: nil, userInfo: userInfo)
        tabBarController?.selectedIndex = 0
    }
}
