//
//  ImageCacheManager.swift
//  Fooder
//
//  Created by Jung Hwan Park on 2022/03/01.
//

import Foundation
import UIKit

class ImageCacheManager
{
    static let shared = NSCache<NSString, UIImage>()
    private init() {}
}

