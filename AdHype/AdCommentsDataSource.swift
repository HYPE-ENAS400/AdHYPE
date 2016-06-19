//
//  AdCommentsDataSource.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/16/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit
class AdCommentsDataSource: UITableViewDataSource {
    
    var captions: [String]!
    init(){
        for i in 1...15{
            captions.append("THIS IS MY CAPTION #\(i)")
        }
    }
    
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return captions.count
    }
    
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell", forIndexPath: indexPath)
        cell.textLabel?.text = captions[indexPath.row]
        return cell
    }
    
}
