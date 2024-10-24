import RxSwift
import Kingfisher
import RxKingfisher

class ShoppingCartTableViewCell: UITableViewCell {
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var subtractButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    private var disposeBag: DisposeBag! = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        disposeBag = nil
        disposeBag = DisposeBag()
    }
    private func bind(viewModel: ShoppingCartCellVM) {
        if let url = URL(string: viewModel.imagePath) {
            let imageResource = ImageResource(downloadURL: url, cacheKey: viewModel.title)
            productImageView.kf.rx.setImage(with: imageResource, placeholder: nil, options: nil)
                .subscribe()
                .disposed(by: disposeBag)
        }
        
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
        priceLabel.text = viewModel.price

        quantityLabel.text = viewModel.quantity
    }
 
    func bind<Observer>(viewModel: ShoppingCartCellVM, at index: IndexPath, plusButtonTap: Observer, minusButtonTap: Observer, deleteButtonTap: Observer) where Observer: ObserverType, Observer.Element == IndexPath {
        
        bind(viewModel: viewModel)
        
        plusButton.rx
            .tap
            .map {
                index
            }
            .bind(to: plusButtonTap)
            .disposed(by: disposeBag)
        
        subtractButton.rx
            .tap
            .map {
                index
            }
            .bind(to: minusButtonTap)
            .disposed(by: disposeBag)
        
        deleteButton.rx
            .tap
            .map {
                index
            }
            .bind(to: deleteButtonTap)
            .disposed(by: disposeBag)
    }
}
