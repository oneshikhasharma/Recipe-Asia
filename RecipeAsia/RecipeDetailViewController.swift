//
//  RecipeDetailViewController.swift
//  RecipeAsia
//
//  Created by Shikha Sharma on 2/8/20.
//  Copyright © 2020 Shikha Sharma. All rights reserved.
//

import UIKit
import CoreData
import SkyFloatingLabelTextField
import Photos
import DropDown
import Toast_Swift

class RecipeDetailViewController: UIViewController {
    
    @IBOutlet var recipesImageView : UIImageView!
    @IBOutlet var recipeCategoryLbl : UILabel!
    @IBOutlet var recipeNameTF : SkyFloatingLabelTextField!
    @IBOutlet var recipesIngredientsTV : UITextView!
    @IBOutlet var recipesInstructionsTV : UITextView!
    
    var recipeModel : RecipeTypeModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipeCategoryLbl.text = recipeModel?.recipeType ??  "NA"
        recipeNameTF.text = recipeModel?.recipeName ?? "NA"
        recipesInstructionsTV.text = recipeModel?.steps ?? "NA"
        recipesIngredientsTV.text = recipeModel?.ingredients ?? "NA"
        if let image = UIImage(data:recipeModel!.image as Data) {
            recipesImageView.image = image
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backBtnAction(_ sender: UIButton)
       {
           self.dismiss(animated: true, completion: nil)
       }
}
