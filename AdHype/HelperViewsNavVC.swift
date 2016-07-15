//
//  HelperViewsNavVC.swift
//  AdHype
//
//  Created by Maxwell Payson on 6/27/16.
//  Copyright © 2016 Enas400. All rights reserved.
//

import UIKit

enum HelperViewSection{
    case MainView
    case GridView
    case SocialView
    case AllViews
}

class HelperViewsNavVC: CustomNavVC{
    
    @IBOutlet weak var pageIndicatorContainerView: UIView!
    var indicatorViews = [UIView]()
    let indicatorSpacing: CGFloat =  3.0
    let indicatorDimension: CGFloat = 10.0
    var section: HelperViewSection!
    
    @IBOutlet weak var helperNavVCContainerView: UIView!{
        didSet{
            super.containerView = helperNavVCContainerView
        }
    }
    
    var pageVCIDs: [String]!
    
  
    var curVCIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch section!{
        case HelperViewSection.MainView:
            pageVCIDs = ["rightSwipePageVCNEW", "leftSwipePageVCNEW", "tapCardHelperVC", "upSwipePageVCNEW", "pointHelperVC"]
        case HelperViewSection.GridView:
            pageVCIDs = ["firstBoardHelperVC", "doubleTapBoardHelper", "boardHelperVC", "clickAdBoardHelperVC", "friendBoardHelperVC"]
        case HelperViewSection.SocialView:
            pageVCIDs = ["firstSocialPageVC", "addPublicCaptionHelperVC", "addNewCaptionHelperVC", "clickSendHelperVC", "sendAdHelperVC"]
        case HelperViewSection.AllViews:
            pageVCIDs = ["rightSwipePageVCNEW", "leftSwipePageVCNEW", "tapCardHelperVC", "upSwipePageVCNEW", "pointHelperVC", "firstSocialPageVC", "addPublicCaptionHelperVC", "addNewCaptionHelperVC", "clickSendHelperVC", "sendAdHelperVC", "firstBoardHelperVC", "doubleTapBoardHelper", "boardHelperVC", "clickAdBoardHelperVC", "friendBoardHelperVC"]
        }
        
        let firstVC = createGeneralViewControllerForID("HelperViews", vcID: pageVCIDs.first!)
        setSwipeGestureRecognizersOnView(firstVC.view)
        setActiveViewController(nil, viewController: firstVC)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        generatePageIndicators()
    }
    func setSwipeGestureRecognizersOnView(view: UIView){
        let rsgr = UISwipeGestureRecognizer(target: self, action: #selector(HelperViewsNavVC.handleSwipeRight))
        rsgr.direction = .Right
        rsgr.delegate = self
        view.addGestureRecognizer(rsgr)
        
        let lsgr = UISwipeGestureRecognizer(target: self, action: #selector(HelperViewsNavVC.handleSwipeLeft))
        lsgr.direction = .Left
        lsgr.delegate = self
        view.addGestureRecognizer(lsgr)
        
    }
    
    func generatePageIndicators(){
        let containerOrigin = CGPointMake(CGRectGetMidX(pageIndicatorContainerView.bounds),
                                          CGRectGetMidY(pageIndicatorContainerView.bounds))
        let stepSize = indicatorSpacing + indicatorDimension
        let furthestLeftX = containerOrigin.x - (stepSize * CGFloat(pageVCIDs.count) / 2)
        let size = CGSize(width: indicatorDimension, height: indicatorDimension)
        for i in 0..<pageVCIDs.count{
            let origin = CGPoint(x: furthestLeftX + stepSize * CGFloat(i), y: containerOrigin.y - 5)
            let newRect = CGRect(origin: origin, size: size)
            let newView = UIView(frame: newRect)
            newView.layer.zPosition = 32
            if i == 0{
                newView.backgroundColor = UIColor.grayColor()
            } else{
                newView.backgroundColor = UIColor.whiteColor()
            }
            
            newView.layer.cornerRadius = indicatorDimension/2
            pageIndicatorContainerView.addSubview(newView)
            indicatorViews.append(newView)
        }
    }
    
    @IBAction func onCloseButtonClicked(sender: AnyObject) {
        
        if section == HelperViewSection.SocialView{
            self.performSegueWithIdentifier("unwindFromHelpToSocialSegue", sender: nil)
        } else if section == HelperViewSection.MainView{
            self.performSegueWithIdentifier("unwindFromLoginHelptoMainSegue", sender: nil)
        }
        else{
           self.performSegueWithIdentifier("unwindFromHelperViewsSegue", sender: nil)
        }
        
    }
    
}

extension HelperViewsNavVC: UIGestureRecognizerDelegate{
    func handleSwipeRight(gestureRecognizer: UISwipeGestureRecognizer){
        let nextIndex = curVCIndex - 1
        guard nextIndex >= 0 else {
            return
        }

        indicatorViews[nextIndex].backgroundColor = UIColor.grayColor()
        indicatorViews[self.curVCIndex].backgroundColor = UIColor.whiteColor()
        let vc = createGeneralViewControllerForID("HelperViews", vcID: pageVCIDs[nextIndex])
        setSwipeGestureRecognizersOnView(vc.view)
        setActiveViewController(.toRight, viewController: vc)
        curVCIndex = nextIndex
    }

    func handleSwipeLeft(gestureRecognizer: UISwipeGestureRecognizer){
        let nextIndex = curVCIndex + 1
        guard nextIndex < pageVCIDs.count else {
            return
        }

        indicatorViews[nextIndex].backgroundColor = UIColor.grayColor()
        indicatorViews[self.curVCIndex].backgroundColor = UIColor.whiteColor()

        let vc = createGeneralViewControllerForID("HelperViews", vcID: pageVCIDs[nextIndex])
        setSwipeGestureRecognizersOnView(vc.view)
        setActiveViewController(.toLeft, viewController: vc)
        curVCIndex = nextIndex
    }
    
}