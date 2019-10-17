//
//  MoviesViewController.swift
//  Movie
//
//  Created by Idris on 12/09/19.
//  Copyright © 2019 Idris-labs. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

class MoviesViewController: UIViewController {
    @IBOutlet weak var movieCollectionView: UICollectionView!
    
    let api = API()
    var selectedSegmentIndex = 0
    var listDataMovies:[MovieModel] = []
    var rowSelected:MovieModel?
    var movieID:String?
    let movieRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSelectedDataMovie(selected: selectedSegmentIndex)
        movieCollectionView.delegate = self
        movieCollectionView.dataSource = self
        movieRefreshControl.addTarget(self, action: #selector(refreshMovie), for: .valueChanged)
        movieCollectionView.addSubview(movieRefreshControl)
    }
    
    @objc func refreshMovie(){
        DispatchQueue.main.async {
            self.getSelectedDataMovie(selected: self.selectedSegmentIndex)
            self.movieRefreshControl.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getSelectedDataMovie(selected: selectedSegmentIndex)
    }
    
    func getSelectedDataMovie(selected:Int){
        switch selectedSegmentIndex {
        case 0:
            getDataMovie(category: "now_playing")
        case 1:
            getDataMovie(category: "popular")
        default:
            getDataMovie(category: "now_playing")
        }
    }
    
    func getDataMovie(category:String){
        SVProgressHUD.show()
        Alamofire.request(api.API_URL+"movie/\(category)?api_key=\(api.API_KEY)&language=en-US&page=1").responseJSON { (response) in
            if response.result.isSuccess{
                let jsonDictionary = response.result.value as! [String:Any]
                let listMovie = jsonDictionary["results"] as! [[String:Any]]
                if listMovie.count > 0{
                    self.listDataMovies = []
                    for item in listMovie{
                        let stringImage = item["poster_path"] as! String
                        let movieTitle = item["original_title"] as! String
                        let movieID = item["id"] as! NSNumber
                        if let dataImage = try? Data(contentsOf:NSURL(string: "http://image.tmdb.org/t/p/w500"+stringImage)! as URL){
                            self.listDataMovies.append(MovieModel(movieImage: UIImage(data: dataImage)!,movieID: movieID.stringValue, movieTitle: movieTitle ))
                        }
                    }
                    DispatchQueue.main.async {
                        self.movieCollectionView.reloadData()
                        SVProgressHUD.dismiss()
                    }
                }
            }
        }
    }
    @IBAction func movieSegmented(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                selectedSegmentIndex = 0
                getSelectedDataMovie(selected: selectedSegmentIndex)
            case 1:
                selectedSegmentIndex = 1
                getSelectedDataMovie(selected: selectedSegmentIndex)
            default:
                selectedSegmentIndex = 0
                getSelectedDataMovie(selected: selectedSegmentIndex)
        }
    }
}
extension MoviesViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listDataMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = movieCollectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCollectionViewCell
        cell.movieImage.image = listDataMovies[indexPath.row].movieImage
        cell.originalTitle.text = listDataMovies[indexPath.row].movieTitle
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        cell.layer.shadowRadius = 8.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        movieID = listDataMovies[indexPath.row].movieID
        performSegue(withIdentifier: "GoToDetailMovie", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToDetailMovie" {
            let detailVC = segue.destination as! DetailViewController
            detailVC.movieID = movieID
            detailVC.category = "movie"
        }
    }
}
