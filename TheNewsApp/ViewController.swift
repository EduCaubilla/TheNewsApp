//
//  ViewController.swift
//  TheNewsApp
//
//  Created by Edu Caubilla on 19/07/2023.
//

import UIKit
import SafariServices

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    //TableView init
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        return table
    }()
    
    private let searchVC = UISearchController(searchResultsController: nil)
    
    private var articles = [Article]()
    private var viewModels = [NewsTableViewCellViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TableView first config
        title = "Technology News"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorColor = UIColor.systemGray5
        
        fetchNewsFeed()
        createSearchBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func createSearchBar(){
        navigationItem.searchController = searchVC
        searchVC.searchBar.delegate = self
    }
    
    private func fetchNewsFeed(){
        //API call for data
        APICaller.shared.getTopStories { [weak self] result in
            switch result{
            case .success(let articles):
                self?.articles = articles
                
                self?.viewModels = articles.compactMap({
                    NewsTableViewCellViewModel(title: $0.title ?? "No title",
                                               subtitle: $0.description ?? "No description",
                                               imageURL: URL(string: $0.urlToImage ?? ""),
                                               date: APICaller.shared.convertStringToDate(strDate: $0.publishedAt))
                })
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print ("There was an error calling the API -> \(error)")
            }
        }
    }
    
    //TableView config

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewsTableViewCell.identifier,
            for: indexPath
        ) as? NewsTableViewCell else {
                fatalError()
            }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at:indexPath, animated: true)
        let article = articles[indexPath.row]
        
        guard let url = URL(string: article.url ?? "") else{
            return
        }
        
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    // Search
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else{
            return
        }
        
        APICaller.shared.getSearchNews(with: text) { [weak self] result in
        switch result{
            case .success(let articles):
                self?.articles = articles
                self?.viewModels = articles.compactMap({
                    NewsTableViewCellViewModel(title: $0.title ?? "No title",
                                               subtitle: $0.description ?? "No description",
                                               imageURL: URL(string: $0.urlToImage ?? ""),
                                               date: APICaller.shared.convertStringToDate(strDate: $0.publishedAt))
                })

                DispatchQueue.main.async {
                    self?.title = "\(text) News"
                    self?.tableView.reloadData()
                    
                    //Remove keyboard from view
                    self?.searchVC.dismiss(animated: true, completion: nil)
                }
            case .failure(let error):
                print ("There was an error calling the API -> \(error)")
            }
        }
    }
}

