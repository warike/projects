//
//  ProfileMenuViewController.swift
//  scoodit
//
//  Created by Sergio Esteban on 07/03/17.
//  Copyright © 2017 Sergio Cardenas. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ProfileMenuViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    


}
