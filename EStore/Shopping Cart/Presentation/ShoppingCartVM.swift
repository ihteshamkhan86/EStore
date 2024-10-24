import RxSwift
import RxRelay
import Foundation

class ShoppingCartCellVM {
    let quantity: String
    let imagePath: String
    let title: String
    let description: String
    let price: String
    
    init(quantity: String, title: String, description: String, price: String, imagePath: String) {
        self.quantity = quantity
        self.title = title
        self.description = description
        self.price = price
        self.imagePath = imagePath
    }
}

fileprivate class SelectedProduct: Hashable {
    let product: Product
    var quantity: UInt
    
    init(product: Product, quantity: UInt) {
        self.product = product
        self.quantity = quantity
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(product.id)
    }
    
    static func == (lhs: SelectedProduct, rhs: SelectedProduct) -> Bool {
        lhs.product.id == rhs.product.id
    }
}

class ShoppingCartVM {
    struct UIInputs {
        let plusButtonTap: Observable<IndexPath>
        let minusButtonTap: Observable<IndexPath>
        let deleteButtonTap: Observable<IndexPath>
    }
    
    private let selectedItems = BehaviorRelay<[SelectedProduct]>(value: [])
    
    let items: Observable<[ShoppingCartCellVM]>
    let quantityDidUpdate: Observable<(index: IndexPath, quantity: String)>
    let badge: Observable<String>
    
    init(inputs: UIInputs,
         addToCart: Observable<Product>) {
        let selected = addToCart
            .compactMap { [selectedItems] product -> [SelectedProduct] in
                var array = selectedItems.value
                let first = array.first {
                    $0.product.id == product.id
                }
                if let selected = first {
                    selected.quantity += 1
                } else {
                    let selectedProduct = SelectedProduct(product: product, quantity: 1)
                    array.append(selectedProduct)
                }
                
                selectedItems.accept(array)
                return array
            }
        
        let delete = inputs.deleteButtonTap
            .compactMap { [selectedItems] index -> [SelectedProduct]? in
                var products = selectedItems.value
                guard index.row < products.count else {
                    return nil
                }
                products.remove(at: index.row)
                selectedItems.accept(products)
                return products
            }
        
        let selectedOrDelete = Observable.merge(selected, delete).share()
        
        self.items = selectedOrDelete
            .map {
                $0.map {
                    ShoppingCartCellVM(quantity: $0.quantity.description, title: $0.product.title, description: $0.product.description, price: "$ " + $0.product.price.description, imagePath: $0.product.thumbnail)
                }
            }
        
        let plusTap = inputs.plusButtonTap
            .map({ [selectedItems] index in
                return (selectedItems.value, index)
            })
            .compactMap { (products, index) -> (SelectedProduct, IndexPath)? in
                guard index.row < products.count else {
                    return nil
                }
                return (products[index.row], index)
            }
            .do(onNext: {
                guard $0.0.quantity < 99 else {
                    return
                }
                $0.0.quantity += 1
            })
        
        let minusTap = inputs.minusButtonTap
            .map({ [selectedItems] index in
                return (selectedItems.value, index)
            })
            .compactMap { (products, index) -> (SelectedProduct, IndexPath)? in
                guard index.row < products.count else {
                    return nil
                }
                return (products[index.row], index)
            }
            .do(onNext: {
                guard $0.0.quantity > 1 else {
                    return
                }
                $0.0.quantity -= 1
            })
                
                
        let plusMinusTap = Observable.merge(plusTap, minusTap)
                .share()
                
                self.quantityDidUpdate = plusMinusTap.map {
                    ($0.1, $0.0.quantity.description)
                }
        
        let plusMinusTapVoid = plusMinusTap
            .map { _ in
                ()
            }
        
        self.badge = Observable.combineLatest(selectedOrDelete, plusMinusTapVoid.startWith(()))
            .compactMap({ products, _ in
                let count = products.map {
                    $0.quantity
                }
                .reduce(0) { partialResult, quantity in
                    return partialResult + quantity
                }
                
                if count == 0 {
                    return ""
                }
                return count.description
            })
    }
}
