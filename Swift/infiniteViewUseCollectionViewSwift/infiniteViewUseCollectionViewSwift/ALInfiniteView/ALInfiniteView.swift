//
//  ALInfiniteView.swift
//  infiniteViewUseCollectionViewSwift
//
//  Created by April on 2017/7/18.
//  Copyright © 2017年 April. All rights reserved.
//

import UIKit

let ALInfiniteCellIdentifier = "ALInfiniteCellIdentifier"

protocol ALInfiniteViewDelegate {
    func alInfiniteViewDidSelectedItem(infiniteView: ALInfiniteView, selectedIndex: Int)
}

class ALInfiniteView: UIView {
    
    @IBOutlet weak var backgroudImageView: UIImageView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet var alInfiniteView: UIView!
    @IBOutlet weak var ALInfiniteCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var originItems: Array<Any>?
    var infiniteItems = [Any]()
    var autoScrollTimer: Timer?
    
    var delegate: ALInfiniteViewDelegate?
    
    override init(frame: CGRect) { //code
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) { //IB
        super.init(coder: aDecoder)
        setup()
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setup() {
        Bundle.main.loadNibNamed("ALInfiniteView", owner: self, options: nil)
        addSubview(alInfiniteView)
        alInfiniteView.frame = self.bounds
        alInfiniteView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        setupCollectionView()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //MARK: - View Setup
    
    private func setupCollectionView () {
        
        let cellNib = UINib.init(nibName: "ALInfiniteViewCell", bundle: nil)
        ALInfiniteCollectionView.register(cellNib, forCellWithReuseIdentifier: ALInfiniteCellIdentifier)
        
        ALInfiniteCollectionView.delegate = self
        ALInfiniteCollectionView.dataSource = self
        ALInfiniteCollectionView.scrollsToTop = false
    }
    
    func setInfiniteViewItems (orginItems: [[String: Any]]) {
        self.originItems = orginItems
        
        infiniteItems = createInfiniteItems(originItems: orginItems)
        pageControl.numberOfPages = originItems!.count
    }
    
    //MARK: - Infinite Items

    private func createInfiniteItems(originItems: [[String: Any]]) -> [[String: Any]]{
        if originItems.count <= 1 {
            return originItems
        }
        
        let firstItem = originItems.first
        let lastItem = originItems.last
        
        var infiniteItems = originItems
        
        infiniteItems.insert(lastItem!, at: 0)
        infiniteItems.append(firstItem!)
        
        return infiniteItems
    }
    
    //MARK: - Scroll Action
    func scrollToVisibleFirstItem() {
        guard originItems!.count > 1 else {
            return
        }
        
        ALInfiniteCollectionView.scrollToItem(at: IndexPath(row: 1, section: 0) , at: .left, animated: false)
        pageControl.currentPage = 0
    }

    //MARK: - PageControl
    @IBAction func pageControlValueChanged(_ sender: Any) {
        let pageWidth = ALInfiniteCollectionView.bounds.size.width
        let scrollTo = CGPoint(x: (pageWidth * (CGFloat)(pageControl.currentPage + 1)), y: 0)
        
        ALInfiniteCollectionView.setContentOffset(scrollTo, animated: true)
    }
    
    func setPageCotrolTheCurrentPage(scrollView: UIScrollView) {
        let pageWidth = ALInfiniteCollectionView.bounds.size.width
        let contentOffsetX = scrollView.contentOffset.x
        
        pageControl.currentPage = ((Int)(contentOffsetX / pageWidth) - 1)
    }
    
    //MARK: - AutoScroll
    
    func startAutoScroll() {
        guard infiniteItems.count > 1 else {
            return
        }
        
        if autoScrollTimer != nil {
            stopAutoScroll()
        }
        
        scrollToVisibleFirstItem()
        
        autoScrollTimer = Timer(timeInterval: 5.0, target: self, selector: #selector(autoScrollAction), userInfo: nil, repeats: true)
        
    }
    
    func autoScrollAction() {
        let offset = ALInfiniteCollectionView.contentOffset.x + ALInfiniteCollectionView.bounds.size.width
        ALInfiniteCollectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
    }
    
    func stopAutoScroll() {
        if autoScrollTimer != nil {
            autoScrollTimer?.invalidate()
            autoScrollTimer = nil
        }
    }
}

extension ALInfiniteView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.alInfiniteViewDidSelectedItem(infiniteView: self, selectedIndex: indexPath.item)
    }
}

extension ALInfiniteView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return infiniteItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemInfo: Dictionary = infiniteItems[indexPath.row] as! [String: Any]
        
        let infiniteCell = collectionView.dequeueReusableCell(withReuseIdentifier: ALInfiniteCellIdentifier, for: indexPath) as! ALInfiniteViewCell
        
        infiniteCell.tag = indexPath.item
        infiniteCell.nameLabel.text = itemInfo["Name"] as? String
        infiniteCell.contentImageView.backgroundColor = itemInfo["Color"] as? UIColor
        
        return infiniteCell
    }
}

extension ALInfiniteView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

extension ALInfiniteView: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       
        struct lastOffsetX {
            static var lastContentOffsetX = CGFloat.leastNormalMagnitude
        }

        // Ignore the first time scroll
        if lastOffsetX.lastContentOffsetX == CGFloat.leastNormalMagnitude {
            lastOffsetX.lastContentOffsetX = scrollView.contentOffset.x
        }
        
        let currentOffsetX = scrollView.contentOffset.x
        let currentOffsetY = scrollView.contentOffset.y
        
        let pageWidth = scrollView.bounds.size.width
        let offset = pageWidth * CGFloat((infiniteItems.count - 2))
        
        //the first page (showing the last item) is visible and user is still scrolling to the left
        if currentOffsetX < pageWidth && lastOffsetX.lastContentOffsetX > currentOffsetX {
            lastOffsetX.lastContentOffsetX = currentOffsetX + offset
            scrollView.contentOffset = CGPoint(x: lastOffsetX.lastContentOffsetX, y: currentOffsetY)
        } else if currentOffsetX > offset && lastOffsetX.lastContentOffsetX < currentOffsetX {
            //the last page (showing the first item) is visible and use is still scrolling to the right
            lastOffsetX.lastContentOffsetX = currentOffsetX - offset
            scrollView.contentOffset = CGPoint(x: lastOffsetX.lastContentOffsetX, y: currentOffsetY)
        } else {
            lastOffsetX.lastContentOffsetX = currentOffsetX
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setPageCotrolTheCurrentPage(scrollView: scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        setPageCotrolTheCurrentPage(scrollView: scrollView)
    }
}
