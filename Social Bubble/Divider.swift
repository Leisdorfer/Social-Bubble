import UIKit

class Divider: UIView {
    private let height: CGFloat = 1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.opacity = 0.5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: height)
    }
}
