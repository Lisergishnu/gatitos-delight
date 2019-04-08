//
//  MBTCatPhotoDetailViewController.swift
//  Gatitos Delight
//
//  Created by Marco Benzi Tobar on 4/7/19.
//  Copyright © 2019 MBT. All rights reserved.
//

import UIKit
import Kingfisher

/// A view controller that allows the user to scroll and zoom an image.
class MBTCatPhotoDetailViewController: UIViewController {

    /// Represented photo in the view.
    var photoURL: URL? {
        didSet {
            populateUI()
        }
    }
    
    @IBOutlet private weak var photoDetailImageView: UIImageView!
    @IBOutlet private weak var photoDetailHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var photoDetailWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var photoDetailScrollView: UIScrollView!
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    // MARK: - UI functionality
    /// Refreshes the UI of the controlled view with the represented image URL.
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
}

// MARK: - UIScrollViewDelegate
extension MBTCatPhotoDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoDetailImageView
    }
}
