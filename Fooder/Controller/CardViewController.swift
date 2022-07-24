//
//  ViewController.swift
//  Fooder
//
//  Created by Jung Hwan Park on 2022/02/19.
//

import UIKit
import GooglePlaces
import VerticalCardSwiper
import SwiftSpinner

class CardViewController: UIViewController, VerticalCardSwiperDatasource, VerticalCardSwiperDelegate
{
    var selectedCell: MyVerticalCardSwiper?
    
    var location: CLLocation?
    
    var navBarTitle: String?
    
    let placesURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?language=ko"
    
    var placesName = [String]()
    var placesID = [String]()
    var photoReference = [String]()
    var placesVicinity = [String]()
    
    var heartImage: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(systemName: "suit.heart.fill")
        img.tintColor = .systemPink
        return img
    }()
    
    var trashImage: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(systemName: "trash.fill")
        img.tintColor = .white
        return img
    }()
    
    @IBOutlet var cardSwiper: VerticalCardSwiper!
    
    @IBOutlet var navigationBar: UINavigationBar!
    
    @IBOutlet var saveButton: UIButton!
    
    let dispatchGroup = DispatchGroup()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("viewdidload")
        view.backgroundColor = K.bgColor
        cardSwiper.backgroundColor = .clear
        cardSwiper.delegate = self
        cardSwiper.stackedCardsCount = 0
        
        cardSwiper.register(nib: UINib(nibName: K.cardSwiperNibName, bundle: nil), forCellWithReuseIdentifier: K.cardSwiperNibName)
        
        self.navigationBar.topItem?.title = "위치: "
        
        let urlString = "\(placesURL)&location=\(location!.coordinate.latitude),\(location!.coordinate.longitude)&radius=2500&type=restaurant&keyword=food&key=\(K.placesAPIKey)"
        dispatchGroup.enter()
        fetchNearbyRestaurants(urlString, location!, false) { success in
            if success == true
            {
                self.dispatchGroup.leave()
                print("PlacesName: \(self.placesName.count)")
                print("PhotoReference: \(self.photoReference.count)")
                self.cardSwiper.datasource = self
                DispatchQueue.main.async
                {
                    self.cardSwiper.reloadData()
                }
            }
        }
        dispatchGroup.notify(queue: .main)
        {
            if self.navBarTitle == nil
            {
                self.lookUpCurrentLocation(self.location!)
                { placemark in
                    self.navigationBar.topItem?.title = "위치: \((placemark?.name)!)"
                    //stop loading animation
                    K.globalFlag = true
                    SwiftSpinner.hide()
                }
            }
            else
            {
                self.navigationBar.topItem?.title = "위치: \(self.navBarTitle!)"
            }
            self.navigationBar.isHidden = false
            self.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationBar.shadowImage = UIImage()
            self.navigationBar.isTranslucent = true
            self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: K.mainBgColor , .font: UIFont.systemFont(ofSize: 20.0, weight: .medium)]
            
            //stop loading animation
            K.globalFlag = true
            SwiftSpinner.hide()
        }
        
        saveButton.backgroundColor = .white
        saveButton.layer.cornerRadius = 20
        saveButton.layer.shadowColor = UIColor.white.cgColor
        saveButton.layer.shadowRadius = 12
        saveButton.layer.shadowOpacity = 0.3
        saveButton.setTitle("저장하기", for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if !K.globalFlag
        {
            DispatchQueue.main.async
            {
                SwiftSpinner.show("주변 식당을 불러오는 중 입니다...")
            }
        }
    }
    
    func fetchNearbyRestaurants(_ url: String, _ location: CLLocation, _ repeating: Bool, completion: @escaping (_ success: Bool) -> Void)
    {
        dispatchGroup.enter()
        print("URL is: \(url)")
        if let url = URL(string: url)
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
                    let placesList = self.parseJSON(placesData: safeData)!
                    for place in placesList.results
                    {
                        if place.rating != 0
                        {
                            self.placesName.append(place.name)
                            self.placesVicinity.append(place.vicinity)
                            self.placesID.append(place.place_id)
                            print(place.name)
                            if place.photos != nil
                            {
                                self.photoReference.append(place.photos![0].photo_reference)
                            }
                            else
                            {
                                self.photoReference.append("nil")
                            }
                        }
                    }
                    if placesList.next_page_token != nil
                    {
                        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=\(placesList.next_page_token!)&key=\(K.placesAPIKey)"
                        self.dispatchGroup.leave()
                        DispatchQueue.main.asyncAfter(deadline: .now()+3.5)
                        {
                            self.fetchNearbyRestaurants(urlString, location, true) { success in
                                if success == true
                                {
                                    DispatchQueue.main.async
                                    {
                                        print(self.placesName.count)
                                        self.cardSwiper.reloadData()
                                    }
                                    completion(true)
                                    return
                                }
                            }
                        }
                    }
                    else
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now()+3.7)
                        {
                            self.dispatchGroup.leave()
                        }
                        completion(true)
                        return
                    }
                }
            }
            //4. start the task
            task.resume()
        }
    }
    
    func parseJSON(placesData: Data) -> PlacesData?
    {
        let decoder = JSONDecoder()
        do
        {
            let places = try decoder.decode(PlacesData.self, from: placesData)
            
            return places
        }
        catch let error
        {
            print(error.localizedDescription)
            return nil
        }
    }
    
    
    func lookUpCurrentLocation(_ location: CLLocation, completionHandler: @escaping (CLPlacemark?) -> Void )
    {
        let geocoder = CLGeocoder()
            // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(location, completionHandler:
        { (placemarks, error) in
            if error == nil
            {
                let firstLocation = placemarks?[0]
                completionHandler(firstLocation)
            }
            else
            {
             // An error occurred during geocoding.
                completionHandler(nil)
            }
        })
    }
    
    @IBAction func didTapSave(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    //MARK: - VerticalCardSwiper DataSource Methods
    func cardForItemAt(verticalCardSwiperView: VerticalCardSwiperView, cardForItemAt index: Int) -> CardCell
    {
        guard let cell =  verticalCardSwiperView.dequeueReusableCell(withReuseIdentifier: K.cardSwiperNibName, for: index) as? MyVerticalCardSwiper else {
            return CardCell()
        }
        cell.initCell(background: self.photoReference[index], title: self.placesName[index], subtitle: self.placesVicinity[index])
        
        if index == self.placesName.count-1
        {
            print("reached end \(self.placesName.count)")
        }
        return cell
    }

    func numberOfCards(verticalCardSwiperView: VerticalCardSwiperView) -> Int
    {
        return self.placesName.count
    }
    
    //MARK: - VerticalCardSwiper Delegate Methods
    func didTapCard(verticalCardSwiperView: VerticalCardSwiperView, index: Int)
    {
        let detailVC = DetailCardViewController(self.placesID[index])

        let cell = cardSwiper.cardForItem(at: index) as? MyVerticalCardSwiper
        
        print(cell)
        selectedCell = cell
        detailVC.dismissClosure = { [weak self] in
//            guard let StrongSelf = self else { return }
//            StrongSelf.updateStatusBar(visible: true)
        }
//        updateStatusBar(visible: false)
        present(detailVC, animated: true, completion: nil)
    }
    
    func didDragCard(card: CardCell, index: Int, swipeDirection: SwipeDirection)
    {
        trashImage.frame = CGRect(x: card.bounds.origin.x+15, y: card.bounds.height/2+100, width: 80, height: 80)
        view.addSubview(trashImage)
        view.sendSubviewToBack(trashImage)
        
        heartImage.frame = CGRect(x: card.bounds.origin.x+card.bounds.width-65, y: card.bounds.height/2+100, width: 90, height: 80)
        view.addSubview(heartImage)
        view.sendSubviewToBack(heartImage)
        
        if swipeDirection == .Right
        {
            print("right")
//            trashImage.frame = CGRect(x: card.bounds.origin.x+5, y: card.bounds.height/2+100, width: 80, height: 80)
//            view.addSubview(trashImage)
//            self.view.sendSubviewToBack(trashImage)
        }
        else if swipeDirection == .Left
        {
            print("left")
//            heartImage.frame = CGRect(x: card.bounds.origin.x+card.bounds.width-55, y: card.bounds.height/2+100, width: 90, height: 80)
//            view.addSubview(heartImage)
//            self.view.sendSubviewToBack(heartImage)
        }
    }
    
    func didCancelSwipe(card: CardCell, index: Int)
    {
        //do something when swipe is cancelled
        heartImage.removeFromSuperview()
        trashImage.removeFromSuperview()
    }

    func willSwipeCardAway(card: CardCell, index: Int, swipeDirection: SwipeDirection)
    {
        if swipeDirection ==  .Right
        {
            //add to favorites
            print("add to favorites")
            card.layer.borderColor = UIColor.systemPink.cgColor
            card.layer.borderWidth = 5
            card.layer.cornerRadius = 10
            self.cardSwiper.reloadData()
            //add to favorites array
        }
        else if swipeDirection == .Left
        {
            //delete item
            removePlaceAtIndex(index) { success in
                if success == true
                {
                    self.cardSwiper.reloadData()
                    print("delete item")
                }
            }
            //trash can opening animation??
        }
    }
    
    func didSwipeCardAway(card: CardCell, index: Int, swipeDirection: SwipeDirection)
    {
        self.cardSwiper.reloadData()
    }
    
    func removePlaceAtIndex(_ index: Int, completion: @escaping (_ success: Bool) -> Void)
    {
        placesName.remove(at: index)
        placesID.remove(at: index)
        photoReference.remove(at: index)
        placesVicinity.remove(at: index)
        cardSwiper.deleteCards(at: [index])
        print(index)
        completion(true)
        return
    }
}

