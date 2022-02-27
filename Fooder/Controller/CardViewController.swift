//
//  ViewController.swift
//  Fooder
//
//  Created by Jung Hwan Park on 2022/02/19.
//

import UIKit
import GooglePlaces
import VerticalCardSwiper
import CoreLocation

class CardViewController: UIViewController, VerticalCardSwiperDatasource, VerticalCardSwiperDelegate, CLLocationManagerDelegate
{
    var selectedCell: MyVerticalCardSwiper?
    
    var locationManager: CLLocationManager?
    private var placesClient: GMSPlacesClient!
    
    let placesURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?language=ko"
    
    @IBOutlet var cardSwiper: VerticalCardSwiper!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        cardSwiper.delegate = self
        cardSwiper.datasource = self
        cardSwiper.isSideSwipingEnabled = false
        cardSwiper.register(nib: UINib(nibName: K.cardSwiperNibName, bundle: nil), forCellWithReuseIdentifier: K.cardSwiperNibName)
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        placesClient = GMSPlacesClient.shared()
        
        fetchNearbyRestaurants()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        locationManager?.stopUpdatingLocation()
    }
    
    func fetchNearbyRestaurants()
    {
        let currentLocation = locationManager?.location
        let urlString = "\(placesURL)&location=\(currentLocation!.coordinate.latitude),\(currentLocation!.coordinate.longitude)&radius=5000&type=restaurant&keyword=food&key=\(K.placesAPIKey)"
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
                    let placesList = self.parseJSON(placesData: safeData)!
                    for place in placesList.results
                    {
                        print(place.name)
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
    //MARK: - VerticalCardSwiper DataSource Methods
    func cardForItemAt(verticalCardSwiperView: VerticalCardSwiperView, cardForItemAt index: Int) -> CardCell
    {
        guard let cell =  verticalCardSwiperView.dequeueReusableCell(withReuseIdentifier: K.cardSwiperNibName, for: index) as? MyVerticalCardSwiper else {
            return CardCell()
        }
        cell.initCell(background: "img1", title: "Foobar", subtitle: "test123")
        
        return cell
    }
    
    func numberOfCards(verticalCardSwiperView: VerticalCardSwiperView) -> Int
    {
        return 10
    }
    
    //MARK: - VerticalCardSwiper Delegate Methods
    func didTapCard(verticalCardSwiperView: VerticalCardSwiperView, index: Int)
    {
        let detailVC = DetailCardViewController()

        let cell = cardSwiper.cardForItem(at: index) as? MyVerticalCardSwiper
        print(cell)
        selectedCell = cell
        detailVC.dismissClosure = { [weak self] in
//            guard let StrongSelf = self else { return }
//            StrongSelf.updateStatusBar(visible: true)
        }
        detailVC.backImage = "img2"
//        updateStatusBar(visible: false)
        present(detailVC, animated: true, completion: nil)
    }
    
    //MARK: - CLLocationManager Delegate Methods
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager)
    {
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse
        {
            locationManager?.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let location = locations.last
        {
            print("New location is \(locations)")
        }
    }
}

