//
//  TaskViewController.swift
//  TaskList
//
//  Created by Bektemur Mamashayev on 02/04/23.
//

import UIKit
import CoreData

protocol ButtonFactory {
    func createButton() -> UIButton
}

class CustomButtonFactory: ButtonFactory {

    let title: String
    let color: UIColor
    let action: UIAction
    
    init(title: String, color: UIColor, action: UIAction) {
        self.title = title
        self.color = color
        self.action = action
    }
    
    func createButton() -> UIButton {
        // Set attributes for button title
        var attributes = AttributeContainer()
        attributes.font = UIFont.boldSystemFont(ofSize: 18)

        // Set configuration for button
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.attributedTitle = AttributedString(title, attributes: attributes)
        buttonConfiguration.baseBackgroundColor = color
        
        let button = UIButton(configuration: buttonConfiguration, primaryAction: action)
        button.translatesAutoresizingMaskIntoConstraints = false
                              
        return button
    }
}

final class TaskViewController: UIViewController {
    private let storageManager = StorageManager.shared
    weak var delegate: TaskViewControllerDelegate!
    private lazy var viewContext = storageManager.persistentContainer.viewContext
    private lazy var taskTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "New Task"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var saveButton: UIButton = {
        let customButtonFactory = CustomButtonFactory(
            title: "Save TAsk",
            color: UIColor(named: "Milk Blue") ?? .systemBlue,
            action: UIAction { [unowned self] _ in
                save()
            }
        )
        return customButtonFactory.createButton()
    }()
    
    private lazy var cancelButton: UIButton = {
        let customButttonFactory = CustomButtonFactory(
            title: "CANCEL",
            color: .red,
            action: UIAction { [unowned self] _ in
                dismiss(animated: true)
            }
        )
        return customButttonFactory.createButton()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSubviews(taskTextField, saveButton, cancelButton)
        setConstraints()
    }
    
    private func save() {
        let task  = Task(context: viewContext)
        task.title = taskTextField.text
        storageManager.saveContext()
        delegate.reloadData()
        dismiss(animated: true)
    }
    
}

//MARK: - Setup UI
private extension TaskViewController {
    func setupSubviews(_ subviews: UIView...) {
        subviews.forEach { subview in
            view.addSubview(subview)
        }
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            taskTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            taskTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            taskTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: taskTextField.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
}
