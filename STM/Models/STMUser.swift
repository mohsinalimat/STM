//
//  STMUser.swift
//  STM
//
//  Created by Kesi Maduka on 1/30/16.
//  Copyright © 2016 Storm Edge Apps LLC. All rights reserved.
//

import Foundation
import Gloss

struct STMUser: JSONDecodable {

    let id: Int
    let username: String
    let displayName: String?
    let description: String?
    let isFollowing: Bool
    let isFollower: Bool

    var photoSignature: String

    // MARK: - Deserialization

    init?(json: JSON) {
        guard let id: Int = "id" <~~ json else {
            return nil
        }

        self.id = id
        self.username = ("username" <~~ json ?? "null")
        self.displayName = "displayName" <~~ json
        self.description = "description" <~~ json
        self.isFollowing = ("isFollowing" <~~ json) ?? false
        self.isFollower = ("isFollower" <~~ json) ?? false
        self.photoSignature = ("photoSignature" <~~ json) ?? ""
    }

    func profilePictureURL() -> URL? {
        return URL(string: Constants.Config.apiBaseURL + "/user/\(id)/profilePicture?sig=\(photoSignature)")
    }

}

func == (lhs: STMUser, rhs: STMUser) -> Bool {
    return lhs.id == rhs.id
}
