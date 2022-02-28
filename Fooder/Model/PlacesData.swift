//
//  PlacesData.swift
//  Fooder
//
//  Created by Jung Hwan Park on 2022/02/27.
//

import Foundation

struct PlacesData: Codable
{
    let next_page_token: String?
    let results: [Place]
}

struct Place: Codable
{
    let name: String
    let place_id: String
    let reference: String
    let vicinity: String
    let photos: [Photo]?
}

struct Photo: Codable
{
    let height: Int
    let width: Int
    let photo_reference: String
}
