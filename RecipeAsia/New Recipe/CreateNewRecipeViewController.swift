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
    var isUpdate : Bool = false
    var ctrVariable : Int = 0
    var recipeModel : RecipeTypeModel?
    var recipes : [Recipe] = []
    var recipeArray : [String] = []
    
    var dropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for recipeTitle in recipes {
                  recipeArray.append(recipeTitle.recipeTitle)
              }
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreateNewRecipeViewController.dismissKeyboard))
             self.view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIWindow.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIWindow.keyboardWillShowNotification, object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
           NotificationCenter.default.removeObserver(self)
       }


    @objc func keyboardWillAppear(_ notification: NSNotification) {

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
               if self.view.frame.origin.y == 0{
                   self.view.frame.origin.y -= keyboardSize.height
               }
           }
       }

    @objc func keyboardWillDisappear(_ notification: NSNotification) {

    
    self.view.frame.origin.y = 0
               
       }
    
    func textFieldShouldReturn(_ textField: UITextView) -> Bool {
           
           textField.resignFirstResponder()
           
           return true
       }
       
       
       @objc func dismissKeyboard()
       {
           view.endEditing(true)
       }

    override func viewWillAppear(_ animated: Bool) {
      
        if (isUpdate){
            if let image = UIImage(data:recipeModel!.image as Data){
                recipesImageView.image = image
            }
            recipeNameTF.text = recipeModel?.recipeName
            recipesIngredientsTV.text = recipeModel?.ingredients
            recipesInstructionsTV.text = recipeModel?.steps
            
        }
    }
    @IBAction func filterBtnAction(_ sender: UIButton)
    {
        dropDown = DropDown()
        dropDown.anchorView = sender
        dropDown.dataSource = recipeArray
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            
            self.recipeCategoryLbl.text = self.recipeArray[index]
            
            self.dropDown.hide()
        }
        dropDown.width = sender.frame.width
        dropDown.show()
        
    }
    
    @IBAction func setPhoto(_ sender : UIButton){
        imagePicker.delegate = self
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { _ in
            self.openGallary()
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
    
    
    @IBAction func addRecipeBtnAction(_ sender: UIButton)
    {
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
            if isUpdate {
                updateData()
            } else {
                save(name: recipeNameTF.text!, email: recipesIngredientsTV.text!, others: recipesInstructionsTV.text!)
            }
        }
    }
    
    
    // MARK: – Database operation Methods
    func save(name: String , email: String, others: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        ctrVariable = ctrVariable + 1
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Recipes", in: managedContext)!
        let recipeObj = NSManagedObject(entity: entity, insertInto: managedContext)
        recipeObj.setValue(ctrVariable, forKeyPath: "id")
        recipeObj.setValue(recipeCategoryLbl.text, forKeyPath: "recipe_type")
        recipeObj.setValue(recipeNameTF.text, forKeyPath: "recipe_name")
        recipeObj.setValue(recipesIngredientsTV.text, forKeyPath: "ingredients")
        recipeObj.setValue(recipesInstructionsTV.text, forKeyPath: "steps")
        recipeObj.setValue(recipesImageView.image!.jpegData(compressionQuality: 1), forKey: "image")
        do {
            try managedContext.save()
            recipe.append(recipeObj)
            self.view.makeToast("Your recipe has been saved sucessfully!!")
            
            self.dismiss(animated: true, completion: nil)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func showAlert(withTitleMessageAndAction title:String, message:String , action: Bool){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        if action {
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action : UIAlertAction!) in
                self.navigationController?.popViewController(animated: true)
            }))
        } else{
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        }
    }
    
    func updateData(){
        
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
            recipeObj.setValue(recipesIngredientsTV.text, forKeyPath: "ingredients")
            recipeObj.setValue(recipesInstructionsTV.text, forKeyPath: "steps")
            recipeObj.setValue(recipesImageView.image!.jpegData(compressionQuality: 1), forKey: "image")
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
    
    // MARK: – Other Methods.
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
    
    // MARK: – Other Methods.
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
    
    func check(forBlanks imageView: UIImageView) -> Bool{
        if (recipesImageView.image == nil) {
            return true
        } else {
            return false
        }
    }
    
    func check(forBlanks label: UILabel) -> Bool{
        
        if (label.text == "Select Recipe Type") {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func backBtnAction(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CreateNewRecipeViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    
    
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
    
    func openGallary()
    {
        
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        recipesImageView.isHidden = false
        recipesImageView.image = selectedImage
        dismiss(animated: true, completion: nil)
        
    }
}
