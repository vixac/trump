
import Foundation


public class TrumpServeSetup {    
   public static func start(_ bundle: Bundle, testName: String) {
    
        let pairs = try! TrumpLoader.loadTestPlan(testName, bundle: bundle)
        let stack = TrumpResponseStack(with: pairs)
        let serve = TrumpServe(stack, failureCallback: {
            TrumpError.log("Warning: Trump can't find a response for the request")
        })
        TrumpURL.trumpDelegate = serve
        URLProtocol.registerClass(TrumpURL.self)
        print("Trump Serve started.")
    }
}
