//
//  PostListViewController.swift
//  PostIOS23
//
//  Created by Jack Knight on 12/17/18.
//  Copyright © 2018 Jack Knight. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var postController = PostController()
    var refreshControl: UIRefreshControl?
    
    @IBOutlet weak var postTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postController.fetchPosts {
            self.reloadTableView()
            }
        postTableView.delegate = self
        postTableView.dataSource = self
        postTableView.estimatedRowHeight = 45
        postTableView.refreshControl = refreshControl
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        presentNewPostAlert()
    }
    
    @objc func refreshControlPulled() {
        refreshControl?.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        postController.fetchPosts {
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.postTableView.reloadData()
           UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
}
    
    
    
    //Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        let post = postController.posts[indexPath.row]
        cell.textLabel?.text = post.username
        cell.detailTextLabel?.text = post.date
        
        return cell
    }
    
    func presentNewPostAlert() {
        
        let alertController = UIAlertController(title: "New Post", message: "", preferredStyle: .alert)
        
        var usernameTextField = UITextField()
        alertController.addTextField { (username) in
            username.placeholder = "Enter unsername..."
            usernameTextField = username
        }
        var messageTextField = UITextField()
        alertController.addTextField { (message) in
            message.placeholder = "Enter Message..."
            messageTextField = message
        }
        let postAction = UIAlertAction(title: "Post", style: .default) { (postAction) in
             guard let username = usernameTextField.text,
                let text = messageTextField.text else { return
                    
            }
        
        self.postController.addNewPostWith(username: username, text: text) {
            self.reloadTableView()
        }
    }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(postAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        }
}

extension PostListViewController {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= postController.posts.count - 1 {
            postController.fetchPosts (reset: false) {
                tableView.reloadData()
            }
        }
    }
}
