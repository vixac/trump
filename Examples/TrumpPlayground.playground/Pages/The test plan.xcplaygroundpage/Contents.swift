/*:
 [Previous](@previous)
 # Creating test plans

 A test plan is a collection of files containing request response pairs to be loaded in the tool
 
 It represent the current test that you want to run. For example, you want to test a login test case:
 1. First the login fails because the password is wrong
 2. The login succeeds after correcting the password.
 
 */
 
import PlaygroundSupport
import Foundation

URLProtocol.registerClass(TrumpURL.self)
TrumpServeSetup.start(Bundle.main, testName: "loginFailureTestPlan.ttp.md")

//: ## The test plan structure
//: Now the following requests is going to be served by Trump. Notice how no changes are needed to the network code

let url = URL(string: "http://www.myservice.com/login")!

let clientService = ClientService(with: url)

clientService.login { status in
    
    let failedStatus = status
//: Observe the value of `failedStatus`, it should be 401
//: So we try again


    clientService.login { status in
        
        let successStatus = status
//: Observe the value of `successStatus`, it should be 200
        
        
/*:
## Count in the test plan

Trump expects the exact count of request that you load in the tool. If you try to call `login` again, it will fail.

         If you uncomment the following lines it will fail.
*/
        
        
//         clientService.login { status in
//         
//         
//         }
 
        
//: To remedy you can change the `count` of the success to `2` instead of 1

    }

}


PlaygroundPage.current.needsIndefiniteExecution = true

