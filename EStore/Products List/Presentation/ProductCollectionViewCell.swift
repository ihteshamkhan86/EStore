import RxSwift
import Kingfisher
import RxKingfisher

class ProductCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    private let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .white
    }
 
    private func bind(viewModel: ProductCellVM) {
        self.titleLabel.text = viewModel.title
        self.priceLabel.text = viewModel.price
        
        if let url = URL(string: viewModel.imagePath) {
            let imageResource = ImageResource(downloadURL: url, cacheKey: viewModel.title)
            imageView.kf.rx.setImage(with: imageResource, placeholder: nil, options: nil)
                .subscribe()
                .disposed(by: disposeBag)
        }
    }
    
    func bindViewModel<Observer>(viewModel: ProductCellVM,  at index: IndexPath, buttonClicked: Observer, share: Observer) where Observer: ObserverType, Observer.Element == IndexPath {
        addToCartButton.rx.tap
            .map {
                index
            }
            .bind(to: buttonClicked)
            .disposed(by: disposeBag)
        
        shareButton.rx.tap
            .map {
                index
            }
            .bind(to: share)
            .disposed(by: disposeBag)
        
        bind(viewModel: viewModel)
    }
}
