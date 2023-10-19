//
//  RecommendPagingView.swift
//  Kkuk
//
//  Created by se-ryeong on 2023/10/19.
//

import UIKit

final class RecommendPagingView: UIView {
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        
        return view
    }()
    
    private let pageControl: CustomPageControl = {
        let control = CustomPageControl()
        control.numberOfPages = 3
        control.currentPage = 0
        control.pageIndicatorTintColor = .subgray2
        control.currentPageIndicatorTintColor = .white
        control.indicatorImage = UIImage.init(systemName: "circle")
        control.currentIndicatorImage = UIImage(systemName: "circle.fill")
        
        return control
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.scrollView)
        self.addSubview(self.pageControl)
        
        self.scrollView.delegate = self
        
        self.scrollView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }
        
        self.pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(scrollView.snp.bottom)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setItems(items: [String]) {
        self.pageControl.numberOfPages = items.count
        let width = UIScreen.main.bounds.width-40
        let padding: CGFloat = 20
        for index in 0..<items.count {
            let view = RecommendView()
            view.configureRecommend(content: items[index], image: nil)
            
            let xPosition = UIScreen.main.bounds.width * CGFloat(index) + padding
            self.scrollView.contentSize.width = width * CGFloat(index+2)
            self.scrollView.addSubview(view)
            view.frame = CGRect(x: xPosition, y: 0, width: width, height: 236)
        }
    }
    
    func resetItem() {
        self.scrollView.subviews.forEach {
            $0.removeFromSuperview()
        }
    }
}
extension RecommendPagingView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) { // scrollView가 스와이프 될 때 발생 될 이벤트
        self.pageControl.currentPage = Int(round(scrollView.contentOffset.x / (UIScreen.main.bounds.width)))
    }
}
