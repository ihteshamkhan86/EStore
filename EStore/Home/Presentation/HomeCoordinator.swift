import Foundation
import RxSwift
import UIKit

class HomeCoordinator {
    private let disposeBag = DisposeBag()
    
    // Temp
    private let navController: UINavigationController = UINavigationController()
    func start() -> UINavigationController {
        let vc = HomeVC()
        
        addChildControllers(to: vc)
        
        navController.addChild(vc)
        return navController
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
            .asDriver(onErrorRecover: { error in
            .empty()
            })
            .drive(onNext: { [weak self ]product in
                self?.showAlertFor(product: product)
            })
            .disposed(by: disposeBag)
        
        viewModel.shareTap
            .asDriver { error in
            .empty()
            }
            .drive(onNext: { [weak self] product in
                self?.showShareSheet(for: product)
            })
            .disposed(by: disposeBag)
    }
    
    private func showAlertFor(product: Product) {
        let vc = ProductDetailsVC(product: product)
            
        navController.pushViewController(vc, animated: true)
    }
    
    private func showShareSheet(for product: Product) {
        let title = product.title
        let details = product.description
        let price = "$ " + product.price.description
        
        let array = [title, details, price]
        let activity = UIActivityViewController(activityItems: array, applicationActivities: nil)
        
        navController.present(activity, animated: true, completion: nil)
    }
}
