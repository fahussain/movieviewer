//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Faheem Hussain on 10/16/16.
//  Copyright © 2016 Faheem Hussain. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorLabel: UILabel!
    
    
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    var endpoint: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        networkErrorLabel.isHidden = true
        // Do any additional setup after loading the view.
        
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let stringUrl = "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)"
        let url = URL(string:stringUrl)
        let request = URLRequest(url: url!)
        let urlConfig = URLSessionConfiguration.default
        // Reduce timeout to show error
        urlConfig.timeoutIntervalForRequest = 3
        urlConfig.timeoutIntervalForResource = 3
        let session = URLSession(
            configuration: urlConfig,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, responseOrNil, errorOrNil) in
            if let requestError = errorOrNil {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.networkErrorLabel.isHidden = false;
            }else {
                if let data = dataOrNil {
                    if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                        
                        self.movies = responseDictionary["results"] as! [NSDictionary]
                        self.tableView.reloadData()
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }
                }
            }
            
            
        });
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let moviesData = movies {
            return moviesData.count
        }else {
            return 0
        }
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let overview = movie["overview"] as! String
        let imageBaseUrl = "http://image.tmdb.org/t/p/w500"
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        if let posterPath = movie["poster_path"] as? String{
            let posterUrl = NSURL(string: imageBaseUrl + posterPath)
            cell.posterView.setImageWith(posterUrl! as URL)
            
        }
    
        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
    }
    

}
