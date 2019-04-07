//
//  MBTCatAPIHeader.swift
//  Gatitos Delight
//
//  Created by Marco Benzi Tobar on 4/6/19.
//  Copyright © 2019 MBT. All rights reserved.
//

import Alamofire

/// A container for Cat API related data.
class MBTCatAPIHeader {
    /// Header containing our Cat API key.
    static let httpHeader : HTTPHeaders = [
        // In production code the API Key should be stored more securely (see https://medium.freecodecamp.org/how-to-securely-store-api-keys-4ff3ea19ebda)
        "x-api-key": "6d3869a8-4adf-4ffd-a0ee-858e20e61f24",
        "Accept": "application/json"
    ]
}
