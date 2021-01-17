//
//  FanartClient.swift
//  FanartTVKIT
//
//  Created by Adolfo Vera Blasco on 20/10/17.
//  Copyright © 2017 Adolfo Vera Blasco. All rights reserved.
//

import Foundation

// MARK:- Completion Handlers

///
/// Art related a show, movie, music...
///
public typealias FanartCompletionHandler<T> = (_ result: T) -> (Void)

///
/// An image requested to Fanart.TV will be find here...
///
public typealias ImageRequestCompletionHandler = (_ image: Data?) -> (Void)

///
/// All API request will be *returned* here
///
private typealias HttpRequestCompletionHandler = (_ results: Data?, _ error: Error?) -> (Void)

//MARK: - Error codes
public enum FanArtError: Error {
    /// Bad Request - request couldn't be parsed
    case badRequest
    /// Oauth must be provided
    case unauthorized
    /// Forbidden - invalid API key or unapproved app
    case forbidden
    /// Not Found - method exists, but no record found
    case noRecordFound
    /// Method Not Found - method doesn't exist
    case noMethodFound
    /// Service Unavailable - server overloaded (try again in 30s)
    case serverOverloaded
    
    case parseError
    
    var message:String {
        switch self {
        case .badRequest:
            return "Bad Request"
        case .unauthorized:
            return "Unauthorized"
        case .forbidden:
            return "Forbidden"
        case .noRecordFound:
            return "No record found"
        case .noMethodFound:
            return "no Method Found"
        case .serverOverloaded:
            return "Server Overloaded"
        case .parseError:
            return "Parse Error"
        }
    }
    
    public static func == (lhs: FanArtError, rhs: FanArtError) -> Bool {
            return true
    }
}

///
/// Network client for Fanart.TV API 
///
public final class FanartClient
{

    /// Singleton instance
    public static let shared: FanartClient = FanartClient()
    
    /// Your Fanart.TV  project/personal api key
    public var apiKey: String?
    /// All the api request starts with this.
    private let baseURL: String = "https://webservice.fanart.tv/v3"

    /// The API client HTTP session
    private var httpSession: URLSession!
    /// API client HTTP configuration
    private var httpConfiguration: URLSessionConfiguration!

    /// The object dedicated to convert from JSON data
    /// obtained from Fanart.TV to out own data structures
    private var parser: FanartParser
    
    /**
        Initialize and set up the network connection
    */
    private init()
    {
        self.parser = FanartParser()

        self.httpConfiguration = URLSessionConfiguration.default
        self.httpConfiguration.httpMaximumConnectionsPerHost = 10

        let http_queue: OperationQueue = OperationQueue()
        http_queue.maxConcurrentOperationCount = 10

        self.httpSession = URLSession(configuration:self.httpConfiguration,
                                             delegate:nil,
                                        delegateQueue:http_queue)
    }
    
    //
    // MARK:- Movies
    //
    
    /**
         Request movie images from a [TMDB](https://www.themoviedb.org) identifier
     
         - Parameters:
             - tmdb: Identifier from The Movie Database
             - completionHandler: Closure in which put the results
     
         - SeeAlso: movie(identifier:completionHandler:)
    */
    public func movie(tmdb: Int, completionHandler: @escaping FanartCompletionHandler<FanartResult<FanArtMovie>>) -> Void
    {
        self.movie(identifier: tmdb as AnyObject, completionHandler: completionHandler)
    }
    
    /**
         Request movie images from an [IMDB](http://imdb.com) identifier
     
         - Parameters:
            - imdb: Identifier from Internet Movie Database
            - completionHandler: Closure in which put the results
     
         - SeeAlso: movie(identifier:completionHandler:)
    */
    public func movie(imdb: String, completionHandler: @escaping FanartCompletionHandler<FanartResult<FanArtMovie>>) -> Void
    {
        self.movie(identifier: imdb as AnyObject, completionHandler: completionHandler)
    }
    
    
    /**
        Request all resources for a movie whatever the
        identifier comes from.

        - Parameter movieID: A tmdb_id, imdb_id or future source valid identificator
        - Parameter completionHandler: Closure in which put the results
    */
    public func movie(identifier movieID: AnyObject, completionHandler: @escaping FanartCompletionHandler<FanartResult<FanArtMovie>>) -> Void
    {
        guard movieID is Int || movieID is String else
        {
            return
        }
        guard let apiKey = self.apiKey else {
            completionHandler(.error(reason: "Empty api_key"))
            return
        }
        let web_resource: String = "\(self.baseURL)/movies/\(movieID)?api_key=\(apiKey)"
        let url: URL = URL(string: web_resource)!

        self.processHttpRequest(from: url, httpHandler: { (results: Data?, error: Error?) -> (Void) in
            // Parsing JSON to Movie
            guard let results = results else
            {
                if let error = error as? FanArtError {
                    completionHandler(.error(reason: error.message))
                    return
                }
                completionHandler(FanartResult.error(reason: "No data found"))
                return
            }

            // Parse JSON to Movie
            let fanArtMovie = try? JSONDecoder().decode(FanArtMovie.self, from: results)
            if let fanArtMovie = fanArtMovie {
                completionHandler(FanartResult.success(result: fanArtMovie))
            } else {
                completionHandler(.error(reason: FanArtError.parseError.message))
            }
            
            }
        )
    }
    
    /**
        Last movies affected by changes from a date

        - Parameter date: Movies updated from this date to Now
        - Parameter completionHandler: Data response
    */
    public func latestMovies(since date: TimeInterval, completionHandler: @escaping FanartCompletionHandler<FanartResult<FanArtLatestMovies>>) -> Void
    {
        guard let apiKey = self.apiKey else {
            completionHandler(.error(reason: "Empty api_key"))
            return
        }
        let timestamp: Int = Int(date)
        let web_resource: String = "\(self.baseURL)/movies/latest?api_key=\(apiKey)&date=\(timestamp)"
        let url: URL = URL(string: web_resource)!

        self.processHttpRequest(from: url, httpHandler: { (results: Data?, error: Error?) -> (Void) in
            // Parse JSON to Movie
            guard let results = results,
                  let latestMovies = try? JSONDecoder().decode(FanArtLatestMovies.self, from: results)  else
            {
                if let error = error as? FanArtError {
                    completionHandler(.error(reason: error.message))
                    return
                }
                completionHandler(FanartResult.error(reason: "No data"))
                return
            }
            
            completionHandler(FanartResult.success(result: latestMovies))
            }
        )
    }
    
    //
    // MARK:- Shows
    //
    
    /**
        All images availables for a TV Show
    
        - Parameter showID: The TVDB identifier for the show
        - Parameter completionHandler: Here we return the results
    */
    public func show(identifier showID: Int, completionHandler: @escaping FanartCompletionHandler<FanartResult<FanArtTVShow>>) -> Void
    {
        guard let apiKey = self.apiKey else {
            completionHandler(.error(reason: "Empty api_key"))
            return
        }
        let web_resource: String = "\(self.baseURL)/tv/\(showID)?api_key=\(apiKey)"
        let url: URL = URL(string: web_resource)!
        
        self.processHttpRequest(from: url, httpHandler: { (results: Data?, error: Error?) -> (Void) in
            // Parse JSON to TV Show
            guard let results = results,
                  let fanArtTVShow = try? JSONDecoder().decode(FanArtTVShow.self, from: results) else
            {
                if let error = error as? FanArtError {
                    completionHandler(.error(reason: error.message))
                    return
                }
                completionHandler(FanartResult.error(reason: "No data"))
                return
            }
            
            completionHandler(FanartResult.success(result: fanArtTVShow))
            }
        )
    }
    
    /**
        Last shows affected by changes since the date
     
        - Parameter date: Movies updated from this date to Now
        - Parameter completionHandler:
     */
    public func latestShows(since date: TimeInterval, completionHandler: @escaping FanartCompletionHandler<FanartResult<FanArtLatestTVShows>>) -> Void
    {
        guard let apiKey = self.apiKey else {
            completionHandler(.error(reason: "Empty api_key"))
            return
        }
        let timestamp: Int = Int(date)
        let web_resource: String = "\(self.baseURL)/tv/latest?api_key=\(apiKey)&date=\(timestamp)"
        let url: URL = URL(string: web_resource)!
        
        self.processHttpRequest(from: url, httpHandler: { (results: Data?, error: Error?) -> (Void) in
            // Parse JSON to Show
            if let results = results,
               let fanArtTVShow = try? JSONDecoder().decode(FanArtLatestTVShows.self, from: results)
            {
                if let error = error as? FanArtError {
                    completionHandler(.error(reason: error.message))
                    return
                }
               
                completionHandler(FanartResult.success(result: fanArtTVShow))
            }
            else
            {
                completionHandler(FanartResult.error(reason: "No data available"))
            }
        })
    }
    
    //
    // MARK:- Music
    //
    
    /**
        All images availables for this music artist
    
        - Parameter artisID: The Musicbrainz identifier for the artist
        - Parameter completionHandler: Here we return the results
    */
    public func musicArtist(identifier artisID: String, completionHandler: @escaping FanartCompletionHandler<FanartResult<MusicArtistArt>>) -> Void
    {
        guard let apiKey = self.apiKey else {
            completionHandler(.error(reason: "Empty api_key"))
            return
        }
        let web_resource: String = "\(self.baseURL)/music/\(artisID)?api_key=\(apiKey)"
        let url: URL = URL(string: web_resource)!
        
        self.processHttpRequest(from: url, httpHandler: { (results: Data?, error: Error?) -> (Void) in
            // Parse JSON to Music Artist
            guard let results = results,
                  let datos = try? JSONSerialization.jsonObject(with: results, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] else
            {
                if let error = error as? FanArtError {
                    completionHandler(.error(reason: error.message))
                    return
                }
                completionHandler(FanartResult.error(reason: "No data available"))
                return
            }

            let musicArtistArt: MusicArtistArt = self.parser.parseArtist(from: datos)
            completionHandler(FanartResult.success(result: musicArtistArt))
        })
    }

    /**
        All images availables for this music label
    
        - Parameter labelID: The Musicbrainz identifier for the label
        - Parameter completionHandler: Here we return the results
    */
    public func musicLabel(identifier labelID: String, completionHandler: @escaping FanartCompletionHandler<FanartResult<MusicLabelArt>>) -> Void
    {
        guard let apiKey = self.apiKey else {
            completionHandler(.error(reason: "Empty api_key"))
            return
        }
        let web_resource: String = "\(self.baseURL)/music/labels/\(labelID)?api_key=\(apiKey)"
        let url: URL = URL(string: web_resource)!
        
        self.processHttpRequest(from: url, httpHandler: { (results: Data?, error: Error?) -> (Void) in
            // Parse JSON to Music Label
            guard let results = results,
                  let datos = try? JSONSerialization.jsonObject(with: results, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] else
            {
                if let error = error as? FanArtError {
                    completionHandler(.error(reason: error.message))
                    return
                }
                completionHandler(FanartResult.error(reason: "No data available"))
                return
            }

            let musicLabelArt: MusicLabelArt = self.parser.parseLabel(from: datos)
            completionHandler(FanartResult.success(result: musicLabelArt))
        })
    }

    /**
        All images availables for this music album
    
        - Parameter albumID: The Musicbrainz identifier for the album
        - Parameter completionHandler: Here we return the results
    */
    public func musicAlbum(identifier albumID: String, completionHandler: @escaping FanartCompletionHandler<FanartResult<MusicAlbumArt>>) -> Void
    {
        guard let apiKey = self.apiKey else {
            completionHandler(.error(reason: "Empty api_key"))
            return
        }
        let web_resource: String = "\(self.baseURL)/music/albums/\(albumID)?api_key=\(apiKey)"
        let url: URL = URL(string: web_resource)!
        
        self.processHttpRequest(from: url, httpHandler: { (results: Data?, error: Error?) -> (Void) in
            // Parse JSON to Music Album
            guard let results = results,
                  let datos = try? JSONSerialization.jsonObject(with: results, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] else
            {
                if let error = error as? FanArtError {
                    completionHandler(.error(reason: error.message))
                    return
                }
                completionHandler(FanartResult.error(reason: "No data available"))
                return
            }

            let musicAlbumArt: MusicAlbumArt = self.parser.parseAlbum(from: datos)
            completionHandler(FanartResult.success(result: musicAlbumArt))
        })
    }

    /**
        Last music artist affected by changes since the date
     
        - Parameter date: Music Artist updated from this date to Now
        - Parameter completionHandler: The updates will be passed here
     */
    public func latestArtists(since date: TimeInterval, completionHandler: @escaping FanartCompletionHandler<FanartResult<FanArtLatestMusic>>) -> Void
    {
        guard let apiKey = self.apiKey else {
            completionHandler(.error(reason: "Empty api_key"))
            return
        }
        let timestamp: Int = Int(date)
        let web_resource: String = "\(self.baseURL)/music/latest?api_key=\(apiKey)&date=\(timestamp)"
        let url: URL = URL(string: web_resource)!
        
        self.processHttpRequest(from: url, httpHandler: { (results: Data?, error: Error?) -> (Void) in
            // Parse JSON to Artists
            guard let results = results,
                  let music = try? JSONDecoder().decode(FanArtLatestMusic.self, from: results) else
            {
                if let error = error as? FanArtError {
                    completionHandler(.error(reason: error.message))
                    return
                }
                completionHandler(FanartResult.error(reason: "No data available"))
                return
            }
            
            completionHandler(FanartResult.success(result: music))
        })
    }

    //
    // MARK:- Image download
    //

    /**
        Request an image resource to Fanart.TV

        - Parameter url: The image URL
        - Parameter completionHandler: The operation result will be passed here.
    */
    public func downloadImage(from url: URL, completionHandler: @escaping ImageRequestCompletionHandler) -> Void
    {
        let request: URLRequest = URLRequest(url: url)

        let data_task: URLSessionDataTask = self.httpSession.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if let data = data,
               let http_response = response as? HTTPURLResponse,
               http_response.statusCode == 200
            {
                completionHandler(data)
            }
            else 
            {
                completionHandler(nil)
            }
        })

        data_task.resume()
    }

    //
    // MARK:- HTTP Request
    //
    
    /**
        Request to Fanart.TV server

        - parameter url: Request URL
        - parameter completionHandler: The HTTP response will be found here.
    */
    private func processHttpRequest(from url: URL, httpHandler: @escaping HttpRequestCompletionHandler) -> Void
    {
        let request: URLRequest = URLRequest(url: url)

        let data_task: URLSessionDataTask = self.httpSession.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error != nil
            {
                httpHandler(nil, error)
            }
            else
            {
                if let data = data, let http_response = response as? HTTPURLResponse
                {
                    switch http_response.statusCode
                    {
                        case 200:
                            httpHandler(data,nil)
                        case 400:
                            httpHandler(nil, nil)
                        case 401:
                            httpHandler(nil, FanArtError.unauthorized)
                        default:
                            httpHandler(nil, nil)
                    }
                }
            }
        })

        data_task.resume()
    }
}
