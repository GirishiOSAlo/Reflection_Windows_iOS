//
//  CustomizeDataModel.swift
//  Reflection Windows
//
//  Created by Girish Bhuva on 20/03/24.
//

import Foundation

// MARK: - Welcome
struct CustomizeDataModel: Codable {
    let data: CustomizeDataResult?
    let success: Bool?
    let message: String?
    let statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case data, success, message
        case statusCode = "status_code"
    }
}

// MARK: - DataClass
struct CustomizeDataResult: Codable {
    let products: [CustomizerProduct]?
    let customizer: CustomizerData?
    let dimensions: [CustomizerDimension]?
    let baseImageURL: String?
    let dimensionDetails: DimensionInfoDetails?
    
    enum CodingKeys: String, CodingKey {
        case products, customizer, dimensions
        case baseImageURL = "base_image_url"
        case dimensionDetails = "dimension_details"
    }
}

// MARK: - Customizer
struct CustomizerData: Codable {
    let glass, colors, anchorage: [CustomizerCategoryDetails]?
}

// MARK: - DimensionDetails
struct DimensionInfoDetails: Codable {
    let dimensionInstructions, dimensionInstructionImage, dimensionInstructionVideo: String?

    enum CodingKeys: String, CodingKey {
        case dimensionInstructions = "dimension_instructions"
        case dimensionInstructionImage = "dimension_instruction_image"
        case dimensionInstructionVideo = "dimension_instruction_video"
    }
}

// MARK: - Anchorage
struct CustomizerCategoryDetails: Codable {
    let id: Int?
    let name: String?
    let image: String?
    let price: String?
    let displayPrice: Int?
    let selected, defaultSelected: Bool?
    let instruction, instructionImage: String?
    let options: [SubOption]?
    let code: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, image, price
        case displayPrice = "display_price"
        case selected
        case defaultSelected = "default_selected"
        case instruction
        case instructionImage = "instruction_image"
        case options, code
    }
}

// MARK: - Option
struct SubOption: Codable {
    let id: Int?
    let name, price: String?
    let displayPrice: Int?
    let instruction, instructionImage: String?
    let selected: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, price
        case displayPrice = "display_price"
        case instruction
        case instructionImage = "instruction_image"
        case selected
    }
}

// MARK: - Dimension
struct CustomizerDimension: Codable {
    var cartCount: Int?
    var width, height: String?

    enum CodingKeys: String, CodingKey {
        case cartCount = "cart_count"
        case width, height
    }
}

// MARK: - Product
struct CustomizerProduct: Codable {
    let id: Int?
    let productName, productID, price: String?
    let categoryID: Int?
    let categoryName, description, longDescription: String?
    let productImage: String?
    let selected, defaultSelected: Bool?
    let minWidth, maxWidth, minHeight, maxHeight: String?
    let isSwing, leftSwing, rightSwing: Int?
    let isLeftSwingSelected, isRightSwingSelected: Int?
    let instruction, instructionImage: String?
    let insectMesh, isInsectMeshVisible: Bool?
    let images: [String]?
    
    var isLeftSelected, isRightSelected: Bool?

    enum CodingKeys: String, CodingKey {
        case id, isLeftSelected, isRightSelected
        case productName = "product_name"
        case productID = "productId"
        case price
        case categoryID = "category_id"
        case categoryName = "category_name"
        case description
        case longDescription = "long_description"
        case productImage = "product_image"
        case selected
        case defaultSelected = "default_selected"
        case minWidth = "min_width"
        case maxWidth = "max_width"
        case minHeight = "min_height"
        case maxHeight = "max_height"
        case isSwing = "is_swing"
        case leftSwing = "left_swing"
        case rightSwing = "right_swing"
        case isLeftSwingSelected = "is_left_swing_selected"
        case isRightSwingSelected = "is_right_swing_selected"
        case instruction
        case instructionImage = "instruction_image"
        case insectMesh = "insect_mesh"
        case isInsectMeshVisible, images
    }
}
