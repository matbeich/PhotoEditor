//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

import SnapKit
import UIKit

class TestVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(scrollView)
        view.addSubview(slider)
        view.addSubview(testButton)

        scrollView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 300, height: 300))
        }

        slider.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.right.equalToSuperview().offset(-10)
            make.left.equalToSuperview().offset(10)
        }

        testButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(slider.snp.top).offset(-24)
        }

        slider.maximumValue = 3
        slider.minimumValue = 0.2
        slider.value = 0.2
        slider.addTarget(self, action: #selector(change(with:)), for: .valueChanged)

        scrollView.delegate = self
        scrollView.maximumZoomScale = CGFloat(slider.maximumValue)
        scrollView.minimumZoomScale = CGFloat(slider.minimumValue)
        scrollView.backgroundColor = .black
        scrollView.setZoomScale(CGFloat(slider.value), animated: false)
    }

    @objc private func change(with slider: UISlider) {
        scrollView.setZoomScale(CGFloat(slider.value), animated: false)
    }

    @objc private func tap() {
//        scrollView.scrollRectToVisible(CGRect(origin: CGPoint(x: 50, y: 50), size: CGSize(width: 20, height: 20)), animated: true)
//
//        scrollView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
//        scrollView.center()
        print(scrollView.contentOffset)
    }

    let slider = UISlider()

    private lazy var scrollingview: UIView = {
        let scrollingview = UIView(frame: view.bounds)

        scrollingview.backgroundColor = .red
        scrollingview.addSubview(testView)

        return scrollingview
    }()

    private lazy var testView: UIView = {
        let testView = UIView(frame: CGRect(origin: CGPoint(x: 50, y: 50), size: CGSize(width: 20, height: 20)))
        testView.backgroundColor = .white

        return testView
    }()

    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.addSubview(scrollingview)
        scroll.contentSize = scrollingview.bounds.size

        return scroll
    }()

    private lazy var testButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.addTarget(self, action: #selector(tap), for: .touchUpInside)
        btn.setTitle("Scroll", for: .normal)

        return btn
    }()
}

extension TestVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollingview
    }
}
