//
//  ContactsTableViewController.swift
//  My Contact List
//
//  Created by Ricardo Ortega on 4/1/24.
//

import UIKit
import CoreData

class ContactsTableViewController: UITableViewController {
    
    var contacts: [NSManagedObject] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataFromDatabase()
        self.navigationItem.leftBarButtonItem = self.editButtonItem

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath)
        // Configure the cell...
        let contact = contacts[indexPath.row] as? Contact
        //under the prototype cell, the details of the individual is displayed
        cell.textLabel?.text = (contact?.contactName)! + " From " + (contact?.city)! + " " + (contact?.phoneNumber)!
        let formatter = DateFormatter()
        formatter.dateStyle = .long //displays Full month while .short displays in MM/DD/YYYY
        cell.detailTextLabel?.text = "Born on: " + formatter.string(from: contact!.birthday!)
        
        cell.accessoryType = UITableViewCell.AccessoryType.detailDisclosureButton
        
        return cell
    }
    override func viewWillAppear(_ animated: Bool) {
        loadDataFromDatabase()
        tableView.reloadData()
        //ensures data is reloaded from the table itself
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let contact = contacts[indexPath.row] as? Contact
            let context = appDelegate.persistentContainer.viewContext
            context.delete(contact!)
            do {
                try context.save()
            } catch {
                fatalError("Error saving context: \(error)")
            }
            loadDataFromDatabase()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedContact = contacts[indexPath.row] as? Contact
        let name = selectedContact!.contactName!
        let actionHandler = { (action:UIAlertAction!) -> Void in
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "ContactController")
                as? ContactViewController
            controller?.currentContact = selectedContact
            self.navigationController?.pushViewController(controller!, animated: true)
        }
        let alertController = UIAlertController(title: "Contact selected",
                                                message: "Selected row: \(indexPath.row) (\(name))", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel,
                                         handler: nil)
        let actionDetails = UIAlertAction(title: "Show details",
                                          style: .default,
                                          handler: actionHandler)
        alertController.addAction(actionCancel)
        alertController.addAction(actionDetails)
        present(alertController, animated: true, completion: nil)
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditContact" {
            let contactController = segue.destination as? ContactViewController
            let selectedRow = self.tableView.indexPath(for: sender as! UITableViewCell)?.row
            let selectedContact = contacts[selectedRow!] as! Contact
            contactController?.currentContact = selectedContact
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 
    func loadDataFromDatabase() {
        //read settings to enable sorting
        let settings = UserDefaults.standard
        let sortField = settings.string(forKey: Constants.kSortField)
        let sortAscending = settings.bool(forKey: Constants.kSortDirectionAscending)
        //set up Core Data Context
        let context = appDelegate.persistentContainer.viewContext
        //set up request
        let request = NSFetchRequest<NSManagedObject>(entityName: "Contact")
        //specify sorting
        
        let sortDescriptor = NSSortDescriptor(key: sortField, ascending: sortAscending)
        let sortDescriptorArray = [sortDescriptor]
            //to sort by multiple fields, add more sort descriptiors to the array
        request.sortDescriptors = sortDescriptorArray
            //Execute request
         
        do {
            contacts = try context.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. Debug line 156 in contactsTable \(error), \(error.userInfo)")
        }
        
        
    }

}
