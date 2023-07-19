//
//  APICaller.swift
//  TheNewsApp
//
//  Created by Edu Caubilla on 19/07/2023.
//

import Foundation


final class APICaller{
    
    static let shared = APICaller()
    
    struct Constants {
        static let topHeadlinesURL = URL(string: "https://newsapi.org/v2/everything?q=tech&apiKey=d01cca23bd74436e97f0f38a83dc79d1")
    }
    
    private init(){}
    
    public func getTopStories(completion: @escaping (Result<[Article], Error>) -> Void){
        guard let url = Constants.topHeadlinesURL else{
            return
        }
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: {data, _, error in
            if let error = error{
                completion(.failure(error))
            }
            else if let data = data {
                do{
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                
                    print("Articles: \(result.articles.count)")
                    
                    completion(.success(result.articles))
                }
                catch{
                    completion(.failure(error))
                }
            }
        })
        
        task.resume()
    }
}

//Models

// MARK: - APIResponse
struct APIResponse: Codable {
    let articles: [Article]
}

// MARK: - Article
struct Article: Codable {
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String
    let content: String
}

// MARK: - Source
struct Source: Codable {
    let name: String
}
