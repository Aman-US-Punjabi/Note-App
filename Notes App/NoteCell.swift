//
//  NoteCell.swift
//  Notes App
//
//  Created by Gary Singh on 2/17/17.
//  Copyright © 2017 AmanGarry. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {

    @IBOutlet weak var headLineLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var detailsLabel: UILabel!

    
    //-------------------------------------------------------------------------
    // configure:       configure a current cell with the note data passed in
    //                      parameter.
    //
    // Parameter:       Takes a Note Entity model as a parameter. Note model
    //                      is created in CoreData, Note entity is data of 
    //                      type string and created as date type.
    //
    func configure(note: Note) {
     
        // set the data to headline
        headLineLabel.text = note.data
        
        // formating date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        // setting date
        dateLabel.text = dateFormatter.string(from: note.created as! Date)
        
        // set the textfield data 
        detailsLabel.text = note.data
    }
    
}
