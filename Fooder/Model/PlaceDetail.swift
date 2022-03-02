//
//  PlaceDetail.swift
//  Fooder
//
//  Created by Jung Hwan Park on 2022/03/02.
//

import Foundation

struct PlaceDetail: Codable
{
    let result: Detail
}

struct Detail: Codable
{
    let name: String
    let formatted_address: String
    let formatted_phone_number: String?
    let opening_hours: OpeningHours?
    let price_level: Int?
    let rating: Double?
    let user_ratings_total: Int?
    let photos: [Photo]?
}

struct OpeningHours: Codable
{
    let open_now: Bool
    let weekday_text: [String]
}
