//: # Trump - A response mocking tool

import PlaygroundSupport
import Foundation

//: First attach Trump to the network stack using the `URLProtocol.registerClass` method
 
URLProtocol.registerClass(TrumpURL.self)

//: Then load the test plan into Trump

TrumpServeSetup.start(Bundle.main, testName: "testplan.ttp.md")


//: Now the following requests is going to be served by Trump. Notice how no changes are needed to the network code

let url = URL(string: "http://www.google.com/someurl")!
let l = URLSession.shared.dataTask(with: url) { data, response, error in
    
    
    if let d = data {
        let dataString = String(data: d, encoding: .utf8)
//: Observe the value of `dataString`, it should the same as in `response.trp.md` (in this page's `Resources` folder)
    }
    
    PlaygroundPage.current.finishExecution()
}

l.resume()

PlaygroundPage.current.needsIndefiniteExecution = true
//: [Next](@next)
