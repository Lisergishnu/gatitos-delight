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
    @IBOutlet weak var photoDetailHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoDetailWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoDetailScrollView: UIScrollView!
    
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
        photoDetailImageView.kf.setImage(with: url) {
            result in
            switch result {
            case .success(let value):
                self.photoDetailWidthConstraint.constant = value.image.size.width
                self.photoDetailHeightConstraint.constant = value.image.size.height
            case .failure(let error):
                print (error)
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // The min scale calculation helps provide pinch functionality, while keeping the image always fitted to the width or height of the screen.
        let widthScale = view.bounds.width / photoDetailImageView.bounds.width
        let heightScale = view.bounds.height / photoDetailImageView.bounds.height
        let minScale = min(widthScale,heightScale)
        photoDetailScrollView.minimumZoomScale = minScale
        photoDetailScrollView.zoomScale = minScale
    }
}

extension MBTCatPhotoDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoDetailImageView
    }
}
