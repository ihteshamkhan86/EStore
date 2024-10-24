import RxSwift
import RxRelay

class ProductCellVM {
    let imagePath: String
    let title: String
    let price: String
    init(imagePath: String, title: String, price: String) {
        self.imagePath = imagePath
        self.title = title
        self.price = price
    }
}
class ProductsListVM {
    struct UIInputs {
        let didSelectItem: Observable<IndexPath>
        let addToCart: Observable<IndexPath>
    }
    
    let products: Observable<[ProductCellVM]>
    let selectedProduct: Observable<Product>
    let addToCart: Observable<Product>
    
    init(inputs: UIInputs,
         getProductsService: GetProductsService) {
        let productsList = getProductsService.getProducts()
            .map {
                $0.products
            }
            .share()
        
        self.products = productsList.map { list in
            list.map { product in
                ProductCellVM(imagePath: product.thumbnail, title: product.title, price: "$ \(product.price.description)")
            }
        }
        
        self.selectedProduct = Observable.combineLatest(inputs.didSelectItem, productsList)
            .compactMap { (indexPath, products) -> Product? in
                guard indexPath.row < products.count else {
                    return nil
                }
                return products[indexPath.row]
                
            }
        
        self.addToCart = Observable.combineLatest(inputs.addToCart, productsList)
            .compactMap { index, products in
                guard index.row < products.count else {
                    return nil
                }
                return products[index.row]
            }
    }
}
