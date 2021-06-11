//
//  ViewController.swift
//  TaskManager
//
//  Created by admin on 10.06.2021.
//

import UIKit
import CoreData

class ViewController: UITableViewController {

    
    // view setup
    private let cellID = "cellID"
    private var tasks: [Task] = []
    
    private let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        rollData()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        navBarSetup()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    private func navBarSetup() {
        title = "Tasks to do"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.yellow]
        navigationController?.navigationBar.barTintColor = UIColor(
            displayP3Red: 125/255,
            green: 1/255,
            blue: 255/255,
            alpha: 1)
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(addTask)
        )
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addTask() {
        alertFieldAction(title: "New Task", message: "What is your next task?")
    }
    
    // func to enter the name of new task
    private func alertFieldAction(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveTask = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else {
                print("empty field")
                return
                
            }
            
            self.save(taskName: task)
            
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addTextField()
        alert.addAction(saveTask)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
    }
    
    // adding new tasks
    private func save(taskName: String) {
        
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: managedContext) else { return }
        
        let task = NSManagedObject(entity: entityDescription, insertInto: managedContext) as! Task
        task.name = taskName
        
        do {
            
            try managedContext.save()
            tasks.append(task)
            self.tableView.insertRows(at: [IndexPath(row: self.tasks.count - 1, section: 0)], with: .automatic)
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // updating array with new task data
    private func rollData() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            tasks = try managedContext.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
    }

}

extension ViewController {
    
    // setting up the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        
        return cell
        
    }
    
    // function to edit the task
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let alertController = UIAlertController(title: "Изменить задание", message: "Для изменения задания введите новое название задания", preferredStyle: .alert)

        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let result = alertController.textFields?.first?.text, !result.isEmpty else { return }
            
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Task")
            
            do {
                let run = try self.managedContext.fetch(fetchRequest)
                
                let updateObject = run[indexPath.row] as! NSManagedObject
                updateObject.setValue(result, forKey: "name")
                
                do {
                    try self.managedContext.save()
                    tableView.reloadData()
                } catch let error {
                    print(error.localizedDescription)
                }
            } catch let error {
                print(error.localizedDescription)
            }
            
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

        alertController.addTextField()
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
        
        return indexPath
    }
    
    // function to remove the task
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            managedContext.delete(tasks[indexPath.row])
            tasks.remove(at: indexPath.row)
            tableView.reloadData()
            do {
                try managedContext.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
}
