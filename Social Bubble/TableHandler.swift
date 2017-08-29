import UIKit
import RxSugar
import RxSwift

class TableHandler: NSObject, UITableViewDelegate, UITableViewDataSource {
    let view = UITableView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), style: .plain)
    private static let reuseIdentifier = "Cell"
    
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
        view.register(UITableViewCell.self, forCellReuseIdentifier: TableHandler.reuseIdentifier)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableHandler.reuseIdentifier) else { return UITableViewCell() }
        cell.textLabel?.text = _data.value[indexPath.row]
        styleCell(cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _selection.onNext(_data.value[indexPath.row])
    }
    
    private func styleCell(_ cell: UITableViewCell) {
        cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 13)
        cell.backgroundColor = UIColor(hue:0.00, saturation:0.00, brightness:0.97, alpha:1.00)
        addRadius(toCorner: [.bottomLeft, .bottomRight], ofView: view)
    }
}
