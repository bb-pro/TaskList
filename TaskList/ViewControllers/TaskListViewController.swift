//
//  ViewController.swift
//  TaskList
//
//  Created by Bektemur Mamashayev on 02/04/23.
//

import UIKit

enum AlertStyle {
    case newTask
    case updateTask
}

final class TaskListViewController: UITableViewController {
    
    private let cellID = "task"
    private var taskList: [Task] = []
    private let storageManager = StorageManager.shared
    private lazy var viewContext = storageManager.persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        fetchData()
    }
    
    private func addNewTask() {
        showAlert(withTitle: "New Task", and: "What do you want to add", action: .newTask)
    }
    private func fetchData() {
        let fetchRequest = Task.fetchRequest()
        
        do {
            taskList = try viewContext.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    private func showAlert(withTitle: String, and message: String, action: AlertStyle) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(cancelAction)
        switch action {
        case .newTask:
            let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
                guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
                self?.save(task)
            }
            alert.addAction(saveAction)
            alert.addTextField { textField in
                textField.placeholder = "New Task"
            }
        case .updateTask:
            let editAction = UIAlertAction(title: "Update", style: .default) { [weak self] _ in
                guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
                self?.edit(task)
            }
            alert.addAction(editAction)
            alert.addTextField { [weak self] textField in
                guard let rowNumber = self?.tableView.indexPathForSelectedRow?.row else { return }
                textField.text = self?.taskList[rowNumber].title
            }
        }
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        let task  = Task(context: viewContext)
        task.title = taskName
        taskList.append(task)
        let indexPath = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        storageManager.saveContext()
    }
    private func edit(_ taskName: String) {
        let task = Task(context: viewContext)
        task.title = taskName
        guard let rowNumber = tableView.indexPathForSelectedRow?.row else { return }
        taskList[rowNumber].title = taskName
        let indexPath = IndexPath(row: rowNumber, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        storageManager.saveContext()
    }
}

//MARK: - Setup UI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor(named: "milkBlue")
        
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction { [unowned self] _ in
                addNewTask()
            })
        navigationController?.navigationBar.tintColor = .white
    }
}

//MARK: - UITableViewDataSource
extension TaskListViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        viewContext.delete(taskList[indexPath.row])
        fetchData()
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

//MARK: - UITableViewDelegate
extension TaskListViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(withTitle: "Update Task", and: "Edit the task", action: .updateTask)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
