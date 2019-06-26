//
//  ViewController.swift
//  MemeMeDemo
//
//  Created by Bdoor on 11/03/1440 AH.
//  Copyright © 1440 udacity. All rights reserved.
//

import UIKit

class ViewController: UIViewController ,UIImagePickerControllerDelegate,UINavigationBarDelegate,UITextFieldDelegate,UINavigationControllerDelegate{
    
    @IBOutlet weak var imagePickerView: UIImageView!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var topTextField: UITextField!
    
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var navigationbar: UINavigationBar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var topText = "TOP"
    var bottomText = "BOTTOM"
    var originalImage:UIImage? = nil
    var topIsFirst = true
    var bottomIsFirst = true
    
    @IBAction func topTextFieldEditingDidBegin(_ sender: UITextField) {
        if topIsFirst {
            topIsFirst = false
            topTextField.text = ""
        }
    }
    
    @IBAction func bottomTextFieldDidBeginEditing(_ sender: Any) {
        if bottomIsFirst {
            bottomIsFirst = false
            bottomTextField.text = ""
        }
    }
    
    //let textFieldDelegate = UITextFieldDelegate()
    
    let memeTextAttributes:[NSAttributedString.Key:Any]=[
        NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeColor.rawValue):UIColor.black,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue):UIColor.white,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue):UIFont(name: "HelveticaNeue-CondensedBlack", size: 40) as Any,
        NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeWidth.rawValue): -3.0]
    
    func resetControls(){
        topTextField.text = topText
        bottomTextField.text = bottomText
        enableBarButon(shareButton)
        
    }
    
    
    
    @IBAction func cancelButton(_ sender: Any) {
        imagePickerView.image = originalImage
        resetControls()
        //self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func share(_ sender: Any) {
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        self.present(activityViewController,animated: true,completion: nil)
        
        
        activityViewController.completionWithItemsHandler = {
            (activity,success,items,error)in
            if success{
                self.save()
                //self.dismiss(animated:true,completion: nil)
            }
        }
    }
    
    
    
    @IBAction func ipickAnImage(_ sender: AnyObject) {
        if sender.tag == 0{
            getImagePickerController(.photoLibrary)
        }
    }
    
    @IBAction func camreButton(_ sender: AnyObject) {
        //if sender.tag == 1{
        getImagePickerController(.camera)
        // /
    }
    
    
    func configure(textField:UITextField,withText:String){
        textField.text = withText
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configure(textField: self.topTextField, withText: topText)
        configure(textField: self.bottomTextField, withText: bottomText)
        imagePickerView.image = originalImage
        enableBarButon(shareButton)
    }
    
    
    
    func enableBarButon(_ barButton:UIBarButtonItem){
        if barButton.tag == 2 {
            barButton.isEnabled = (originalImage != nil)
        }else{
            barButton.isEnabled = true
        }
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let AppDelegate = UIApplication.shared.delegate as! AppDelegate
        var memes = AppDelegate.memes
        
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeTKeyboardNotifications()
    }
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    
    @objc func keyboardWillShow(_ notification:Notification){
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    
    
    @objc func keyboardWillHide(_ notification:Notification){
        view.frame.origin.y = 0
    }
    
    
    
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    
    
    func subscribeTKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    
    
    func unsubscribeFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    
    func generateMemedImage() -> UIImage{
        hideNavbarAndToolbar(true)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        imagePickerView.backgroundColor = .white
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        hideNavbarAndToolbar(false)
        return memedImage
        
    }
    
    
    
    func hideNavbarAndToolbar(_ hide:Bool){
        toolbar.isHidden = hide
        navigationbar.isHidden = hide
    }
    
    
    
    func save(){
        let memes = Meme(topText:topTextField.text!,bottomText:bottomTextField.text!,originalImage: imagePickerView.image!, memedImage: generateMemedImage())
        let alertController = UIAlertController()
        alertController.title = "image saved"
        alertController.message = "the memed image successfully saved to photos"
        _ = UIAlertAction (title: "ok", style: UIAlertAction.Style.default){
            
            ACTION in self.dismiss(animated: true, completion: nil)
        }
        
        
        
        let AppDelegate = UIApplication.shared.delegate as? AppDelegate
        AppDelegate?.memes.append(memes)
        
    }
    
    
    @objc func imagePickerController(_ picker:UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey:Any]){
        if let image = info[.originalImage] as? UIImage{
            imagePickerView.image = image
            resetControls()
        }
        dismiss(animated: true, completion: { self.shareButton.isEnabled = true})
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func getImagePickerController(_ sourceType:UIImagePickerController.SourceType){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePickerController.sourceType = sourceType
        self.present(imagePickerController,animated: true,completion: nil)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
}

