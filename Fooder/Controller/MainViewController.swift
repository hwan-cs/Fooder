//
//  MainViewController.swift
//  Fooder
//
//  Created by Jung Hwan Park on 2022/03/06.
//

import UIKit
import GooglePlaces
import CoreLocation

class MainViewController: UIViewController, CLLocationManagerDelegate
{
    private var searchBar: UISearchBar!
    private var useCurrentLocation: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchButton: UIButton!
    
    var locationManager: CLLocationManager?
    
    var didInit = false
    
    private var tableDataSource: GMSAutocompleteTableDataSource!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = K.mainBgColor
        searchBar = UISearchBar(frame: CGRect(x: 0, y: self.view.frame.size.height/2, width: self.view.frame.size.width-70, height: 60.0))
        searchBar.delegate = self
        useCurrentLocation = UIButton(frame: CGRect(x: self.view.frame.size.width-70, y: 50, width: 70, height: 60.0))
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold, scale: .large)
        let currLocImg = UIImage(systemName: "location.fill", withConfiguration: config)
        useCurrentLocation.setImage(currLocImg, for: .normal)
        useCurrentLocation.addTarget(self, action: #selector(onCurrentLocationClick(_:)), for: .touchUpInside)
        useCurrentLocation.alpha = 0
        view.addSubview(searchBar)
        view.addSubview(useCurrentLocation)
        
        tableDataSource = GMSAutocompleteTableDataSource()
        tableDataSource.primaryTextHighlightColor = .white
        tableDataSource.tableCellBackgroundColor = .clear
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        filter.country = "kr"
        tableDataSource.autocompleteFilter = filter
        tableDataSource.delegate = self
        
        tableView.delegate = tableDataSource
        tableView.dataSource = tableDataSource
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .large)
        let img = UIImage(systemName: "magnifyingglass", withConfiguration: largeConfig)
        searchButton.setImage(img, for: .normal)
        
        searchBar.searchTextField.backgroundColor = K.detailBgColor
        searchBar.barTintColor = UIColor.clear
        searchBar.backgroundImage = UIImage()
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = K.cardBgColor
        
        tableView.backgroundColor = K.mainBgColor
        searchBar.alpha = 0
        tableView.alpha = 0
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.searchBar.endEditing(true)
    }
    
    @IBAction func searchClicked(_ sender: UIButton)
    {
        UIView.animate(withDuration: 0.5)
        {
            self.searchButton.alpha = 0
            self.searchBar.alpha = 1
            self.useCurrentLocation.alpha = 1
            self.searchBar.frame.origin.y = 50
        }
    }
    
    @objc func onCurrentLocationClick(_ sender: UIButton)
    {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CardViewController") as! CardViewController
        if let currLoc = locationManager?.location
        {
            vc.location = currLoc
            vc.modalPresentationStyle = .fullScreen
            K.globalFlag = false
        }
        else
        {
            print("No location was available")
        }
        self.present(vc,animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        locationManager?.stopUpdatingLocation()
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
//            print("New location is \(locations)")
        }
    }
}

extension MainViewController: UISearchBarDelegate
{
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool
    {
        self.tableView.alpha = 1
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        tableDataSource.sourceTextHasChanged(searchText)
    }
}

extension MainViewController: GMSAutocompleteTableDataSourceDelegate
{
    func didUpdateAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource)
    {
        // Turn the network activity indicator off.
        //isNetworkActivityIndicatorVisible is deperecated in iOS 13.0
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        // Reload table data.
        tableView.reloadData()
    }

    func didRequestAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource)
    {
        tableView.reloadData()
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace)
    {
        // Do something with the selected place.
        let selectedLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CardViewController") as! CardViewController
        vc.location = selectedLocation
        vc.navBarTitle = place.name
        vc.modalPresentationStyle = .fullScreen
        K.globalFlag = false
        self.present(vc,animated: true)
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error)
    {
        print(error.localizedDescription)
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didSelect prediction: GMSAutocompletePrediction) -> Bool
    {
        return true
    }
}

extension MainViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60
    }
}
