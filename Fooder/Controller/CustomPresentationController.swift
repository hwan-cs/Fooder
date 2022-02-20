//
//  CustomPresentationController.swift
//  Fooder
//
//  Created by Jung Hwan Park on 2022/02/19.
//

import UIKit

class CustomPresentationController: UIPresentationController
{
    
    private lazy var blurView = UIVisualEffectView(effect: nil)
    
    override var shouldRemovePresentersView: Bool
    {
        return false
    }
    
    override func presentationTransitionWillBegin()
    {
        let container = containerView!
        blurView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(blurView)
        blurView.edges(to: container)
        blurView.alpha = 0.0
     
        presentingViewController.beginAppearanceTransition(false, animated: false)
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.blurView.effect = UIBlurEffect(style: .light)
            self.blurView.alpha = 1
        }, completion: nil)
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool)
    {
        presentingViewController.endAppearanceTransition()
    }
    
    override func dismissalTransitionWillBegin()
    {
        presentingViewController.beginAppearanceTransition(true, animated: true)
        presentedViewController.transitionCoordinator!.animate(alongsideTransition: { _ in
            self.blurView.alpha = 0.0
        }, completion: nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool)
    {
        presentingViewController.endAppearanceTransition()
        if completed {
            blurView.removeFromSuperview()
        }
    }
}

extension UIView
{
    func edges(to view: UIView, top: CGFloat=0, left: CGFloat=0, bottom: CGFloat=0, right: CGFloat=0)
    {
        NSLayoutConstraint.activate([
            self.leftAnchor.constraint(equalTo: view.leftAnchor, constant: left),
            self.rightAnchor.constraint(equalTo: view.rightAnchor, constant: right),
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: top),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom)
            ])
    }
}
