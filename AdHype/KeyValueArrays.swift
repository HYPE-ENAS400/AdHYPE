//
//  KeyValueStruct.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/19/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import Foundation

class KeyValueArrays {
    private var keys = [String]()
    private var values = [String]()
    
    func putPair(pair: (key: String, value: String) ){
        keys.append(pair.key)
        values.append(pair.value)
    }
    
    func getPairAtIndex(index: Int) -> (key: String, value: String){
        return ((keys[index], values[index]))
    }
    func getKeyAtIndex(index: Int) -> String{
        return keys[index]
    }
    func getValueAtIndex(index: Int) -> String{
        return values[index]
    }
    
    func getIndexOfPairForKey(key: String) -> Int?{
        return keys.indexOf(key)
    }
    
    func deletePairAtIndex(index: Int){
        keys.removeAtIndex(index)
        values.removeAtIndex(index)
    }
    
    func deletePairForKey(key: String) -> Bool{
        if let index = getIndexOfPairForKey(key){
            deletePairAtIndex(index)
            return true
        } else {
            return false
        }
    }
    func getCount() -> Int{
        return keys.count
    }
    
    func getKeys() -> [String]{
        return keys
    }
    func getValues() -> [String]{
        return values
    }

}