import UIKit

extension CGRect {
    public init(x: CGFloat, y: CGFloat, size: CGSize) {
        self.init(x: x, y: y, width: size.width, height: size.height)
    }
}

extension String {
    func formatText() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "")
    }
}

struct Padding {
    static let tiny: CGFloat = 4
    static let small: CGFloat = 8
    static let large: CGFloat = 16
}

func addRadius(toCorner corner: UIRectCorner, ofView view: UIView) {
    let shapeLayer = CAShapeLayer()
    shapeLayer.bounds = view.frame
    shapeLayer.position = view.center
    shapeLayer.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [corner], cornerRadii: CGSize(width: 3, height: 3)).cgPath
    view.layer.mask = shapeLayer
}


