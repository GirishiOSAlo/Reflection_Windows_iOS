//
//  ResourcesDetailModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 08/03/24.
//

import Foundation

// MARK: - Welcome
struct ResourcesDetailModel: Codable {
    let data: ResourcesDetailData?
    let success: Bool?
    let message: String?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct ResourcesDetailData: Codable {
    let resources: [ResourcesCatData]?
}

// MARK: - DataResource
struct ResourcesCatData: Codable {
    let id: Int?
    let name: String?
    let resources: [ResourceCatDetail]?
}

// MARK: - ResourceResource
struct ResourceCatDetail: Codable {
    let id: Int?
    let name: String?
    let image: String?
    let url: String?
    let resourcesCategoryID: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, image, url
        case resourcesCategoryID = "resources_category_id"
    }
}
