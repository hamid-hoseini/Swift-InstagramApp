//
//  Post.swift
//  InstagramApp
//
//  Created by Hamid Hoseini on 10/14/17.
//  Copyright © 2017 Hamid Hoseini. All rights reserved.
//

import UIKit

class Post: NSObject {
    var author: String!
    var likes: Int!
    var pathToImage: String!
    var userID: String!
    var postID: String!
    var peopleWhoLike: [String] = [String]()
}
