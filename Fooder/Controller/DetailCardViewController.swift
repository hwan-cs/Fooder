//
//  DetailCardViewController.swift
//  Fooder
//
//  Created by Jung Hwan Park on 2022/02/20.
//

import UIKit

class DetailCardViewController: UIViewController
{
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    var dismissClosure: (()->())?
    
    var placeID: String
    
    var interactiveStartingPoint: CGPoint? = nil

    var draggingDownToDismiss = false
    
    var backImage: String?
    
    private lazy var dismissPanGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer()
        gesture.maximumNumberOfTouches = 1
        gesture.addTarget(self, action: #selector(handleDismissPan(gesture:)))
        gesture.delegate = self
        return gesture
    }()
    
    lazy var scrollView: DetailScrollView = {
        let frame = self.view.bounds
        let view = DetailScrollView(frame: frame, id: self.placeID)
        view.delegate = self
        return view
    }()
    
    lazy var closeBtn: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: UIScreen.main.bounds.size.width - 20 - 30, y: 20, width: 30, height: 30)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        return button
    }()
    
    init(_ placeID: String)
    {
        self.placeID = placeID
        super.init(nibName: nil, bundle: nil)
        self.setupTranstion()
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setUI()
        getImageFromCell()
    }
}

// MARK: - Extensions

extension DetailCardViewController
{
    private func setupTranstion()
    {
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    private func setUI()
    {
        self.view.backgroundColor = .white
        self.view.layer.masksToBounds = true
        view.addSubview(scrollView)
        view.addSubview(closeBtn)
        view.addGestureRecognizer(dismissPanGesture)
        
        if #available(iOS 11.0, *)
        {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        else
        {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    private func getImageFromCell()
    {
        if let backImage = backImage
        {
            scrollView.imageView.image = UIImage(named: backImage)
        }
    }
    
    private func stopDismissPanGesture(_ gesture: UIPanGestureRecognizer)
    {
        draggingDownToDismiss = false
        interactiveStartingPoint = nil
        scrollView.showsVerticalScrollIndicator = true
        
        UIView.animate(withDuration: 0.2)
        {
            gesture.view?.transform = CGAffineTransform.identity
        }
    }

    // MARK: - @objc Methods
    
    @objc private func closeAction()
    {
        dismiss(animated: true, completion: nil)
        dismissClosure?()
    }
    
    @objc private func handleDismissPan(gesture: UIPanGestureRecognizer)
    {
        if !draggingDownToDismiss
        {
            return
        }
        
        let startingPoint: CGPoint
        
        if let p = interactiveStartingPoint
        {
            startingPoint = p
        }
        else
        {
            startingPoint = gesture.location(in: nil)
            interactiveStartingPoint = startingPoint
        }

        let currentLocation = gesture.location(in: nil)
        
        var progress = (currentLocation.y - startingPoint.y) / 100
        
        //prevent viewController bigger when scrolling up
        if currentLocation.y <= startingPoint.y
        {
            progress = 0
        }
        
        if progress >= 1.0
        {
//            let transition: CATransition = CATransition()
//            transition.duration = 0.5
//            transition.type = CATransitionType.fade
//            transition.subtype = CATransitionSubtype.fromRight
//            self.view.window!.layer.add(transition, forKey: kCATransition)
//            self.dismiss(animated: false, completion: nil)
            self.dismiss(animated: true, completion: nil)
            dismissClosure?()
            stopDismissPanGesture(gesture)
            return
        }

        let targetShrinkScale: CGFloat = 0.86
        let currentScale: CGFloat = 1 - (1 - targetShrinkScale) * progress
        
        switch gesture.state
        {
            case .began,.changed:
                scrollView.isScrollEnabled = false
                gesture.view?.transform = CGAffineTransform(scaleX: currentScale, y: currentScale)
                gesture.view?.layer.cornerRadius = 10 * (progress)
                scrollView.showsVerticalScrollIndicator = false
            case .cancelled,.ended:
                scrollView.isScrollEnabled = true
                stopDismissPanGesture(gesture)
            default:
                break
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension DetailCardViewController: UIViewControllerTransitioningDelegate
{
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return PopAnimator(animationType: .present)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return PopAnimator(animationType: .dismiss)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController?
    {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

// MARK: - UIScrollViewDelegate

extension DetailCardViewController: UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        // 여기 공부해보기 위 스크롤이 바운스가 안됨.
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset = .zero
            draggingDownToDismiss = true
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension DetailCardViewController: UIGestureRecognizerDelegate
{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
