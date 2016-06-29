//
//  SelectionTableView.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/23/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit


// Handles the logic of a view control with a selection table, default methods must be overriden
//class SelectionTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
class SelectionTableView: UITableView, UITableViewDelegate, UITableViewDataSource{
    private var selectedIndices = [Int]()
    
    var selectionDelegate: SelectionTableViewDelegate!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        dataSource = self
    }
    
    func addPreselectedIndex(index: Int?){
        if let i = index{
            selectedIndices.append(i)
        }
    }
    func clearSelectedIndices(){
        selectedIndices.removeAll()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! SelectionCell
        let cellIndex = indexPath.row
        if let i = selectedIndices.indexOf(cellIndex){
            selectedIndices.removeAtIndex(i)
            cell.cellDeselected()
            selectionDelegate.cellAtIndexDeselected(cellIndex)
        } else{
            selectedIndices.append(cellIndex)
            cell.cellSelected()
            selectionDelegate.cellAtIndexSelected(cellIndex)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectionDelegate.getNumberOfCells()
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell") as! SelectionCell
        
//        if let color = selectionDelegate.getCellColorAtIndex(indexPath.row){
//            cell.backgroundColor = color
//        }
        
        cell.backgroundColor = selectionDelegate.getCellColorAtIndex(indexPath.row)
        
        if selectedIndices.contains(indexPath.row){
            cell.initCell(true)
        } else{
            cell.initCell(false)
        }
        if let data = selectionDelegate.getCellTextAtIndex(indexPath.row){
            cell.userCell.text = data.main
            cell.detailLabel.text = data.detail
        }
        return cell
    }
    
}

protocol SelectionTableViewDelegate{
    func cellAtIndexSelected(index: Int)
    func cellAtIndexDeselected(index: Int)
    func getNumberOfCells()->Int
    func getCellTextAtIndex(index: Int) -> SelectionCellTextData?
    func getCellColorAtIndex(index: Int) -> UIColor?
}