//

import UIKit
import Firebase
import SafariServices

//class MainViewController: UIViewController, HypeAdStoreDelegate {
class MainViewController: UIViewController {

    @IBOutlet var countLabel: UILabel!
    @IBOutlet var progressBar: KYCircularProgress!
    @IBOutlet var kolodaView: KolodaView!
    @IBOutlet var mainSpinner: UIActivityIndicatorView!
    @IBOutlet weak var outOfCardsView: UIView!
    
    var delegate: MainViewControllerDelegate!
    var userInterests: SelectionDataSource<Bool>!
    
    var userRef: FIRDatabaseReference!
    let adStoreRef = FIRDatabase.database().reference().child(Constants.ADSNODE)
    
    var userAdsViewed: Int = 0
    var userContentCount: Int = 0
    var contentCountDetachInfo: FIRDetachInfo?
    var nextQueueKey: String?
    
    var ads = [HypeAd]()
    var adsMetaDataQueue = Queue<HypeAdMetaData>()

    var numAdsSwiped: Int = 0
    
    //Create subview for kolodaView, add Koloda view, and pass protocols
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressBar.lineWidth = 10.0
        progressBar.guideLineWidth = 10.0
        progressBar.progressGuideColor = UIColor(red: 212/255, green: 212/255, blue: 212/255, alpha: 1)
        progressBar.showProgressGuide = true
        progressBar.colors = [UIColor(red: 255/255, green: 56/255, blue: 73/255, alpha: 1)]
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        outOfCardsView.layer.cornerRadius = 20
        outOfCardsView.layer.shadowOpacity = 0.6
        outOfCardsView.layer.shadowOffset = CGSizeZero
        outOfCardsView.layer.shadowRadius = 5
        
        userRef = FIRDatabase.database().reference().child(Constants.USERSNODE).child(getUserID())
        
        delay(5){
            if !self.mainSpinner.hidden{
                self.outOfCardsView.hidden = false
                self.mainSpinner.stopAnimating()
            }
        }
    }
    
    override func viewDidAppear(animated: Bool){
        super.viewDidAppear(animated)
        
        userRef.child(Constants.ADVIEWEDCOUNTNODE).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if let adCount = snapshot.value as? Int {
                self.userAdsViewed = adCount
                let progress = adCount % Constants.ADSPERCONTENT
                self.progressBar.progress = Double(progress + 1)/Double(Constants.ADSPERCONTENT)
            } else {
                let progress = 0
                self.progressBar.progress = Double(progress + 1)/Double(Constants.ADSPERCONTENT)
            }
        })
        
        let contentCountRef = userRef.child(Constants.CONTENTCOUNTNODE)
        let contentCountHandle = contentCountRef.observeEventType(.Value, withBlock: { (snapshot) in
            if let count = snapshot.value as? Int {
                self.userContentCount = count
                self.countLabel.text = "\(self.userContentCount)"
            }
            
        })
        
        contentCountDetachInfo = FIRDetachInfo(ref: contentCountRef, handle: contentCountHandle)
        
    }
    
    func queryAdMetaData(){
        
        //Get Ads From Friends
        let receivedAdsRef = userRef.child(Constants.RECEIVEDADQUEUENODE)
        receivedAdsRef.observeEventType(.ChildAdded, withBlock: {(snapshot) -> Void in
            let dict = snapshot.value as! [String: String]
            guard let name = dict[Constants.ADNAMENODE] else{
                print("ERROR: COULD NOT GET AD NAME")
                return
            }
            guard let url = dict[Constants.ADURLNODE] else {
                print("ERROR: COULD NOT GET URL FOR AD: \(name)")
                return
            }
            guard let primaryTag = dict[Constants.ADPRIMARYTAGNODE] else {
                print("ERROR: COULD NOT GET PRIMARY TAG FOR AD: \(name)")
                return
            }
            let captionFromFriend = dict[Constants.ADCAPTIONNODE]
            let newMetaData = HypeAdMetaData(name: name, key: snapshot.key, url: url, primaryTag: primaryTag, isFromFriend: true, captionFromFriend: captionFromFriend)
            self.adsMetaDataQueue.enqueue(newMetaData)
            self.appendAdIfRoom()
        })
        
        appendToQueueIfRoom(adStoreRef)
    }
    
    func appendAdIfRoom(){
        guard ads.count <= Constants.MAXNUMADS else{
            return
        }
        
        if let metaData = adsMetaDataQueue.dequeue() {
            let newAd = HypeAd(refURL: Constants.BASESTORAGEURL + "\(metaData.name)", metaData: metaData)
            newAd.downloadImage({(result) -> Void in
                if case let .Success(ad) = result{
                    self.ads.append(ad)
                    if self.ads.count == 1 {
                        self.mainSpinner.stopAnimating()
                        self.kolodaView.reloadData()
                    } else{
                        let currCount = self.kolodaView.countOfCards
                        self.kolodaView.insertCardAtIndexRange(currCount..<(currCount+1), animated: true)
                    }
                } else{
                    self.appendAdIfRoom()
                }
            })
        }
//        else {
//            print("RAN OUT OF ADD NAMES")
//        }
    }
    
    func appendToQueueIfRoom(ref: FIRDatabaseReference){
        
        guard adsMetaDataQueue.getCount() <= Constants.MAXNUMADQUEUE else {
            return
        }
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            guard let nextKey = self.nextQueueKey else {
                return
            }
            
            ref.removeAllObservers()
            
            let query = ref.queryOrderedByKey().queryEqualToValue(nextKey)
            
            query.observeSingleEventOfType(.ChildAdded, withBlock: {(snapshot) -> Void in
                if let dict = snapshot.value as? [String: String]{
                    if self.isUserInterestedInAd(dict){
                        guard let name = dict[Constants.ADNAMENODE] else{
                            print("ERROR: COULD NOT GET AD NAME")
                            return
                        }
                        guard let url = dict[Constants.ADURLNODE] else {
                            print("ERROR: COULD NOT GET URL FOR AD: \(name)")
                            return
                        }
                        guard let primaryTag = dict[Constants.ADPRIMARYTAGNODE] else {
                            print("ERROR: COULD NOT GET PRIMARY TAG FOR AD: \(name)")
                            return
                        }
                        let newMetaData = HypeAdMetaData(name: name, key: snapshot.key, url: url, primaryTag: primaryTag, isFromFriend: false, captionFromFriend: nil)
                        self.adsMetaDataQueue.enqueue(newMetaData)
                        print("ENQUEUED AD WITH KEY: \(snapshot.key)")
                        if self.adsMetaDataQueue.getTotalCount()<=Constants.MAXNUMADS{
                            self.appendAdIfRoom() 
                        }
                    }
                    if let nextKey = dict["nextKey"]{
                        self.nextQueueKey = nextKey
                        self.appendToQueueIfRoom(ref)
                    } else{
                        self.nextQueueKey = nil
                    }
                } else{
                    print("ERROR PARSING AD META DATA RESULTS")
                }
            })
            
        }
        
        
    }
    
    func isUserInterestedInAd(adDict: [String: String])->Bool{
        //switch so iterates through dictionary, write script so dict only has key if ad fits category
        for key in userInterests.getKeys(){
            guard let val = userInterests.getValueForKey(key) else{
                continue
            }
            if adDict[key] != nil && val{
                return true
            }
        }
        return false
    }

    
    func updateAdCount(){
        userRef.child(Constants.ADVIEWEDCOUNTNODE).setValue(userAdsViewed)
        let progress = userAdsViewed % Constants.ADSPERCONTENT
        progressBar.progress = Double(progress + 1)/Double(Constants.ADSPERCONTENT)
        if(progress) == Constants.ADSPERCONTENT - 1 {
            userContentCount += 1
            userRef.child(Constants.CONTENTCOUNTNODE).setValue(userContentCount)
        }
    }
    
    func resetMainView(){
        ads = [HypeAd]()
        adsMetaDataQueue = Queue<HypeAdMetaData>()
        numAdsSwiped = 0
        outOfCardsView.hidden = true
        mainSpinner.startAnimating()
        kolodaView.reloadData()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if let detachInfo = contentCountDetachInfo{
            detachInfo.ref.removeObserverWithHandle(detachInfo.handle)
        }
    }
    
    @IBAction func refreshButtonClicked(sender: AnyObject) {
        let ref = FIRDatabase.database().reference().child(Constants.ADSNODE)
        let nextAdKeyQuery = ref.queryOrderedByKey().queryLimitedToFirst(1)
        nextAdKeyQuery.observeSingleEventOfType(.ChildAdded, withBlock: {(snapshot) -> Void in
            self.nextQueueKey = snapshot.key
            self.resetMainView()
            self.appendToQueueIfRoom(self.adStoreRef)
        })

    }
    
    @IBAction func onSwipeRightClicked(sender: AnyObject){
        kolodaView.swipe(SwipeResultDirection.Right)
    }
    @IBAction func onSwipeLeftClicked(sender: AnyObject){
        kolodaView.swipe(SwipeResultDirection.Left)
    }
    
    func getUserID() -> String {
        return (FIRAuth.auth()?.currentUser?.uid)!
    }
    
    func getProxyIndex(index: Int) -> Int{
        return index - numAdsSwiped
    }

}

// KolodaView protocol that determines what cards to show
extension MainViewController: KolodaViewDataSource{
    func kolodaNumberOfCards(koloda: KolodaView) -> UInt{
        return UInt(ads.count + numAdsSwiped)
    }
    
    //Return a new view (card) to show from ImageStore
    func koloda(koloda: KolodaView, viewForCardAtIndex cardIndex: UInt) -> UIView {
        
        let ad = ads[getProxyIndex(Int(cardIndex))]
        return generateNewAdView(ad)

    }
    
    func generateNewAdView(ad: HypeAd) -> UIView {
        
        let superFrame = kolodaView.frameForTopCard()
        let newContainerView = UIView(frame: superFrame)
        
        newContainerView.layer.cornerRadius = 20
        newContainerView.layer.shadowOpacity = 0.6
        newContainerView.layer.shadowOffset = CGSizeZero
        newContainerView.layer.shadowRadius = 5
        
        guard let image = ad.getImage() else {
            print("ERROR GETTING ADD IMAGE")
            return newContainerView
        }
        
        let childFrame = CGRectInset(superFrame, 4, 4)
        let newChildView = UIImageView(frame: childFrame)
        newChildView.layer.cornerRadius = 20
        newChildView.layer.masksToBounds = true
        newChildView.image = image
        
        newContainerView.addSubview(newChildView)
        newContainerView.backgroundColor = UIColor.whiteColor()
        
        
        if ad.isFromFriend() {
            newContainerView.backgroundColor = UIColor(red: 255/255, green: 56/255, blue: 73/255, alpha: 1.0)
            if let caption = ad.getCaption(){
                let textViewFrame = CGRect(x: childFrame.minX, y: childFrame.maxY-65, width: childFrame.width, height: -55)
                let newTextView = UITextView(frame: textViewFrame)
                newTextView.text = caption
                newTextView.editable = false
                newTextView.font = UIFont.systemFontOfSize(20)
                newTextView.textAlignment = NSTextAlignmentFromCTTextAlignment(CTTextAlignment.Center)
                
                newTextView.layer.zPosition = 10
                newTextView.textColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1)
                newTextView.backgroundColor = UIColor(white: 1, alpha: 0.7)
                newContainerView.addSubview(newTextView)
            }
        }
        
        return newContainerView
    }
    
    func koloda(koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> OverlayView? {
        return NSBundle.mainBundle().loadNibNamed("CustomOverlayView", owner: self, options: nil)[0] as? OverlayView
    }
}

extension MainViewController: KolodaViewDelegate {

    
    func koloda(koloda: KolodaView, didSwipeCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        let newIndex = getProxyIndex(Int(index))
        
        let ad = ads[newIndex]
        
        if direction == .Up {
            delegate.onSwipeUp(ad, onClose: {(canceled: Bool) in
                if canceled{
                    self.kolodaView.revertAction()
                } else {
                    self.onCardSwiped(newIndex, ad: ad)
                }
            })
            return
        } else if direction == .Right {
            let cardsLikedRef = userRef.child(Constants.ADSLIKEDNODE)
            cardsLikedRef.child(ad.getKey()).setValue(ad.getMetaDataDict())
            
        }
        onCardSwiped(newIndex, ad: ad)
    }
    
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
        if ads.count > 0{
            kolodaView.reloadData()
        } else if !adsMetaDataQueue.isEmpty(){
            appendAdIfRoom()
        } else {
            outOfCardsView.hidden = false   
        }
    }
    
    func onCardSwiped(cardIndex: Int, ad: HypeAd){
        if ad.isFromFriend(){
            userRef.child(Constants.RECEIVEDADQUEUENODE).child(ad.getKey()).removeValue()
        }
        userRef.child(Constants.USERNEXTADKEY).setValue(ad.getKey())
        userAdsViewed += 1
        updateAdCount()
        numAdsSwiped += 1
        ads.removeAtIndex(cardIndex)
        appendAdIfRoom()
        appendToQueueIfRoom(adStoreRef)
    }
    
    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        let newIndex = getProxyIndex(Int(index))
        
        if let url = NSURL(string: ads[newIndex].getURL()){
            if #available(iOS 9.0, *) {
                let vc = SFSafariViewController(URL: url, entersReaderIfAvailable: false)
                presentViewController(vc, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
            }
            
        }
    }
    
    func koloda(koloda: KolodaView, allowedDirectionsForIndex index: UInt) -> [SwipeResultDirection] {
        return [SwipeResultDirection.Left, SwipeResultDirection.Right, SwipeResultDirection.Up]
    }

}

protocol MainViewControllerDelegate{
    func onSwipeUp(ad: HypeAd, onClose: (canceled: Bool)->Void)
}





