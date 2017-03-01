//
//  NoteEditVC.swift
//  Notes App
//
//  Created by Gary Singh on 2/15/17.
//  Copyright © 2017 AmanGarry. All rights reserved.
//

import UIKit

class NoteEditVC: UIViewController {

    @IBOutlet weak var deleteView: UIVisualEffectView!      // outlet for deleteView
    
    @IBOutlet weak var cancelBtn: UIButton!                 // outlet for Cancek Button
    
    @IBOutlet weak var deleteBtn: UIButton!                 // outlet for Delete Button
    
    @IBOutlet weak var textView: UITextView!                // outlet for textView
    
    @IBOutlet weak var dateLabel: UILabel!                  // outlet for dateLabel
    
    var noteToEdit: Note?                                   // Create a note
    
    //------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // dismiss keyboard when tapped on screen
        let tap = UITapGestureRecognizer(target: self.view,
                                         action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        // if note to edit is not nil then load data of note to screen
        if noteToEdit != nil {
            loadItemData()
        // else create a new date and set date after formatting it to date label
        } else {
            
            // get current date
            let date = NSDate()
            
            // date format
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d, yyyy, h:mm a"
            
            // set date as string
            dateLabel.text = dateFormatter.string(from: date as Date)
        }
        
    }
    
    //------------------------------------------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //------------------------------------------------------------------------------------
    // doneBtnPressed:      Save the note if it is not empty and segue to main screen
    //                          but if it is empty then segue to main screen without 
    //                          saving it.
    //
    @IBAction func doneBtnPressed(_ sender: UIButton) {
        
        // run if text is in the textView and atleast having one character
        if let textData = textView.text, textData.characters.count > 0 {
            
            let note: Note!             // set the note
        
            // if note is empty then create a new note in memory
            if noteToEdit == nil {
                note = Note(context: context)
            // else initialize the note to existing note
            } else {
                note = noteToEdit
            }
        
            // set note data to entered text
            note.data = textData
            
            // set the current date as created date
            note.created = NSDate()
            
            // save the note to memory
            ad.saveContext()
        }
        
        // segue to the main screen
        dismiss(animated: true, completion: nil)
    }
    
    
    //------------------------------------------------------------------------------------
    // deleteIconTapped:        if note in not nil(empty) then 
    //                          unhide 1. deleteView, 2. Cancel & 3. Delete Buttons
    //                          and if note is nil then segue to main screen
    //
    @IBAction func deleteIconTapped(_ sender: UIButton) {
        
        // if note in not nil(empty) then
        // unhide 1. deleteView, 2. Cancel & 3. Delete Buttons
        if noteToEdit != nil {
            deleteView.isHidden = false
            cancelBtn.isHidden = false
            deleteBtn.isHidden = false
        // else segue to main screen
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    //------------------------------------------------------------------------------------
    // deleteBtnTapped:     delete the note from the memory and show the 
    //                          unhidden 1. deleteView, 2. Delete & 3. Cancel Button
    //                          and segue to main screen
    //
    @IBAction func deleteBtnTapped(_ sender: UIButton) {
        
        // delete note
        context.delete(noteToEdit!)
        ad.saveContext()
        
        // get back
        deleteView.isHidden = true
        deleteBtn.isHidden = true
        cancelBtn.isHidden = true
        
        // segue back to main screen
        dismiss(animated: true, completion: nil)
    }
    
    
    //------------------------------------------------------------------------------------
    // cancelBtnTapped:         Unhide the 1. deleteView, 2. Delete & 3. Cancel Buttons
    //
    @IBAction func cancelBtnTapped(_ sender: UIButton) {
      
        // Unhide the 1. deleteView, 2. Delete & 3. Cancel Buttons
        deleteView.isHidden = true
        deleteBtn.isHidden = true
        cancelBtn.isHidden = true
    }
    
    
    //------------------------------------------------------------------------------------
    // loadItemData:            Load the data from the existing note data
    //
    func loadItemData() {
      
        // if note to edit is not nil then proceed
        if let note = noteToEdit {
            
            // set textView text to note data
            textView.text = note.data
            
            // date format
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d, yyyy, h:mm a"
            
            // set date label as string
            dateLabel.text = dateFormatter.string(from: note.created as! Date)
        }
    }
    
}

