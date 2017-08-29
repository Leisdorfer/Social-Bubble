import UIKit
import RxSwift
import RxSugar

class PlaceholderPaddedTextField: UITextField, UITextFieldDelegate {
    let searchTerm: Observable<String>
    private let _searchTerm = PublishSubject<String>()
    let editingStarted: Observable<Void>
    private let _editingStarted = PublishSubject<Void>()
    
    override init(frame: CGRect) {
        searchTerm = _searchTerm.asObservable()
        editingStarted = _editingStarted.asObservable()
        super.init(frame: frame)
        backgroundColor = UIColor(hue:0.00, saturation:0.00, brightness:0.97, alpha:1.00)
        font = UIFont(name: "HelveticaNeue", size: 13)
        textColor = UIColor(hue:0.62, saturation:0.57, brightness:0.68, alpha:1.00)
        delegate = self
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let searchTerm = (text as NSString).replacingCharacters(in: range, with: string)
        _editingStarted.onNext()
        _searchTerm.onNext(searchTerm)
        return true
    }
}

