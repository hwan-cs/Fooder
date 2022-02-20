//
//  ViewController.swift
//  Fooder
//
//  Created by Jung Hwan Park on 2022/02/19.
//

import UIKit
import VerticalCardSwiper

class CardViewController: UIViewController, VerticalCardSwiperDatasource, VerticalCardSwiperDelegate
{

    var selectedCell: MyVerticalCardSwiper?
    
    @IBOutlet var cardSwiper: VerticalCardSwiper!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        cardSwiper.delegate = self
        cardSwiper.datasource = self
        cardSwiper.isSideSwipingEnabled = false
        cardSwiper.register(nib: UINib(nibName: K.cardSwiperNibName, bundle: nil), forCellWithReuseIdentifier: K.cardSwiperNibName)
    }
    
    //MARK: - VerticalCardSwiper DataSource Methods
    func cardForItemAt(verticalCardSwiperView: VerticalCardSwiperView, cardForItemAt index: Int) -> CardCell
    {
        guard let cell =  verticalCardSwiperView.dequeueReusableCell(withReuseIdentifier: K.cardSwiperNibName, for: index) as? MyVerticalCardSwiper else {
            return CardCell()
        }
        cell.initCell(background: "img1", title: "Foobar", subtitle: "test123")
        
        return cell
    }
    
    func numberOfCards(verticalCardSwiperView: VerticalCardSwiperView) -> Int
    {
        return 10
    }
    
    //MARK: - VerticalCardSwiper Delegate Methods
    func didTapCard(verticalCardSwiperView: VerticalCardSwiperView, index: Int)
    {
        let detailVC = DetailCardViewController()

        let cell = cardSwiper.cardForItem(at: index) as? MyVerticalCardSwiper
        print(cell)
        selectedCell = cell
        detailVC.dismissClosure = { [weak self] in
//            guard let StrongSelf = self else { return }
//            StrongSelf.updateStatusBar(visible: true)
        }
        detailVC.backImage = "img2"
//        updateStatusBar(visible: false)
        present(detailVC, animated: true, completion: nil)
    }
}

