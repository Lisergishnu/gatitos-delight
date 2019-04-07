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
    @IBOutlet weak var loadingBackgroundImageView: UIImageView!
    @IBOutlet weak var actionBannerImageView: UIImageView!
    @IBOutlet weak var upvoteImageView: UIImageView!
    @IBOutlet weak var downvoteImageView: UIImageView!
    
    // The label of setCat notifications
    static let SetCat = Notification.Name("setCat")
    
    // These variables are set everytime fillUI is called
    var currentCatID: String?
    var currentCatURL: URL?

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(setCat(notification:)), name: MBTCatsRatingViewController.SetCat, object: nil)
        
        showLoadingUI()
        askForRandomCat() {
            self.hideLoadingUI()
        }
    }

    // MARK: - Cat API functionality
    func askForRandomCat(completion: (()->())? = nil) {
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
    
    func askForCat(with imageID:String, completion: (()->())? = nil) {
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
            self.askForRandomCat() {
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
            self.askForRandomCat() {
                self.hideLoadingUI()
            }
        }
        self.startBannerAnimation(with: UIImage(named: "NayBanner")!)
    }
    
    // MARK: - UI Helper functions
    func fillUI(catInfoResponse: JSON, completion: (()->())? = nil) {
        debugPrint(catInfoResponse)
        if let breedName = catInfoResponse["breeds"][0]["name"].string  {
            breedButton.setTitle(breedName, for: UIControl.State.normal)
        } else {
            breedButton.setTitle("", for: UIControl.State.normal)
        }
        
        if let catID = catInfoResponse["id"].string {
            currentCatID = catID
        }
        
        if let imageURL = catInfoResponse["url"].string {
            let url = URL(string: imageURL)
            currentCatURL = url
            catImageView.kf.cancelDownloadTask()
            let processor = DownsamplingImageProcessor(size: catImageView.bounds.size)
                            >> RoundCornerImageProcessor(cornerRadius: 20)
            catImageView.kf.indicatorType = .activity
            catImageView?.kf.setImage(
                with: url,
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1))])
            catImageView.kf.setImage(with: url) { result in
                switch result {
                case .success(let value):
                    debugPrint(value.image)
                    completion?()
                case .failure(let error):
                    print(error)
                    DispatchQueue.main.async {
                        self.showLoadingUI()
                        self.askForRandomCat() {
                            self.hideLoadingUI()
                        }
                    }
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
        upvoteImageView.isHidden = true
        downvoteImageView.isHidden = true
        actionBannerImageView.isHidden = true
        
        loadingBackgroundImageView.isHidden = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingUI() {
        catImageView.isHidden = false
        if breedButton.currentTitle != "" {
                breedButton.isHidden = false
        }
        upvoteButton.isHidden = false
        downvoteButton.isHidden = false
        upvoteImageView.isHidden = false
        downvoteImageView.isHidden = false
        actionBannerImageView.isHidden = false
        
        loadingBackgroundImageView.isHidden = true
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    // MARK: - Transitions
    @IBAction func goToBreed(_ sender: Any) {
        guard let name = breedButton.titleLabel?.text else {
            return
        }
        let userInfo: [String:String] = [MBTBreedsTableViewController.BreedNameKey:name]
        NotificationCenter.default.post(name: MBTBreedsTableViewController.SetBreed, object: nil, userInfo: userInfo)
        tabBarController?.selectedIndex = 1
    }
    
    @IBAction func openDetail(_ sender: Any) {
        performSegue(withIdentifier: "zoom", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "zoom" {
            guard let controller = segue.destination as? MBTCatPhotoDetailViewController,
                let url = currentCatURL else {
                return
            }
            controller.photoURL = url
        }
    }
    
    @IBAction func unwindDetailView(segue: UIStoryboardSegue) {
    }
    
    // MARK: - Notification handling
    @objc func setCat(notification: NSNotification) {
        guard let id = notification.userInfo?[MBTBreedDetailViewController.ImageIDKey] as? String else{
            return
        }
        showLoadingUI()
        askForCat(with: id) {
            self.hideLoadingUI()
        }
    }
}

