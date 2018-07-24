//
//  Author.swift
//  Buzzler
//
//  Created by 진형탁 on 24/07/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import RxDataSources
import ObjectMapper

public struct Author: Equatable, Mappable {
    
    var id: Int = 0
    var username: String = ""

    public static func == (lhs: Author, rhs: Author) -> Bool {
        return lhs.id == rhs.id ? true : false
    }
    
    public init?(map: Map) { }
    
    init() { }
    
    mutating public func mapping(map: Map) {
        id <- map["id"]
        username <- map["username"]
    }
    
    init(id: Int, username: String) {
        self.id = id
        self.username = username
    }
    
}

