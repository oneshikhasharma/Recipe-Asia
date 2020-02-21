//
//  CreateNewRecipeViewController.swift
//  RecipeAsia
//
//  Created by Shikha Sharma on 2/7/20.
//  Copyright © 2020 Shikha Sharma. All rights reserved.
//

import UIKit
import CoreData
import SkyFloatingLabelTextField
import Photos
import DropDown
import Toast_Swift

class CreateNewRecipeViewController: UIViewController {
    
    @IBOutlet var recipesImageView : UIImageView!
    @IBOutlet var uploadImageBtn : UIButton!
    @IBOutlet var recipeCategoryLbl : UILabel!
    @IBOutlet var recipeNameTF : SkyFloatingLabelTextField!
    @IBOutlet var recipesIngredientsTV : UITextView!
    @IBOutlet var recipesInstructionsTV : UITextView!
    @IBOutlet var addRecipeBtn : UIButton!
    
    var imagePicker = UIImagePickerController()
    var recipe: [NSManagedObject] = []
    var isPresentAlready : Bool = false
    var recipeID : Int = 0
    var recipeModel : RecipeTypeModel?
    var recipes : [Recipe] = []
    var recipeCategoryArray : [String] = []
    
    var dropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: fetch recipe title
        for recipeTitle in recipes {
            recipeCategoryArray.append(recipeTitle.recipeTitle)
        }
        
        // MARK: Keyboard Manager for textview fields
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreateNewRecipeViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIWindow.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIWindow.keyboardWillShowNotification, object: nil)
        
    }
    
    // Removes notification observer when view goes out of window
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Keyboard will appear
    @objc func keyboardWillAppear(_ notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    // MARK: Keyboard will disappear
    @objc func keyboardWillDisappear(_ notification: NSNotification) {
        
        // set view origin to 0 to keep the frame aligned withh the window
        self.view.frame.origin.y = 0
        
    }
    
    // MARK: Textfield resigns from action
    func textFieldShouldReturn(_ textField: UITextView) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    
    // MARK: Dismiss keyboard on touch or Notification Action call
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Check if recipe is already present, fetch recipe details and set data
        if (isPresentAlready){
            if let image = UIImage(data:recipeModel!.recipeImage as Data){
                recipesImageView.image = image
            }
            recipeNameTF.text = recipeModel?.recipeName
            recipesIngredientsTV.text = recipeModel?.recipeIngredients
            recipesInstructionsTV.text = recipeModel?.recipeInstructions
            
        }
    }
    
    // MARK: Select recipe category
    @IBAction func selectRecipeCategoryBtnAction(_ sender: UIButton)
    {
        dropDown.anchorView = sender
        dropDown.dataSource = recipeCategoryArray
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            
            self.recipeCategoryLbl.text = self.recipeCategoryArray[index]
            
            self.dropDown.hide()
        }
        dropDown.width = sender.frame.width
        dropDown.show()
        
    }
    
    // MARK: Select recipe picture
    @IBAction func uploadRecipePhoto(_ sender : UIButton){
        imagePicker.delegate = self
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.openCamera() // Opens Camera
        }))
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { _ in
            self.openGallary() // Opens Gallery
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        /*If you want work actionsheet on ipad
         then you have to use popoverPresentationController to present the actionsheet,
         otherwise app will crash on iPad */
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: Add recipe
    @IBAction func addRecipeBtnAction(_ sender: UIButton)
    {
        // Validating all inputs
        if check(forBlanks: recipeNameTF) {
            self.view.makeToast("Please enter valid name.")
        }  else  if check(forBlanks: recipesInstructionsTV) {
            self.view.makeToast( "Please enter valid instructions.")
        }
        else  if check(forBlanks: recipesIngredientsTV) {
            self.view.makeToast( "Please enter valid ingredients." )
        }
        else  if check(forBlanks: recipesImageView) {
            self.view.makeToast( "Please select an image." )
        }
        else  if check(forBlanks: recipeCategoryLbl) {
            self.view.makeToast( "Please select a recipe type." )
        }
        else {
            
            // Check if already present then update recipe or else create new recipe
            if isPresentAlready {
                addNewRecipe()
            } else {
                updateRecipe(name: recipeNameTF.text!, email: recipesIngredientsTV.text!, others: recipesInstructionsTV.text!)
            }
        }
    }
    
    
    // MARK: – Database operation Methods
    func updateRecipe(name: String , email: String, others: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        recipeID = recipeID + 1
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Recipes", in: managedContext)!
        let recipeObj = NSManagedObject(entity: entity, insertInto: managedContext)
        recipeObj.setValue(recipeID, forKeyPath: "id")
        recipeObj.setValue(recipeCategoryLbl.text, forKeyPath: "recipe_type")
        recipeObj.setValue(recipeNameTF.text, forKeyPath: "recipe_name")
        recipeObj.setValue(recipesIngredientsTV.text, forKeyPath: "recipe_ingredients")
        recipeObj.setValue(recipesInstructionsTV.text, forKeyPath: "recipe_instructions")
        recipeObj.setValue(recipesImageView.image!.jpegData(compressionQuality: 1), forKey: "recipe_image")
        do {
            try managedContext.save()
            recipe.append(recipeObj)
            self.view.makeToast("Your recipe has been saved sucessfully!!")
            
            self.dismiss(animated: true, completion: nil)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    // MARK: Add new recipe function
    func addNewRecipe(){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Recipes")
        fetchRequest.predicate = NSPredicate(format:"id = %d", recipeModel?.id ?? 0)
        do
        {
            let test = try managedContext.fetch(fetchRequest)
            
            let recipeObj = test[0] as! NSManagedObject
            recipeObj.setValue(recipeNameTF.text, forKeyPath: "recipe_name")
            recipeObj.setValue(recipesIngredientsTV.text, forKeyPath: "recipe_ingredients")
            recipeObj.setValue(recipesInstructionsTV.text, forKeyPath: "recipe_instructions")
            recipeObj.setValue(recipesImageView.image!.jpegData(compressionQuality: 1), forKey: "recipe_image")
            do{
                try managedContext.save()
            }
            catch
            {
                print(error)
            }
        }
        catch
        {
            print(error)
        }
        
    }
    
    // MARK: Back button action
    @IBAction func backBtnAction(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    
   // MARK: Validate textfield input
    func check(forBlanks textfield: UITextField) -> Bool{
        let rawString: String? = textfield.text
        let whitespace = CharacterSet.whitespacesAndNewlines
        let trimmed: String? = rawString?.trimmingCharacters(in: whitespace)
        if (trimmed?.count ?? 0) == 0 {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Validate textView input
    func check(forBlanks textView: UITextView) -> Bool{
        let rawString: String? = textView.text
        let whitespace = CharacterSet.whitespacesAndNewlines
        let trimmed: String? = rawString?.trimmingCharacters(in: whitespace)
        if (trimmed?.count ?? 0) == 0 {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Validate Image input
    func check(forBlanks imageView: UIImageView) -> Bool{
        if (recipesImageView.image == nil) {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Validate label input
    func check(forBlanks label: UILabel) -> Bool{
        
        if (label.text == "Select Recipe Type") {
            return true
        } else {
            return false
        }
    }
    
}

// MARK: Image View Delegates
extension CreateNewRecipeViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    
    // MARK: Opens Camera
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Opens Gallery
    func openGallary()
    {
        
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    // dismisses the image picker view
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // select image from the image picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        recipesImageView.isHidden = false
        recipesImageView.image = selectedImage
        dismiss(animated: true, completion: nil)
        
    }
}
