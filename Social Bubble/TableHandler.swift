import UIKit
import RxSugar
import RxSwift

class TableHandler: NSObject, UITableViewDelegate, UITableViewDataSource {
    let view = UITableView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), style: .plain)
    
    private let disposeBag = DisposeBag()
    let data: AnyObserver<[String]>
    private let _data = Variable<[String]>([])
    let selection: Observable<String>
    private let _selection = PublishSubject<String>()
    
    override init() {
        data = _data.asObserver()
        selection = _selection.asObservable()
        super.init()
        view.dataSource = self
        view.delegate = self
        view.register(GooglePlaceCell.self, forCellReuseIdentifier: GooglePlaceCell.reuseIdentifier)
        view.layer.borderColor = UIColor(hue:0.62, saturation:0.57, brightness:0.68, alpha:1.00).cgColor
        view.layer.borderWidth = 3
        rxs.disposeBag
            ++ view.rxs.reloadData <~ _data.asObservable().toVoid()
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _data.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GooglePlaceCell.reuseIdentifier) as? GooglePlaceCell else { return GooglePlaceCell() }
        if indexPath.row < _data.value.count - 1 {
            cell.place.text = _data.value[indexPath.row]
        } else {
            cell.attribution.image = UIImage(named: "powered_by_google_on_white")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _selection.onNext(_data.value[indexPath.row])
    }
}

class GooglePlaceCell: UITableViewCell {
    static let reuseIdentifier = "Cell"
    let place = UILabel()
    let attribution = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(hue:0.00, saturation:0.00, brightness:0.97, alpha:1.00)
        place.font = UIFont(name: "HelveticaNeue", size: 13)
        contentView.addSubview(place)
        contentView.addSubview(attribution)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let placeSize = place.sizeThatFits(bounds.size)
        place.frame = CGRect(x: bounds.minX + Padding.large, y: bounds.midY - placeSize.height/2, size: placeSize)
        let imageSize = attribution.sizeThatFits(bounds.size)
        attribution.frame = CGRect(x: bounds.midX - imageSize.width/2, y: bounds.midY - imageSize.height/2, size: imageSize)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        place.text = ""
        attribution.image = nil
    }
}
