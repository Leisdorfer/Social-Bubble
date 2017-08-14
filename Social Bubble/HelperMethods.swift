import UIKit

extension CGRect {
    public init(x: CGFloat, y: CGFloat, size: CGSize) {
        self.init(x: x, y: y, width: size.width, height: size.height)
    }
}

struct Padding {
    static let tiny: CGFloat = 4
    static let small: CGFloat = 8
    static let large: CGFloat = 16
}

