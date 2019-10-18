//
//  UICollectionView+Reuseable.swift
//  CodingChallenge-500px
//
//  Created by Hsuan-Chih Chuang on 2019/10/17.
//  Copyright © 2019 Hsuan-Chih Chuang. All rights reserved.
//

import UIKit

public protocol CellReusable {
    static var reuseIdentifier: String { get }
    static var toUINib: UINib { get }
}

extension CellReusable {
    public static var reuseIdentifier : String { return String(describing: self) }
    public static var toUINib : UINib          { return UINib(nibName: reuseIdentifier, bundle: .main)
    }
}

extension UICollectionViewCell : CellReusable {}

extension UICollectionView {
    public func dequeueReusableCell<Cell: CellReusable>(with cellClass: Cell.Type, for indexPath: IndexPath) -> Cell {
        return dequeueReusableCell(withReuseIdentifier: cellClass.reuseIdentifier, for: indexPath) as! Cell
    }
    public func register<Cell: CellReusable>(with cellClass: Cell.Type) {
        register(cellClass.toUINib, forCellWithReuseIdentifier: cellClass.reuseIdentifier)
    }
}
