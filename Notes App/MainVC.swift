//
//  MainVC.swift
//  Notes App
//
//  Created by Gary Singh on 2/16/17.
//  Copyright © 2017 AmanGarry. All rights reserved.
//

import UIKit
import CoreData

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!      // tableView outlet
    
    @IBOutlet weak var searchBar: UISearchBar!      // searchBar outlet
    
    var inSearchMode = false                        // set inSearchMode to false
    
    var fetchResultsController: NSFetchedResultsController<Note>!
    
    //------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        // dismiss keyboard
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        // if done button of keyboard pressed then hide keyboard
        searchBar.returnKeyType = UIReturnKeyType.done
        
        searchBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // fetch data from Core Data
        attemptFetch()
    }
    
    //------------------------------------------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    //------------------------------------------------------------------------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        // if fetched data has a sections then return the number of sections
        if let sections = fetchResultsController.sections {
            return sections.count
        }
        
        return 0
    }
    
    //------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        // if fetched data is having sections then proceed
        if let sections = fetchResultsController.sections {
            // get section data from the sections
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    //------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // get the cell for the given indexpath as NoteCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as! NoteCell
        
        // configure the cell and return it
        configureCell(cell: cell, indexPath: indexPath as NSIndexPath)

        // Configure the cell...
        return cell
    }

    
    //------------------------------------------------------------------------------------
    // if cell is selected then segue to note edit screen and load selected 
    //  note data to edit screen
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // if fetched notes are greater then 0 then select the note at the 
        //  selected row and perform the segue with existing note
        if let objects = fetchResultsController.fetchedObjects, objects.count > 0 {
            let note = objects[indexPath.row]
            performSegue(withIdentifier: "NoteEditVC", sender: note)
        }
    }

    //------------------------------------------------------------------------------------
    // In a storyboard-based application, 
    //  you will often want to do a little preparation before navigation
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "NoteEditVC" {
            if let destination = segue.destination as? NoteEditVC {
                // get the note from the sender & confirm its of type Note
                if let note = sender as? Note {
                    destination.noteToEdit = note
                }
            }
        }
    }
    
    //------------------------------------------------------------------------------------
    // composeBtnTapped:        segue to NoteEditVC
    //
    @IBAction func composeBtnTapped(_ sender: UIButton) {
        
        performSegue(withIdentifier: "NoteEditVC", sender: nil)
    }
    
    //------------------------------------------------------------------------------------
    // configure the cell using configure method in NoteCell
    func configureCell(cell: NoteCell, indexPath: NSIndexPath) {
        
        let note = fetchResultsController.object(at: indexPath as IndexPath)
        cell.configure(note: note)
    }
    
    //------------------------------------------------------------------------------------
    // attemptFetch:        Fetch data from the memory and if inSearchMode is true then
    //                          fetch filtered data from the CoreData
    //
    func attemptFetch() {
        
        // fetch Request
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        
        // to filter the reasult according to search query if in search mode
        if inSearchMode {
            let filterString = searchBar.text?.lowercased()
            
            let predicate = NSPredicate(format: "data contains[cd] %@", filterString!)
            
            fetchRequest.predicate = predicate
        }
        
        // type of sortings, sort by date
        let dateSort = NSSortDescriptor(key: "created", ascending: false)
            
        fetchRequest.sortDescriptors = [dateSort]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        controller.delegate = self
        
        self.fetchResultsController = controller
        
        // fetch data
        do {
            try controller.performFetch()
        } catch {
            let error = error as NSError
            print("\(error)")
        }
    }
    
    //------------------------------------------------------------------------------------
    // if content in dataBase changes then update table view
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.beginUpdates()
    }
    
    
    //------------------------------------------------------------------------------------
    // after content got changed then end updating table view
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.endUpdates()
    }
    
    //------------------------------------------------------------------------------------
    // control the insert, delete, update, move funcs in core data automatically
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type) {
        
        // insert the data in memory
        case.insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        // delete the data from memory
        case.delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
        // update the data in memory
        case.update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRow(at: indexPath) as! NoteCell
                configureCell(cell: cell, indexPath: indexPath as  NSIndexPath)
            }
            break
        // move the data from one location to another in memory
        case.move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        }
    }

    
    //------------------------------------------------------------------------------------
    // searchBarSearchButtonClicked:        if search button clicked then hide the 
    //                                          keyboard
    //
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // hide keyboard
        view.endEditing(true)
    }
    
    
    //------------------------------------------------------------------------------------
    // searchBar:           fetch data depending upon the text entered in the search
    //                          bar or if search bar is empty, and reload the table view.
    //
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // if search bar has no text
        if searchBar.text == nil || searchBar.text == "" {
            
            inSearchMode = false            // set inSearchMode to false
            self.attemptFetch()             // fetch data
            tableView.reloadData()          // reload the table
        // if search bar has text then
        } else {
            inSearchMode = true             // set inSearchMode to true
            self.attemptFetch()             // fetch data
            tableView.reloadData()          // reload the table
        }
        
    }
}
