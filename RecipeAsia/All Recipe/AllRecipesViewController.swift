//
//  AllRecipiesViewController.swift
//  RecipeAsia
//
//  Created by Shikha Sharma on 2/7/20.
//  Copyright © 2020 Shikha Sharma. All rights reserved.
//


import UIKit
import CoreData
import DropDown

class AllRecipesViewController: UIViewController {
    
    @IBOutlet var recipesCollectionView : UICollectionView!
    
    var recipes : [Recipe] = []
    var recipeArray : [String] = []
    var recipeModel : [RecipeTypeModel] = []
    var recipeModel1 : [RecipeTypeModel] = []
    
    @IBOutlet var filterDropDown : UILabel!
    
    var recipeCategory : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fectch all recipe types xml files
        for recipeTitle in recipes {
            recipeArray.append(recipeTitle.recipeTitle)
        }
    }
    
    //MARK: View appears on window
    override func viewWillAppear(_ animated: Bool) {
        
        retrieveData() // fetch all recipes
        
        if recipeCategory != "" // check if recipe category is not empty, show filtered recipe else all recipes will be shown
        {
            self.recipeModel =  self.recipeModel1.filter{ ($0.recipeType == recipeCategory) }
            self.recipesCollectionView.reloadData()
            self.filterDropDown.text = recipeCategory
            
        }
    }
    
    //MARK: Filter recipes on category bases
    @IBAction func filterBtnAction(_ sender: UIButton)
    {
        let dropDown = DropDown()
        dropDown.anchorView = sender
        dropDown.dataSource = recipeArray
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            
            // Filter recipe to new object on recipe category basis
            self.recipeModel =  self.recipeModel1.filter{ ($0.recipeType == self.recipeArray[index]) }
            self.recipesCollectionView.reloadData()
            
            self.filterDropDown.text = self.recipeArray[index]
            dropDown.hide()
        }
        dropDown.width = sender.frame.width
        dropDown.show()
        
    }
    
    //MARK: Fetch all recipes functions
    func retrieveData(){
        
        // empty both recipe models to populate with updates data
        recipeModel.removeAll()
        recipeModel1.removeAll()
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Recipes")
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject]{
                if let imageData = data.value(forKey: "recipe_image") as? NSData {
                    
                    // Populate recipe model
                    recipeModel.append(RecipeTypeModel(id: data.value(forKey: "id") as! Int, recipeType: data.value(forKey: "recipe_type") as? String ?? "NA", recipeName: data.value(forKey: "recipe_name") as? String ?? "NA", recipeIngredients: data.value(forKey: "recipe_ingredients") as! String, recipeInstructions: data.value(forKey: "recipe_instructions") as! String, recipeImage: imageData))
                    
                    recipeModel1.append(RecipeTypeModel(id: data.value(forKey: "id") as! Int, recipeType: data.value(forKey: "recipe_type") as? String ?? "NA", recipeName: data.value(forKey: "recipe_name") as? String ?? "NA", recipeIngredients: data.value(forKey: "recipe_ingredients") as! String, recipeInstructions: data.value(forKey: "recipe_instructions") as! String, recipeImage: imageData))
                    
                    self.recipesCollectionView.reloadData()
                }
            }
        } catch {
            print("Failed")
        }
    }
    
    
    //MARK: Perform segues (Actions, Data)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is RecipeDetailViewController{
            let vc = segue.destination as? RecipeDetailViewController
            vc?.recipeModel = recipeModel[sender as? Int ?? 0]
        }else{
            let vc = segue.destination as? CreateNewRecipeViewController
            vc?.recipes = recipes
        }
    }
}

//MARK: Collection View Delegates
extension AllRecipesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipeModel.count // Item count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell : AllRecipeCollectionViewCell = recipesCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AllRecipeCollectionViewCell
        
        let recipe = recipeModel[indexPath.row] // Get data from recipe model at index row, populate collection view
        cell.recipeName.text = recipe.recipeName
        if let image = UIImage(data:recipe.recipeImage as Data) {
            cell.recipeImage.image = image
        }
        
        return cell
    }
    
    // perform segue on cell selection to show detail screen
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "recipe_detail", sender: indexPath.row)
    }
    
    // set collection view cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  3
        let collectionViewSize = recipesCollectionView.frame.size.width / 3 - padding
        return CGSize(width: collectionViewSize, height: collectionViewSize)
    }
}
