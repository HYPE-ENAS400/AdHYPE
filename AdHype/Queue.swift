//
//  Queue.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/21/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

// Adapted from: https://gist.github.com/kareman/931017634606b7f7b9c0

class QueueItem<T>{
    let value: T!
    var next: QueueItem<T>?
    init(newVal: T?){
        self.value = newVal
    }
}

class Queue<T>{
    private var lastItem: QueueItem<T>!
    private var firstItem: QueueItem<T>!
    
    private var count: Int = 0
    private var totalCount: Int = 0
    
    init(){
        lastItem = QueueItem(newVal: nil)
        firstItem = lastItem
    }
    
    func enqueue(newVal: T){
        lastItem.next = QueueItem(newVal: newVal)
        lastItem = lastItem.next
        count += 1
        totalCount += 1
    }
    func dequeue() -> T?{
        if let nextItem = firstItem.next{
            firstItem = nextItem
            count -= 1
            return firstItem.value
        } else {
            return nil
        }
    }
    func isEmpty() -> Bool{
        return firstItem === lastItem
    }
    func getCount() -> Int{
        return count
    }
    func getTotalCount() -> Int{
        return totalCount
    }
}