import RxSwift
import UIKit

class ShoppingCartVC: UIViewController {
    typealias ViewModel = ShoppingCartVM
    var viewModelFactory: (ViewModel.UIInputs) -> ViewModel = { _ in fatalError("factory not provided") }
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        let plusButtonTap = PublishSubject<IndexPath>()
        let minusButtonTap = PublishSubject<IndexPath>()
        let deleteButtonTap = PublishSubject<IndexPath>()
        let inputs = ViewModel.UIInputs(plusButtonTap: plusButtonTap.asObservable(), minusButtonTap: minusButtonTap.asObservable(), deleteButtonTap: deleteButtonTap)
        let vm = viewModelFactory(inputs)
        bind(viewModel: vm, plusButtonTap: plusButtonTap, minusButtonTap: minusButtonTap, deleteButtonTap: deleteButtonTap)
    }

    private func setupViews() {
        self.tabBarItem = UITabBarItem(title: "Shopping Cart", image: .checkmark, selectedImage: nil)
        
        self.tableView.register(UINib(nibName: "ShoppingCartTableViewCell", bundle: nil), forCellReuseIdentifier: "cartCell")
    }
    
    private func bind(viewModel: ViewModel, plusButtonTap: PublishSubject<IndexPath>, minusButtonTap: PublishSubject<IndexPath>, deleteButtonTap: PublishSubject<IndexPath>) {
        viewModel
            .items
            .bind(to: tableView.rx.items(cellIdentifier: "cartCell", cellType: ShoppingCartTableViewCell.self)) { index, viewModel, cell in
                cell.bind(viewModel: viewModel, at: IndexPath(row: index, section: 0), plusButtonTap: plusButtonTap.asObserver(), minusButtonTap: minusButtonTap.asObserver(), deleteButtonTap: deleteButtonTap)
            }
            .disposed(by: disposeBag)
        
        viewModel.quantityDidUpdate
            .asDriver { error in
            .empty()
            }
            .drive(onNext: { [tableView] in
                guard let cell = tableView?.cellForRow(at: $0.index) as? ShoppingCartTableViewCell else {
                    return
                }
                cell.quantityLabel.text = $0.quantity
            })
            .disposed(by: disposeBag)
        
        viewModel.badge
            .debug("badge")
            .asDriver(onErrorRecover: { error in
            .empty()
            })
            .drive(onNext: { [weak self] badgeValue in
                self?.tabBarItem.badgeValue = badgeValue
                if badgeValue.count == 0 {
                    self?.tabBarItem.badgeValue = nil
                }
            })
            .disposed(by: disposeBag)
    }
}
