import RxSwift
import Kingfisher
import RxKingfisher

class ProductDetailsVC: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    
    private let product: Product
    init(product: Product) {
        self.product = product
        super.init(nibName: "ProductDetailsVC", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = URL(string: self.product.thumbnail) {
            let imageResource = ImageResource(downloadURL: url, cacheKey: product.title)
            imageView.kf.rx.setImage(with: imageResource, placeholder: nil, options: nil)
                .subscribe()
                .disposed(by: disposeBag)
        }
        
        self.titleLabel.text = product.title
        self.descriptionLabel.text = product.description
        self.priceLabel.text = "$ " + product.price.description
    }


}
