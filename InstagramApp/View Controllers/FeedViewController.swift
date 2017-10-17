//
//  FeedViewController.swift
//  InstagramApp
//
//  Created by Hamid Hoseini on 10/14/17.
//  Copyright © 2017 Hamid Hoseini. All rights reserved.
//

import UIKit
import Firebase

class FeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var posts = [Post]()
    var following = [String]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchPost()
    }
    
    func fetchPost() {
        let ref = Database.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: {snapshot in
            let users = snapshot.value as! [String: AnyObject]
            
            for (_, value) in users {
                if let uid = value["uid"] as? String {
                    if uid == Auth.auth().currentUser?.uid {
                        if let followingUsers = value["following"] as? [String: String]{
                            for (_, user) in followingUsers {
                                self.following.append(user)
                            }
                        }
                        self.following.append(Auth.auth().currentUser!.uid)
                        
                        ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with: {snap in
                            let postSnap = snap.value as! [String: AnyObject]
                            
                            for (_, post) in postSnap {
                                if let userID = post["userID"] as? String {
                                    for each in self.following {
                                        if each == userID {
                                            let postOfArray = Post()
                                            if let author = post["author"] as? String, let likes = post["likes"] as? Int,
                                                let pathToImage = post["pathToImage"] as? String, let postID = post["postID"
                                                ] as? String {
                                                postOfArray.author = author
                                                postOfArray.likes = likes
                                                postOfArray.pathToImage = pathToImage
                                                postOfArray.postID = postID
                                                postOfArray.userID = userID
                                                
                                                if let people = post["peopleWhoLike"] as? [String : AnyObject] {
                                                    for (_, person) in people {
                                                        postOfArray.peopleWhoLike.append(person as! String)
                                                    }
                                                }
                                                self.posts.append(postOfArray)
                                            }
                                        }
                                    }
                                    self.collectionView.reloadData()
                                }
                            }
                        })
                        
                    }
                }
            }
        })
        ref.removeAllObservers()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! PostCell
        cell.postImage.downloadImage(from: self.posts[indexPath.row].pathToImage)
        cell.authorLabel.text = self.posts[indexPath.row].author
        cell.likesLabel.text = "\(self.posts[indexPath.row].likes!) likes"
        cell.postID = self.posts[indexPath.row].postID
        
        for person in self.posts[indexPath.row].peopleWhoLike {
            if person == Auth.auth().currentUser!.uid {
                cell.likeBtn.isHidden = true
                cell.unlikeBtn.isHidden = false
                break;
            }
        }
        
        return cell
    }

}
