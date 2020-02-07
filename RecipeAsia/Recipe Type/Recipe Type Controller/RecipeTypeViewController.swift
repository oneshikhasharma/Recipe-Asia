//
//  RecipeTypeViewController.swift
//  RecipeAsia
//
//  Created by Shikha Sharma on 2/7/20.
//  Copyright © 2020 Shikha Sharma. All rights reserved.
//

import UIKit

struct Recipe {
    var recipeTitle: String
}

class RecipeTypeViewController: UIViewController {
    
    @IBOutlet var recipeTypeCollectionView : UICollectionView!
    var recipes : [Recipe] = []
    var recipeTitle = String()
    var elementName: String = String()
    
    var recipeCategory : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = Bundle.main.url(forResource: "recipetypes", withExtension: "xml") {
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                parser.parse()
            }
        }
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func allRecipeBtnAction(_ sender: UIButton)
    {
        self.performSegue(withIdentifier: "allrecipe", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AllRecipesViewController {
            let vc = segue.destination as? AllRecipesViewController
            vc?.recipes = recipes
            vc?.recipeCategory = recipeCategory
        }
    }
}

extension RecipeTypeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell : RecipeTypeCollectionViewCell = recipeTypeCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! RecipeTypeCollectionViewCell
        let recipe = recipes[indexPath.row]
        cell.recipeTypeName.text = recipe.recipeTitle
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  5
        let collectionViewSize = recipeTypeCollectionView.frame.size.width - padding
        return CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        let recipe = recipes[indexPath.row]
        recipeCategory = recipe.recipeTitle
            
        self.performSegue(withIdentifier: "allrecipe", sender: self)
    }
}

extension RecipeTypeViewController : XMLParserDelegate
{
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        if elementName == "recipe" {
            recipeTitle = String()
        }
        
        self.elementName = elementName
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "recipe" {
            let recipe = Recipe(recipeTitle: recipeTitle)
            recipes.append(recipe)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if (!data.isEmpty) {
            if self.elementName == "title" {
                recipeTitle += data
            }
        }
    }
    
}
