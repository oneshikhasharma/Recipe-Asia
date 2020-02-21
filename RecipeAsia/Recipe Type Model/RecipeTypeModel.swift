//
//  Recipe.swift
//  RecipeAsia
//
//  Created by Shikha Sharma on 2/7/20.
//  Copyright © 2020 Shikha Sharma. All rights reserved.
//


import UIKit

struct RecipeTypeModel {
    var id : Int
    var recipeType : String
    var recipeName : String
    var recipeIngredients : String
    var recipeInstructions : String
    var recipeImage : NSData
    
    init(id : Int, recipeType : String, recipeName : String, recipeIngredients : String, recipeInstructions : String, recipeImage : NSData){
        self.id = id
        self.recipeType = recipeType
        self.recipeName = recipeName
        self.recipeIngredients = recipeIngredients
        self.recipeInstructions = recipeInstructions
        self.recipeImage = recipeImage
    }
}
