import Foundation

public class ClientService {
    
    public let url: URL
    
    public init(with url: URL) {
        self.url = url
    }
    
    public func login(_ completion: @escaping (Int)-> Void ) {
        
        let loginFailure = URLSession.shared.dataTask(with: url) { data, response, error in
            
            let r = response as? HTTPURLResponse
            let status = r?.statusCode
            completion(status!)
        }
        
        loginFailure.resume()
        
    }
    
}
