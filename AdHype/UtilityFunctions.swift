

import Foundation
import Firebase
import UIKit

struct FIRDetachInfo{
    var ref: FIRDatabaseReference
    var handle: FIRDatabaseHandle
    init(ref: FIRDatabaseReference, handle: FIRDatabaseHandle){
        self.ref = ref
        self.handle = handle
    }
}

struct User: Equatable{
    var key: String
    var userName: String
    var fullName: String?
//    var selected: Bool
    init(key: String, userName: String, fullName: String?){
        self.key = key
        self.userName = userName
        self.fullName = fullName
//        self.selected = selected
    }
}

func == (lhs: User, rhs: User) -> Bool {
    return lhs.key == rhs.key
}

struct SelectionCellTextData{
    var main: String
    var detail: String?
    init(main: String, detail: String?){
        self.main = main
        self.detail = detail
    }
}

func convertSelectionCellTextDataToUserNamesDict(data: SelectionCellTextData)->[String: String]{
    var dict = [Constants.USERDISPLAYNAME: data.main]
    if let fullName = data.detail{
        dict[Constants.USERFULLNAME] = fullName
    }
    return dict
}

protocol DisplayMessageDelegate: class{
    func displayMessage(message: String, duration: Double)
}

protocol UserClickDelegate: class{
    func onShowUserProfile(user: User?)
}

//http://stackoverflow.com/questions/24034544/dispatch-after-gcd-in-swift/24318861#24318861
func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func initializeAppButtonLayer(layer: CALayer){
    layer.cornerRadius = CGFloat(Constants.DEFAULTCORNERRADIUSSMALL)
    layer.shadowRadius = 2
    layer.shadowOpacity = 1.0
    layer.shadowOffset = CGSizeZero
    layer.shadowColor = UIColor.grayColor().CGColor
}

func resizeImage(image: UIImage, newScale: CGFloat) -> UIImage{
    let newWidth = image.size.width * newScale
    let newHeight = image.size.width * newScale
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
    image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
}
