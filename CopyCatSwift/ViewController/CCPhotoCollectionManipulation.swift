//
//  CCPhotoCollectionDeletion.swift
//  CopyCatSwift
//
//  Created by Zhenyu Yang on 1/19/16.
//  Copyright © 2016 Baiqi Zhang. All rights reserved.
//


protocol CCPhotoCollectionManipulation {
    
    func prepareDelete()
    func finishDelete()
    func performDelete()
    func prepareDeleteCell(cell: CCCollectionViewCell)
    func cancelDeleteCell(cell: CCCollectionViewCell)
}
