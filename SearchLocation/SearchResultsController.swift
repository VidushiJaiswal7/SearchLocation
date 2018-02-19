//
//  SearchResultsController.swift
//  SearchLocation
//
//  Created by VIdushi Jaiswal on 18/02/18.
//  Copyright © 2018 Vidushi Jaiswal. All rights reserved.
//

//The SearchResultsController will hold the display of instant results returned from Google Places API each time the user is typing in the search bar.

import UIKit

protocol LocateOnTheMap{
    func locateWithLongitude(lon:Double, andLatitude lat:Double, andTitle title: String)
}

class SearchResultsController: UITableViewController {

    var searchResults: [String]!
    var delegate: LocateOnTheMap!
    
    //MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchResults = Array()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
          return self.searchResults.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath as IndexPath)
        
        cell.textLabel?.text = self.searchResults[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1 - Dismiss the SearchResultsController when a cell is selected
        self.dismiss(animated: true, completion: nil)
        
        // 2 - Contstruct the URL
        let urlpath = "https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyAGciCgaCaJjUZKnctBG3-m02vmMmPHU3k&address=\(self.searchResults[indexPath.row])&sensor=true".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

          let url = URL(string: urlpath!)
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            // 3 - If the code is a valid JSON then the code will retrieve the latitue and the longitude
            do {
                if data != nil{
                    let dic = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary

                    print("Dictionary is \(dic)")
                    
                    let lat = (((((dic.value(forKey: "results") as! NSArray).object(at: 0) as! NSDictionary).value(forKey: "geometry") as! NSDictionary).value(forKey: "location") as! NSDictionary).value(forKey: "lat")) as! Double
                    
                    print("Dictionary Lat is \(lat)")

                    let lon = (((((dic.value(forKey: "results") as! NSArray).object(at: 0) as! NSDictionary).value(forKey: "geometry") as! NSDictionary).value(forKey: "location") as! NSDictionary).value(forKey: "lng")) as! Double
                    
                    print("Dictionary Lon is \(lon)")


                    // 4 - Calling the delegate function
                    self.delegate.locateWithLongitude(lon: lon, andLatitude: lat, andTitle: self.searchResults[indexPath.row] )
                }
            }catch {
                print("Error")
            }
            
           
        }
        // 5 - Resume the task
        task.resume()
    }
    
    //MARK: Helper Methods
    
    //Refresh the table view inside the search results view with all the content from the searchResults data source array.
    func reloadDataWithArray(_ array:[String]){
        self.searchResults = array
        self.tableView.reloadData()
    }


}
