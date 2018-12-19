//
//  PostController.swift
//  PostIOS23
//
//  Created by Jack Knight on 12/17/18.
//  Copyright © 2018 Jack Knight. All rights reserved.
//

import UIKit

class PostController {
    
    let baseURL = URL(string: "https://devmtn-posts.firebaseio.com/posts")
    
    var posts = [Post]()
    
    func fetchPosts(reset: Bool = true, completion: @escaping () -> Void){
       
        let queryendInterval = reset ? Date().timeIntervalSince1970 : posts.last?.queryTimestamp ?? Date().timeIntervalSince1970
        
        let urlParameters = [
            "orderBy" : "\"timestamp\"",
            "endAt": "\(queryendInterval)",
            "limitToLast" : "15",
        ]
        
        let queryItems = urlParameters.compactMap( {URLQueryItem(name: $0.key, value: $0.value) } )
        
        guard let unwrappedurl = self.baseURL else { completion (); fatalError("URL optional is nil")}
        
        var urlComponents = URLComponents(url: unwrappedurl, resolvingAgainstBaseURL: true)
        
        guard let url = urlComponents?.url else {completion(); return}
       
        let getterEndpoint = url.appendingPathExtension("json")
       
        urlComponents?.queryItems = queryItems
        
       var request = URLRequest(url: getterEndpoint)
        request.httpBody = nil
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print(error)
                completion()
                return
            }
            guard let data = data else { completion()
                return
            }
            
            //decode
            let jsondecoder = JSONDecoder()
            do {
                let postsDictionary = try jsondecoder.decode([String: Post].self, from: data)
                let posts: [Post] = postsDictionary.compactMap({ $0.value })
                let sortedPosts = posts.sorted(by: { $0.timestamp > $1.timestamp})
                if reset {
                self.posts = sortedPosts
                } else {
                    self.posts.append(contentsOf: sortedPosts)
                }
                    completion()
                
            } catch {
                print("Error retrieving posts from \(getterEndpoint)")
                completion()
                return
                
            }
        }
        dataTask.resume()
    }
    
    func addNewPostWith(username: String, text: String, completion: @escaping () -> Void) {
        
        let post = Post(username: username, text: text)
        var postData: Data
        do {
            let jsonencoder = JSONEncoder()
            postData =  try jsonencoder.encode(post)
        } catch {
            print("Error adding new post ; (\(error.localizedDescription)")
            completion()
            return
        }
        guard let unwrappedURL = baseURL else {return}
        let postEndpoint = unwrappedURL.appendingPathExtension("json")
        
        var request = URLRequest(url: postEndpoint)
        request.httpMethod = "POST"
        request.httpBody = postData
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print(error)
                completion()
                return
            }
            guard let data = data else { completion()
                return
            }
            print(String(data: data, encoding: .utf8) ?? "There was an error")
            self.fetchPosts(completion: {
                completion()
            })
        }
        dataTask.resume()
    }
    
}
