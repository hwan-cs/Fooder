//
//  MyVerticalCardSwiper.swift
//  Fooder
//
//  Created by Jung Hwan Park on 2022/02/20.
//

import UIKit
import VerticalCardSwiper

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
        
        backgroundImg.contentMode = .scaleAspectFill
        
        opacityView.backgroundColor = UIColor.black.withAlphaComponent(0.2)

        titleLabel.font = UIFont.systemFont(ofSize: 45, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        subtitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = .white
    }
    
    func initCell(background: String, title: String, subtitle: String)
    {
        if let background = UIImage(named: background)
        {
            self.backgroundImg.image = background
        }
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
    }
}

