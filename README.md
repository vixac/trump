![Trump](TrumpLogo.png)

#Trump

A testing tool delivering fake news to your app. Sad

## How it works

Trump serves pre determined responses to your app, using test plans defined in JSON.

It is useful for UI Testing, or even to demo an app. 

## Installing

Using cocoapods:
```
pod 'Trump'
```

It's also compatible with Carthage.

Also you can check the sources and add it to your project

## Getting started

### Preparing the tests

Define a *response* for a given *request* in a **response file**:
> A response file contains a pair of request/response to be returned by the framework

```json
{
	"pairs": [{
		"request": {
			"method": "POST",
			"endpoint": "https://myovo-uat.ovoenergy.com/api/auth/login"
		},
		"response": {
			"statusCode": 401,
			"data": {
				"code": "Unknown",
				"message": "Wrong email or password"
			}
		}
	}]
}

```

Then create a **test plan**:
> A test plan is a simple collection of files containing requests/responses. It maps a tests that you want to run, for example 'login failure'

```json
{
	"files" : ["loginFail.json"]
}
```

### Running the tests

On iOS, trump works by registering a protocol to the network stack: 

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
 
 	[...]
	let mockResponsesBundle = Bundle(for:AppDelegate.self).path(forResource: "MockResponses", ofType: "bundle")!
	URLProtocol.registerClass(TrumpURL.self)
	TrumpServeSetup.start( Bundle(path: mockResponsesBundle)!, testName: "TestName")
	[...]
            
}
```


### Tips

At OVO we package the tests in a bundle that we include only on the "Debug" or "UITesting" version of the build with this script in the build phases:

```bash
if [[ ${CONFIGURATION} == "Debug" ]]; then
	echo "Adding the test cases"
	cp -R "${SRCROOT}/MYPROJECTTESTS/MockResponses.bundle" "${TARGET_BUILD_DIR}/${PRODUCT_NAME}.app/MockResponses.bundle"
fi
```

Also we pass the test case we want to run as an argument in the UI Tests like this:

```swift
func testLoginFail() {
	let app = UITestHelper.launchAppWithTestCase("LoginFailTestPlan.json")
	[...] 	
}
```

It's up to you to process this arguement, but we do it this way: 

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
      
	#if DEBUG
	if let testCaseName = ProcessInfo().environment["UITestCaseName"] {
		print("Starting Trum with testCase name is \(testCaseName).")
		let mockResponsesBundle = Bundle(for:AppDelegate.self).path(forResource: "MockResponses", ofType: "bundle")!
		URLProtocol.registerClass(TrumpURL.self)
		TrumpServeSetup.start( Bundle(path: mockResponsesBundle)!, testName: testCaseName)
	}
	#ENDIF
}
```

Check the example in the `Example` folder for more details.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Victor Zaccarelli** - *Initial work* - email@email.com

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

