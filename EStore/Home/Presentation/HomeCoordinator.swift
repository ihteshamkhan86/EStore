import Foundation
import RxSwift

class HomeCoordinator {
    private let disposeBag = DisposeBag()
    func start() -> HomeVC {
        let vc = HomeVC()
        
        addChildControllers(to: vc)
        return vc
    }
    
    private func addChildControllers(to viewController: HomeVC)  {
        let productsListCoordinator = ProductsListCoordinator()
        let productsListVC = productsListCoordinator.start()
        
        let shoppingCartCoordinator = ShoppingCartCoordinator()
        let shoppingCartVC = shoppingCartCoordinator.start()
        
        let addToCart = PublishSubject<Product>()
        
        productsListVC.viewModelFactory = { [unowned self] inputs in
            let service = GetProductsServiceImpl()
            let vm = ProductsListVM(inputs: inputs, getProductsService: service)
            bind(viewModel: vm)
            vm.addToCart
                .bind(to: addToCart)
                .disposed(by: disposeBag)
            return vm
        }
        
        shoppingCartVC.viewModelFactory = { [addToCart] inputs in
            let vm = ShoppingCartVM(inputs: inputs, addToCart: addToCart.asObservable())
            return vm
        }
        let _ = shoppingCartVC.view
        
        viewController.setViewControllers([productsListVC, shoppingCartVC], animated: true)
    }
    
    private func bind(viewModel: ProductsListVM) {
        viewModel
            .selectedProduct
            .debug("selected product")
            .subscribe()
            .disposed(by: disposeBag)
    }
}
