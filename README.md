# NetRoute
## iOS networking framework.

goforit.pro/netroute

## NetRoute Features

- [x] Simple to use
- [x] Keeps your code clean and consistent
- [x] Built-in JSON support
- [x] Support for unit testing

---

## NetRoute requires:

- Swift 3.0+
- Xcode 8.0+

## Supported platforms

- iOS 8.2+
- OS X 10.9+
- tvOS 9.0+
- watchOS 2.0+

## Installation

- Get the latest release here `(link unavaliable)`. 
- Drag it to your target's files in Xcode. 
- Select your target settings and navigate to 'General'
- Add `NetRoute` to Embeded Binaries list. 

---

## Usage of NetRoute

### Making a request

Meking a request with NetRoute is very easy.

```swift
import NetRoute

// First step is to create the URL of the request.
let requestUrl = URL(string: "https://httpbin.org/get")!

// Here is where you run your request.
NetRequest(url: requestUrl, type: .GET).run()
```
> When setting up the request URL be consider using `https` instead of `http`. Using insecure connections is unrecommended by Apple and causes different problems with Application Transport Security

### Handle the response

Use `completionHandler` to handle the response when the request is done.

```swift
import NetRoute

// First step is to create the URL of the request.
let requestUrl = URL(string: "https://httpbin.org/get")

// Here is where you run your request.
NetRequest(url: requestUrl!, type: .GET).run() { (response) in
    print(response)
}
```
> Requests are done in asyncronios way, and to interrupt with UI elements be sure to use DispatchQueue.main

#### Response parsing

You can use diffirent properties of `NetResponse` to get what you want.

**Response properties**

- `response.string`
- `response.dictionary`
