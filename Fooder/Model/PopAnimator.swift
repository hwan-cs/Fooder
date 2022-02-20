//
//  PopAnimator.swift
//  Fooder
//
//  Created by Jung Hwan Park on 2022/02/20.
//

import UIKit

fileprivate let transitonDuration: TimeInterval = 1.0

enum AnimationType
{
    case present
    case dismiss
}

class PopAnimator: NSObject
{
    let animationType: AnimationType
    
    init(animationType: AnimationType)
    {
        self.animationType = animationType
        super.init()
    }
}

// MARK: - Extensions

extension PopAnimator
{
    func animationForPresent(using transitionContext: UIViewControllerContextTransitioning)
    {
        let containerView = transitionContext.containerView
        //1.Get fromVC and toVC
        guard let fromVC = transitionContext.viewController(forKey: .from) as? UITabBarController else { return }
        guard let mainVC = fromVC.viewControllers?.first as? CardViewController else { return }
        guard let toVC = transitionContext.viewController(forKey: .to) as? DetailCardViewController else { return }
        guard let selectedCell = mainVC.selectedCell else { return }
        
        let frame = selectedCell.convert(selectedCell.bgView.frame, to: fromVC.view)
//        let frame = CGRect(x: selectedCell.bgView.frame.midX, y: selectedCell.bgView.frame.midY, width: selectedCell.bgView.frame.width, height: 500)
        
        //2.Set presentation original size.
        toVC.view.frame = frame
        toVC.view.layer.cornerRadius = 10
        
        toVC.scrollView.imageView.frame.size.width = UIScreen.main.bounds.width - 40
        toVC.scrollView.imageView.frame.size.height = 500
        
        containerView.addSubview(toVC.view)
        
        //3.Change original size to final size with animation.
        UIView.animate(withDuration: transitonDuration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            toVC.view.frame = UIScreen.main.bounds
            toVC.view.layer.cornerRadius = 10
            toVC.scrollView.imageView.frame.size.width = UIScreen.main.bounds.width
            toVC.scrollView.imageView.frame.size.height = 500
            toVC.closeBtn.alpha = 1

            fromVC.tabBar.frame.origin.y = UIScreen.main.bounds.height
        }) { completed in
            transitionContext.completeTransition(completed)
        }
    }
    
    func animationForDismiss(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? DetailCardViewController else { return }
        guard let toVC = transitionContext.viewController(forKey: .to) as? UITabBarController else { return }
        guard let mainVC = toVC.viewControllers?.first as? CardViewController else { return }
        guard let selectedCell = mainVC.selectedCell else { return }
        
        UIView.animate(withDuration: transitonDuration / 2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: {
            let frame = selectedCell.convert(selectedCell.bgView.frame, to: fromVC.view)

            fromVC.view.frame = frame
            fromVC.view.layer.cornerRadius = 10
            fromVC.scrollView.imageView.frame.size.width = UIScreen.main.bounds.width - 40
            fromVC.scrollView.imageView.frame.size.height = 500
            fromVC.closeBtn.alpha = 0
            
            toVC.tabBar.frame.origin.y = UIScreen.main.bounds.height - toVC.tabBar.frame.height
        }) { completed in
            transitionContext.completeTransition(completed)
        }
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension PopAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitonDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if animationType == .present {
            animationForPresent(using: transitionContext)
        } else {
            animationForDismiss(using: transitionContext)
        }
    }
}
