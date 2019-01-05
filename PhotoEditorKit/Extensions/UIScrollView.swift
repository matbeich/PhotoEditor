//
// Copyright © 2018 Dimasno1. All rights reserved. Product:PhotoEditor
//

extension UIScrollView {
    func centerVerticallyWithView(_ view: UIView, animated: Bool = false) {
        let xOf = contentOffset.x
        let yOf = contentSize.height / 2 + view.center.y.distance(to: frame.minY)

        setContentOffset(CGPoint(x: xOf, y: yOf), animated: animated)
    }

    func centerHorizontallyWithView(_ view: UIView, animated: Bool = false) {
        let xOf = contentSize.width / 2 + view.center.x.distance(to: frame.minX)
        let yOf = contentOffset.y

        setContentOffset(CGPoint(x: xOf, y: yOf), animated: animated)
    }

    func centerWithView(_ view: UIView, animated: Bool = false) {
        let xOf = contentSize.width / 2 + view.center.x.distance(to: frame.minX)
        let yOf = contentSize.height / 2 + view.center.y.distance(to: frame.minY)

        setContentOffset(CGPoint(x: xOf, y: yOf), animated: animated)
    }
}
