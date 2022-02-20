//
//  DetailScrollView.swift
//  Fooder
//
//  Created by Jung Hwan Park on 2022/02/20.
//

import UIKit

class DetailScrollView: UIScrollView
{
    let bgBackView = UIView()
    let imageView = UIImageView()
    let textView = UITextView()

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI()
    {
        bgBackView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 500)
        bgBackView.layer.masksToBounds = true
        
        imageView.frame = bgBackView.bounds
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        
        let textViewWidth = UIScreen.main.bounds.size.width - 2 * textViewLeftMargin
        let font = UIFont.boldSystemFont(ofSize: 15)
        let textHeight = textViewText.calculateHeightWith(width: textViewWidth, font: font)
        textView.frame = CGRect(x: textViewLeftMargin, y: bgBackView.frame.height + textViewTopMargin, width: textViewWidth, height: textHeight + textViewBottomMargin)
        textView.text = textViewText
        textView.font = font
        textView.textColor = .gray
        
        bgBackView.addSubview(imageView)
        addSubview(bgBackView)
        addSubview(textView)
    
        contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: bgBackView.frame.height + textViewTopMargin + textView.frame.height + textViewBottomMargin)
    }
}


fileprivate let textViewLeftMargin: CGFloat = 20
fileprivate let textViewTopMargin: CGFloat = 40
fileprivate let textViewBottomMargin: CGFloat = 50
fileprivate let textViewText = "Thank you. I'm honored to be with you today for your commencement from one of the finest universities in the world. Truth be told, i never graduated from college and this is the closest I've ever gotten to a college gradution. \n\nToday i want to tell you three stories from my life. That's it. No big deal. Just three stories. The first story is about connecting the dots. \n\ndropped out of Reed College after the first 6 months, but then stayed around as a drop-in for another 18 months or so before I really quit. So why did I drop out? \n\nIt started before I was born. My biological mother was a young,unwed college graduate student, and she decided to put me up for adoption. She felt very strongly that I should be adopted by college graduates, so everything was all set for me to be adopted at birth by a lawyer and his wife. Except that when I popped out they decided at the last minute that they really wanted a girl. So my parents, who were on a waiting list, got a call in the middle of the night asking: 'We got an unexpected baby boy; do you want him?' They said: 'Of course.' My biological mother found out later that my mother had never graduated from college and  my father had never graduated from high school. She refused to sign the final adoption papers. She only relented a few months later when my parents promised that I would  go to college."

extension String
{
    func calculateHeightWith(width: CGFloat, font: UIFont)-> CGFloat
    {
        let attr = [NSAttributedString.Key.font: font]
        let maxSize: CGSize = CGSize(width: width, height: CGFloat(MAXFLOAT))
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        return self.boundingRect(with: (maxSize), options: option, attributes: attr, context: nil).size.height
    }
}
