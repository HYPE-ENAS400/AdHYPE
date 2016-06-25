

import Foundation
import Firebase
import UIKit

enum VCTransitionDirection{
    case toRight
    case toLeft
}

struct FIRDetachInfo{
    var ref: FIRDatabaseReference
    var handle: FIRDatabaseHandle
    init(ref: FIRDatabaseReference, handle: FIRDatabaseHandle){
        self.ref = ref
        self.handle = handle
    }
}

protocol DisplayMessageDelegate{
    func displayMessage(message: String, duration: Double)
}

//func generateDemoAddQueue(userUID: String, completion: ()->Void ){
//    let ref = FIRDatabase.database().reference().child(Constants.ADSNODE)
//    ref.observeSingleEventOfType(.Value, withBlock: {(snapshot)->Void in
//        if let dict = snapshot.value as? [String : String]{
//            let newRef = FIRDatabase.database().reference().child(Constants.USERSNODE).child(userUID).child(Constants.ADQUEUENODE)
//            newRef.setValue(dict, withCompletionBlock: {(error, reference) -> Void in
//                completion()
//            })
//        }
//    })
//}

//func generateInitialDatabaseAdQueue(userUID: String, completion: ()->Void){
//    let ref = FIRDatabase.database().reference().child(Constants.ADSNODE)
//    let query = ref.queryOrderedByKey().queryLimitedToFirst(20)
//}

//http://stackoverflow.com/questions/24034544/dispatch-after-gcd-in-swift/24318861#24318861
func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
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
