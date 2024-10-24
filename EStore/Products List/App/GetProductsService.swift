import RxSwift

protocol GetProductsService {
    func getProducts() -> Observable<ProductsResponse>
}

class GetProductsServiceImpl: GetProductsService {
    enum CustomError: Error {
        case message(String)
    }
    func getProducts() -> Observable<ProductsResponse> {
        guard let filePath = Bundle.main.url(forResource: "Products", withExtension: "txt") else {
            return .error(CustomError.message("Path not found"))
        }
        
        do {
            let data = try Data(contentsOf: filePath)
            let response = try JSONDecoder().decode(ProductsResponse.self, from: data)
            return .just(response)
        }catch let error {
            return .error(error)
        }
    }
}
