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
        getThumbnails(with: breed.id) { imgurls in
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
            for strurl in imgurls {
                thumbnailsImageViews[i]?.kf.indicatorType = .activity
                let url = URL(string: strurl)
                thumbnailsImageViews[i]?.kf.setImage(with: url)
                i += 1
            }
            // Remove image views with no images
            if i < 9 {
                for j in (i-1)..<9 {
                    thumbnailsImageViews[j]?.removeFromSuperview()
                }
            }
        }
    }
    
    // MARK: - API request
    func getThumbnails(with breedID:String, completion: (([String])->())? = nil) {
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
                                var strUrls : [String] = []
                                guard let responseValue = response.result.value else {
                                    debugPrint("Couldn't get a proper API response.")
                                    return
                                }
                                
                                for (_,img):(String,JSON) in JSON(responseValue) {
                                    guard let strUrl = img["url"].string else {
                                        continue
                                    }
                                    strUrls.append(strUrl)
                                }
                                completion?(strUrls)
                            case .failure(let error):
                                debugPrint(error)
                            }
        }
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
