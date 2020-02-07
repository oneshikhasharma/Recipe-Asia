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
        
        for recipeTitle in recipes {
            recipeArray.append(recipeTitle.recipeTitle)
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        retrieveData()
        
        
        if recipeCategory != ""
        {
            self.recipeModel =  self.recipeModel1.filter{ ($0.recipeType == recipeCategory) }
            self.recipesCollectionView.reloadData()
            self.filterDropDown.text = recipeCategory
            
        }
    }
    @IBAction func filterBtnAction(_ sender: UIButton)
    {
        let dropDown = DropDown()
        dropDown.anchorView = sender
        dropDown.dataSource = recipeArray
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            
            self.recipeModel =  self.recipeModel1.filter{ ($0.recipeType == self.recipeArray[index]) }
            self.recipesCollectionView.reloadData()
            
            self.filterDropDown.text = self.recipeArray[index]
            dropDown.hide()
        }
        dropDown.width = sender.frame.width
        dropDown.show()
        
    }
    
    
    func retrieveData(){
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
                if let imageData = data.value(forKey: "image") as? NSData {
                    recipeModel.append(RecipeTypeModel(id: data.value(forKey: "id") as! Int, recipeType: data.value(forKey: "recipe_type") as? String ?? "NA", recipeName: data.value(forKey: "recipe_name") as? String ?? "NA", ingredients: data.value(forKey: "ingredients") as! String, steps: data.value(forKey: "steps") as! String, image: imageData))
                    
                    recipeModel1.append(RecipeTypeModel(id: data.value(forKey: "id") as! Int, recipeType: data.value(forKey: "recipe_type") as? String ?? "NA", recipeName: data.value(forKey: "recipe_name") as? String ?? "NA", ingredients: data.value(forKey: "ingredients") as! String, steps: data.value(forKey: "steps") as! String, image: imageData))
                    
                    self.recipesCollectionView.reloadData()
                }
            }
        } catch {
            print("Failed")
        }
    }
    
    
    
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

extension AllRecipesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipeModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell : AllRecipeCollectionViewCell = recipesCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AllRecipeCollectionViewCell
        let recipe = recipeModel[indexPath.row]
        cell.recipeName.text = recipe.recipeName
        if let image = UIImage(data:recipe.image as Data) {
            cell.recipeImage.image = image
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "recipe_detail", sender: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  3
        let collectionViewSize = recipesCollectionView.frame.size.width / 3 - padding
        return CGSize(width: collectionViewSize, height: collectionViewSize)
    }
}
