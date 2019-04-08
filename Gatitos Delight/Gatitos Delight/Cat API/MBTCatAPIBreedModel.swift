//
//  MBTCatAPIBreedModel.swift
//  Gatitos Delight
//
//  Created by Marco Benzi Tobar on 4/7/19.
//  Copyright © 2019 MBT. All rights reserved.
//

import Foundation

/// Swift representation of the Cat API breed model.
struct MBTCatAPIBreedModel {
    /// ID of the breed.
    var id: String
    /// Name of the breed.
    var name: String
    /// Country where the breed comes from.
    var country: String
    /// Expected life span of the breed.
    var lifeSpan: String
    /// A series of adjectives describing the perceived temperament of the breed.
    var temperament: String
    /// Description of the breed.
    var description: String
    /// Average weight of the breed.
    var weight: String
}
