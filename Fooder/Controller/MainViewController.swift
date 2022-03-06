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
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    private var tableDataSource: GMSAutocompleteTableDataSource!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        searchBar.delegate = self
        
        tableDataSource = GMSAutocompleteTableDataSource()
        tableDataSource.delegate = self
        
        tableView.delegate = tableDataSource
        tableView.dataSource = tableDataSource
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
