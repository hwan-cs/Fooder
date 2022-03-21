//
//  DetailScrollView.swift
//  Fooder
//
//  Created by Jung Hwan Park on 2022/02/20.
//

import UIKit
import SwiftSpinner

class DetailScrollView: UIScrollView
{
    let bgBackView = UIView()
    let imageView = UIImageView()
    var naverImages = [String]()
    let textView = UITextView()
    var transition = CATransition()
    
    var placeID: String
    var detail: PlaceDetail?
    
    let pageControl = UIPageControl(frame: CGRect(x: 0, y: 460, width: UIScreen.main.bounds.size.width, height: 40))
    
    init(frame: CGRect, id: String)
    {
        self.placeID = id
        print(self.placeID)
        super.init(frame: frame)
        isMultipleTouchEnabled = true
        fetchPlaceDetails(placeID)
        { success in
            if success == true
            {
                DispatchQueue.main.async
                {
                    self.setupUI()
                }
                if self.detail?.result.photos == nil
                {
                    DispatchQueue.main.async
                    {
                        SwiftSpinner.show("사진을 불러오는 중 입니다...")
                    }
                    self.requestAPINaver(query: (self.detail?.result.name)!)
                    { link in
                        print((self.detail?.result.name)!)
                        if link?.count != 0
                        {
                            SwiftSpinner.hide()
                            DispatchQueue.main.async
                            {
                                let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.getSwipeAction(_:)))
                                swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
                                let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.getSwipeAction(_:)))
                                swipeRight.direction = UISwipeGestureRecognizer.Direction.right
                                
                                self.imageView.addGestureRecognizer(swipeLeft)
                                self.imageView.addGestureRecognizer(swipeRight)
                                self.pageControl.numberOfPages = self.naverImages.count
                                self.imageView.addSubview(self.pageControl)
                                self.imageView.setImageUrl(self.naverImages[self.pageControl.currentPage])
                            }
                        }
                        else
                        {
                            DispatchQueue.main.async
                            {
                                SwiftSpinner.show(duration: 1.5, title: "사진을 불러오기 실패 했습니다!", animated:  false) {
                                    SwiftSpinner.hide()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI()
    {
        backgroundColor = K.bgColor
        bgBackView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 500)
        bgBackView.layer.masksToBounds = true
        
        imageView.frame = bgBackView.bounds
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        
        pageControl.currentPageIndicatorTintColor = UIColor.black
        pageControl.pageIndicatorTintColor = UIColor.lightGray.withAlphaComponent(0.8)
        
        bgBackView.addSubview(imageView)
        addSubview(bgBackView)
        
        textViewText = ""
        if let photos = self.detail?.result.photos
        {
            let bgImg = photos[Int.random(in: 0..<photos.count)]
            let url = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=1600&photoreference=\(bgImg.photo_reference)&key=\(K.placesAPIKey)"
            imageView.setImageUrl(url)
        }
        else
        {
            imageView.image = UIImage(named: "restaurant.jpeg")
        }
        textViewText.append("\(self.detail!.result.name)")
        textViewText.append("\n\n주소: \(self.detail!.result.formatted_address)")
        if let fpn = self.detail?.result.formatted_phone_number
        {
            textViewText.append("\n\n전화번호: \(fpn)")
        }
        
        if let ratings = self.detail?.result.rating, let urt = self.detail?.result.user_ratings_total
        {
            textViewText.append("\n\n평점: \(ratings) (\(urt))")
        }
        
        if let open = self.detail?.result.opening_hours
        {
            textViewText.append("\n\n")
            for str in open.weekday_text
            {
                textViewText.append("\(str)\n")
            }
        }
        
        textView.text = textViewText
        
        let textViewWidth = UIScreen.main.bounds.size.width - 2 * textViewLeftMargin
        let font = UIFont.boldSystemFont(ofSize: 18)
        let textHeight = textViewText.calculateHeightWith(width: textViewWidth, font: font)
        textView.frame = CGRect(x: textViewLeftMargin, y: bgBackView.frame.height + textViewTopMargin, width: textViewWidth, height: textHeight + CGFloat(textViewText.numberOfLines()*5))
        textView.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        textView.font = font
        textView.textColor = .black
        textView.isUserInteractionEnabled = false
        textView.backgroundColor = K.detailBgColor
        textView.layer.cornerRadius = 30
        textView.layer.shadowColor = UIColor.white.cgColor
        textView.clipsToBounds = false
        textView.layer.shadowOpacity = 0.3
        textView.layer.shadowRadius = 12
        addSubview(textView)

        contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: bgBackView.frame.height + textViewTopMargin + textView.frame.height + 300)
    }
    
    private func fetchPlaceDetails(_ id: String, completion: @escaping (_ success: Bool) -> Void)
    {
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?fields=name,photo,vicinity,geometry,address_component,formatted_address,adr_address,opening_hours,rating,formatted_phone_number,price_level,reviews,user_ratings_total,permanently_closed&place_id=\(id)&key=\(K.placesAPIKey)"
        print("URL is: \(urlString)")
        if let url = URL(string: urlString)
        {
            //2.create a url sesison
            let session = URLSession(configuration: .default)
            //3. give the session a task
            let task = session.dataTask(with: url)
            { (data, response, error) in
                if error != nil
                {
                    print(error?.localizedDescription)
                    return
                }
                if let safeData = data
                {
                    if let detail = self.parseJSON(detailData: safeData)
                    {
                        self.detail = detail
                        completion(true)
                        return
                    }
                }
            }
            //4. start the task
            task.resume()
        }
    }
    
    private func parseJSON(detailData: Data) -> PlaceDetail?
    {
        let decoder = JSONDecoder()
        do
        {
            let details = try decoder.decode(PlaceDetail.self, from: detailData)
            
            return details
        }
        catch let error
        {
            print(String(describing: error))
            return nil
        }
    }
    
    func requestAPINaver(query: String, completion: @escaping ([String]?)-> Void)
    {
        let stringURL = "https://openapi.naver.com/v1/search/image?query=\(query)&display=10&sort=sim"
        let encodedQuery: String = stringURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        if let url = URL(string: encodedQuery)
        {
            var requestURL = URLRequest(url: url)
            requestURL.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            requestURL.addValue(K.naverClientID, forHTTPHeaderField: "X-Naver-Client-Id")
            requestURL.addValue(K.naverClientKey, forHTTPHeaderField: "X-Naver-Client-Secret")
            print(requestURL)
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: requestURL)
            { (data, response, error) in
                if error != nil
                {
                    print(error?.localizedDescription)
                    return
                }
                if let safeData = data
                {
                    if let searchResult = self.parseNaverJSON(safeData)
                    {
                        if searchResult.items.count != 0
                        {
                            var link = searchResult.items.randomElement()?.link
                            let size = searchResult.items.count > 2 ? 3 : searchResult.items.count
                            for _ in 0..<size
                            {
                                while self.naverImages.contains(link!)
                                {
                                    link = searchResult.items.randomElement()?.link
                                }
                                print(link!)
                                self.naverImages.append(link!)
                            }
                        }

                        completion(self.naverImages)
                        return
                   }
                }
            }
            task.resume()
        }
    }
    
    func parseNaverJSON(_ searchResult: Data) -> NaverImgSearchResult?
    {
        let decoder = JSONDecoder()
        do
        {
            let results = try decoder.decode(NaverImgSearchResult.self, from: searchResult)
            
            return results
        }
        catch let error
        {
            print(error.localizedDescription)
            return nil
        }
    }
    
    @objc func getSwipeAction( _ recognizer : UISwipeGestureRecognizer)
    {
        if recognizer.direction == .right
        {
            pageControl.currentPage -= 1
        }
        else if recognizer.direction == .left
        {
            pageControl.currentPage += 1
        }
        animateImageView()
        imageView.setImageUrl(naverImages[self.pageControl.currentPage])
    }
    
    func animateImageView()
    {
        CATransaction.begin() //Begin the CATransaction

        CATransaction.setAnimationDuration(0.25)

        transition.type = CATransitionType.fade
        transition.subtype = CATransitionSubtype.fromRight

        imageView.layer.add(transition, forKey: kCATransition)
        CATransaction.commit()
    }
}


fileprivate let textViewLeftMargin: CGFloat = 20
fileprivate let textViewTopMargin: CGFloat = 40
fileprivate var textViewText = ""

extension String
{
    func calculateHeightWith(width: CGFloat, font: UIFont)-> CGFloat
    {
        let attr = [NSAttributedString.Key.font: font]
        let maxSize: CGSize = CGSize(width: width, height: CGFloat(MAXFLOAT))
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        return self.boundingRect(with: (maxSize), options: option, attributes: attr, context: nil).size.height
    }
    
    func numberOfLines() -> Int
    {
        return self.numberOfOccurrencesOf(string: "\n") + 1
    }

    func numberOfOccurrencesOf(string: String) -> Int
    {
        return self.components(separatedBy:string).count - 1
    }
}
