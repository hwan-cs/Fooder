//
//  MyVerticalCardSwiper.swift
//  Fooder
//
//  Created by Jung Hwan Park on 2022/02/20.
//

import UIKit
import VerticalCardSwiper
import SwiftSpinner

class MyVerticalCardSwiper: CardCell
{
    @IBOutlet var bgView: UIView!
    @IBOutlet var backgroundImg: UIImageView!
    @IBOutlet var opacityView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        setUI()
        // Initialization code
    }
    
    override var isHighlighted: Bool
    {
        didSet
        {
            if isHighlighted
            {
                UIView.animate(withDuration: 0.1)
                {
                    self.bgView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                }
            }
            else
            {
                UIView.animate(withDuration: 0.3)
                {
                    self.bgView.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
            }
        }
    }
}


extension MyVerticalCardSwiper
{
    private func setUI()
    {
        bgView.layer.cornerRadius = 10
        bgView.clipsToBounds = true
        
        bgView.addGradientWithColor(color: UIColor.systemPink)
        
        backgroundImg.contentMode = .scaleAspectFill
        
        opacityView.backgroundColor = UIColor.black.withAlphaComponent(0.2)

        titleLabel.font = UIFont.systemFont(ofSize: 45, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 1
        
        subtitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = .white
        subtitleLabel.numberOfLines = 2
    }
    
    func initCell(background: String, title: String, subtitle: String)
    {
        if background != "nil"
        {
            let url = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=1600&photoreference=\(background)&key=\(K.placesAPIKey)"
            self.backgroundImg.contentMode = .scaleAspectFill
            self.backgroundImg.setImageUrl(url)
        }
        else
        {
            self.backgroundImg.image = UIImage(systemName: "photo.fill")
            self.backgroundImg.backgroundColor = K.cardBgColor
            self.backgroundImg.contentMode = .scaleAspectFit
        }
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
    }
}

extension UIImageView
{
    func setImageUrl(_ url: String)
    {
        let cacheKey = NSString(string: url)
        
        if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey)
        {
            // 해당 Key 에 캐시이미지가 저장되어 있으면 이미지를 사용
            self.image = cachedImage
            return
        }
        
        DispatchQueue.global(qos: .background).async
        {
            if let imageUrl = URL(string: url)
            {
                URLSession.shared.dataTask(with: imageUrl)
                { (data, res, err) in
                    if let _ = err
                    {
                        DispatchQueue.main.async
                        {
                            self.image = UIImage()
                        }
                        return
                    }
                    DispatchQueue.main.async
                    {
                        if let data = data, let image = UIImage(data: data)
                        {
                            ImageCacheManager.shared.setObject(image, forKey: cacheKey) // 다운로드된 이미지를 캐시에 저장
                            self.image = image
                            SwiftSpinner.hide()
                        }
                    }
                }.resume()
            }
        }
    }
}

extension UIView
{
    func addGradientWithColor(color: UIColor)
    {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [UIColor.clear.cgColor, color.cgColor]
     
        self.layer.insertSublayer(gradient, at: 0)
    }
}
