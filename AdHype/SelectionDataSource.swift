//
//  SelectionDataSource.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/23/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import Foundation

class SelectionDataSource<T>{
    private var keys = [String]()
    private var values = [T]()
    
    func putPair(pair: (key: String, value: T) ){
        keys.append(pair.key)
        values.append(pair.value)
    }
    
    func getPairAtIndex(index: Int) -> (key: String, value: T){
        return ((keys[index], values[index]))
    }
    func getKeyAtIndex(index: Int) -> String{
        return keys[index]
    }
    func getValueAtIndex(index: Int) -> T{
        return values[index]
    }
    func getValueForKey(key: String)->T?{
        if let i = keys.indexOf(key){
            return values[i]
        } else{
            return nil
        }
    }
    func getIndexOfPairForKey(key: String) -> Int?{
        return keys.indexOf(key)
    }
    func deletePairAtIndex(index: Int){
        keys.removeAtIndex(index)
        values.removeAtIndex(index)
    }
    
//    func deletePairForKey(key: String) -> Bool{
//        if let index = getIndexOfPairForKey(key){
//            deletePairAtIndex(index)
//            return true
//        } else {
//            return false
//        }
//    }
    
//    func setValueForKey(key: String, value: T){
//        if let i = keys.indexOf(key){
//            values[i] = value
//        }
//    }
    
    func setKeys(keys: [String]){
        self.keys = keys
    }
    func setValueAtIndex(index: Int, value: T){
        values[index] = value
    }
    func getCount() -> Int{
        return keys.count
    }
    func getKeys() -> [String]{
        return keys
    }
    func getValues() -> [T]{
        return values
    }
    func clear(){
        keys.removeAll()
        values.removeAll()
    }

}