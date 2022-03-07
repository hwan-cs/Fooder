//
//  MainViewController.swift
//  Fooder
//
//  Created by Jung Hwan Park on 2022/03/06.
//

import UIKit
import GooglePlaces

class MainViewController: UIViewController
{
    private var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchButton: UIButton!
    
    private var tableDataSource: GMSAutocompleteTableDataSource!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = K.mainBgColor
        searchBar = UISearchBar(frame: CGRect(x: 0, y: self.view.frame.size.height/2, width: self.view.frame.size.width, height: 44.0))
        searchBar.delegate = self
        view.addSubview(searchBar)
        
        tableDataSource = GMSAutocompleteTableDataSource()
        tableDataSource.delegate = self
        
        tableView.delegate = tableDataSource
        tableView.dataSource = tableDataSource
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .large)
        let img = UIImage(systemName: "magnifyingglass", withConfiguration: largeConfig)
        searchButton.setImage(img, for: .normal)
        
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        filter.country = "kr"
        tableDataSource.autocompleteFilter = filter
        
        searchBar.searchTextField.backgroundColor = .gray
        searchBar.barTintColor = UIColor.clear
        searchBar.backgroundImage = UIImage()
        
        searchBar.alpha = 0
        tableView.alpha = 0
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
            self.searchBar.frame.origin.y = 50
        }
    }
}

extension MainViewController: UISearchBarDelegate
{
    
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
        print("Place name: \(place.name!)")
        print("Place address: \(place.formattedAddress!)")
        print("Place attributions: \(place.attributions!)")
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
