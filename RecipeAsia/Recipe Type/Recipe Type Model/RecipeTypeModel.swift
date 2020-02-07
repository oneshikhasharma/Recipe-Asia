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
    var ingredients : String
    var steps : String
    var image : NSData
    
    init(id : Int, recipeType : String, recipeName : String, ingredients : String, steps : String, image : NSData){
        self.id = id
        self.recipeType = recipeType
        self.recipeName = recipeName
        self.ingredients = ingredients
        self.steps = steps
        self.image = image
    }
}
