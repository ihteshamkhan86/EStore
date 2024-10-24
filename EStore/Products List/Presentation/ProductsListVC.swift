import RxSwift
import RxCocoa
import RxRelay

class ProductsListVC: UIViewController {
    var viewModelFactory: (ProductsListVM.UIInputs) -> ProductsListVM = { _ in fatalError("factory not provided") }
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        let didSelectItem = collectionView.rx.itemSelected.asObservable()
        let addToCart = PublishSubject<IndexPath>()
        let inputs = ProductsListVM.UIInputs(didSelectItem: didSelectItem, addToCart: addToCart.asObservable())
        let vm = viewModelFactory(inputs)
        bind(viewModel: vm, addToCart: addToCart)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupLayout()
    }

    private func setupViews() {
        self.tabBarItem = UITabBarItem(title: "Products", image: UIImage.strokedCheckmark, selectedImage: nil)
        
        self.collectionView.register(UINib(nibName: "ProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "product")
        self.collectionView.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        self.collectionView.contentInset = Constants.collectionViewInset
       
    }
    
    private func setupLayout() {
        guard let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        layout.minimumLineSpacing = Constants.collectionViewLineSpacing
        layout.minimumInteritemSpacing = Constants.collectionViewInteritemSpacing
        
        let width = widthForItemWith(interItemSpacing: layout.minimumInteritemSpacing, numberOfColumns: UIDevice.current.orientation.isLandscape ? 3 : 2, totalWidth: view.bounds.width, leftInset: self.collectionView.contentInset.left, rightInset: self.collectionView.contentInset.right)
        layout.itemSize = CGSize(width: width, height: width)
    }
    
    private func bind(viewModel: ProductsListVM, addToCart: PublishSubject<IndexPath>) {
        viewModel.products
            .bind(to: collectionView.rx.items(cellIdentifier: "product", cellType: ProductCollectionViewCell.self)) { index, product,  cell in
                
                cell.bindViewModel(viewModel: product, at: IndexPath(row: index, section: 0), buttonClicked: addToCart.asObserver())
                   
            }
            .disposed(by: disposeBag)
    }
    
    private func widthForItemWith(interItemSpacing: CGFloat, numberOfColumns: Int, totalWidth: CGFloat, leftInset: CGFloat, rightInset: CGFloat) -> CGFloat {
        guard numberOfColumns > 1 else {
            return totalWidth
        }
        let newWidth = totalWidth-leftInset-rightInset
        let spacing = (CGFloat(numberOfColumns)-1)*interItemSpacing
        return (newWidth/CGFloat(numberOfColumns))-spacing
    }
    
    struct Constants {
        static let collectionViewInteritemSpacing: CGFloat = 8
        static let collectionViewLineSpacing: CGFloat = 32
        
        static let collectionViewInset = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
    }
}
