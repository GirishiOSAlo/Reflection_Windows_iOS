//
//  FAQDataModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 09/09/24.
//

import Foundation

import Foundation

// MARK: - Welcome
struct FAQDataModel: Codable {
    let data: [FAQData]?
    let success: Bool?
    let message: String?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - Datum
struct FAQData: Codable {
    let id: Int?
    let title, createdAt, updatedAt: String?
    let deletedAt: String?
    var faqs: [FAQ]?

    enum CodingKeys: String, CodingKey {
        case id, title
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case faqs
    }
}

// MARK: - FAQ
struct FAQ: Codable {
    let id, faqsTypeMasterID: Int?
    let questions, answers: String?
    let createdAt, updatedAt: String?
    let deletedAt: String?
    var isExpanded: Bool = false  

    enum CodingKeys: String, CodingKey {
        case id
        case faqsTypeMasterID = "faqs_type_master_id"
        case questions, answers
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}
