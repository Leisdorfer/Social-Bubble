import UIKit

class PlaceholderPaddedTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        font = UIFont(name: "HelveticaNeue", size: 13)
        textColor = UIColor(hue:0.62, saturation:0.57, brightness:0.68, alpha:1.00)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: bounds).insetBy(dx: Padding.large, dy: Padding.tiny)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: bounds).insetBy(dx: Padding.large, dy: Padding.tiny)
    }
    
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return super.editingRect(forBounds: bounds).insetBy(dx: Padding.large, dy: Padding.tiny)
    }
}

