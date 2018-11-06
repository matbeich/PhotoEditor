//
//  ViewController.swift
//  PhotoEditor
//
//  Created by Admin on 11/6/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class SceneController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
    }

    private let toolBar = ToolBar()
    private let toolControlsContainer = UIView()
    private let photoViewController = PhotoViewController()
}
