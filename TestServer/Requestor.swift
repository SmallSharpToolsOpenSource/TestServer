//
//  Requestor.swift
//  TestServer
//
//  Created by Brennan Stehling on 9/4/16.
//  Copyright © 2016 SmallSharpTools LLC. All rights reserved.
//

import Foundation

public typealias JSONDictionary = [String : AnyObject]
public typealias JSONArray = [JSONDictionary]
public typealias ParamsDictionary = [String : AnyObject]

public enum HTTPMethod: String {
    case HEAD = "HEAD"
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

let RequestorErrorDomain = "Requestor"

public enum RequestorErrorCode: Int {
    case RemoteError = 501
    case MissingCredentials = 502
    case NoAccessToken = 503
    case NoResponse = 504
    case ResourceNotFound = 505
    case InvalidResponse = 506
    case AccessForbidden = 507
    case UndefinedError = 599
}

public class Requestor : NSObject {

    public var isDebugging: Bool = false

    public func request(method: HTTPMethod, baseURL: String, path: String, params: ParamsDictionary?, completionHandler: ((response: AnyObject?, error: NSError?) -> ())?) -> NSURLSessionTask? {
        if let url = urlWithString(baseURL + path, parameters: method == .GET ? params : nil) {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = method.rawValue
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            do {
                // Place parameters in body for POST and PUT methods
                if let params = params  where method == .POST || method == .PUT {
                    let body = try NSJSONSerialization.dataWithJSONObject(params, options: [])
                    request.HTTPBody = body
                }

                return processRequest(request, completionHandler: completionHandler)
            } catch {
                let error = requestorError(.InvalidResponse, reason: "Invalid Response")
                completionHandler?(response: nil, error: error)
                return nil
            }
        }

        return nil
    }

    // MARK: - Internal Functions -

    internal func processRequest(request: NSURLRequest, completionHandler: ((response: AnyObject?, error: NSError?) -> ())?) -> NSURLSessionTask? {
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfiguration)
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard let httpResponse = response as? NSHTTPURLResponse,
                let data = data else {
                    if let error = error {
                        completionHandler?(response: response, error: error)
                    }
                    else {
                        let error = self.requestorError(.UndefinedError, reason: "Undefined Error")
                        completionHandler?(response: nil, error: error)
                    }
                    return
            }

            if self.isDebugging {
                debugPrint("Status Code: \(httpResponse.statusCode)")
                if let MIMEType = httpResponse.MIMEType {
                    debugPrint("Status Code: \(MIMEType)")
                }
                if let string = String(data: data, encoding: NSUTF8StringEncoding) {
                    debugPrint("Response: \(string)")
                }
            }

            if httpResponse.statusCode != 200 {
                if httpResponse.statusCode == 404 {
                    let error = self.requestorError(.ResourceNotFound, reason: "Resource Not Found")
                    completionHandler?(response: response, error: error)
                    return
                }
                else if httpResponse.statusCode == 500 {
                    let error = self.requestorError(.RemoteError, reason: "Remote Error")
                    completionHandler?(response: response, error: error)
                    return
                }
            }

            if data.length == 0 {
                completionHandler?(response: [:], error: error)
            } else if httpResponse.MIMEType == "text/html" {
                let html = String(data: data, encoding: NSUTF8StringEncoding)
                completionHandler?(response: html, error: error)
            } else {
                do {
                    let response = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                    if httpResponse.statusCode == 403 {
                        let error = self.requestorError(.AccessForbidden, reason: "Access Forbidden")
                        completionHandler?(response: response, error: error)
                    }
                    else {
                        completionHandler?(response: response, error: error)
                    }
                } catch {
                    let error = self.requestorError(.InvalidResponse, reason: "Invalid Response")
                    completionHandler?(response: nil, error: error)
                }
            }
            
        }
        task.resume()
        return task
    }

    internal func requestorError(code: RequestorErrorCode, reason: String, userInfo: [String : AnyObject]? = [:]) -> NSError {
        var dictionary: [String : AnyObject]? = userInfo
        dictionary?[NSLocalizedDescriptionKey] = reason

        let error = NSError(domain: RequestorErrorDomain, code: code.rawValue, userInfo: dictionary)
        return error
    }

    internal func urlWithString(string: String?, parameters: JSONDictionary?) -> NSURL? {
        guard let string = string else {
            return nil
        }

        let URL = NSURL(string: string)
        if let parameters = parameters {
            return appendQueryParameters(parameters, URL: URL)
        }

        return URL
    }

    internal func appendQueryParameters(parameters: JSONDictionary, URL: NSURL?) -> NSURL? {
        guard let URL = URL,
            let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: false) else {
                return nil
        }

        var queryItems: [NSURLQueryItem] = []

        for key in parameters.keys {
            let value = parameters[key]
            if let stringValue = value as? String {
                let queryItem : NSURLQueryItem = NSURLQueryItem(name: key, value: stringValue)
                queryItems.append(queryItem)
            }
            else if let value = value {
                let stringValue = "\(value)"
                let queryItem : NSURLQueryItem = NSURLQueryItem(name: key, value: stringValue)
                queryItems.append(queryItem)
            }
        }

        components.queryItems = queryItems
        
        return components.URL
    }
    
}
