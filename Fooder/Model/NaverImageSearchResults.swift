//
//  NaverImageSearchResults.swift
//  Fooder
//
//  Created by Jung Hwan Park on 2022/03/10.
//

import Foundation

struct NaverImgSearchResult: Codable
{
    let items: [NaverImage]
}

struct NaverImage: Codable
{
    let title: String
    let link: String
    let thumbnail: String
    let sizeheight: String
    let sizewidth: String
}
