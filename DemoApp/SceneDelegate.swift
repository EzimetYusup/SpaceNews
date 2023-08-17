//
//  SceneDelegate.swift
//  DemoApp
//
//  Created by Ezimet Ozkhan on 1/31/23.
//

import SDWebImage
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // SpaceNews' thumbnail images are too big, has to set memory limit for Mem cache
        // otherwise app's memory will easily get 1GB with few scrolls
        injectMockResponsesForUITestIfNecessary()
        SDImageCache.shared.config.maxMemoryCost = 1024 * 1024 * 5
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        // Override point for customization after application launch.
        let newsList = NewsListViewController()
        let navigationController = UINavigationController(rootViewController: newsList)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func injectMockResponsesForUITestIfNecessary() {
        guard isUITest else { return }
        let mockCount = 1
        let mockArticles = Article(id: 1, title: "NASA Awards Environmental Compliance, Operations Contract",
                                   url: "http://www.nasa.gov/press-release/nasa-awards-environmental-compliance-operations-contract",
                                   imageUrl: "https://www.nasa.gov/sites/default/files/thumbnails/image/nasa_meatball_1.jpeg?itok=hHt8a7fl",
                                   newsSite: "",
                                   summary: "NASA has selected Navarro Research and Engineering, Inc., of Oak Ridge, Tennessee, for the Environmental Compliance and Operations 3 (ECO3) contract, which provides environmental restoration program services and other support at the agency’s White Sands Test Facility in Las Cruces, New Mexico.", publishedAt: "")
        let jsonEncoder = JSONEncoder()
        let jsonResultData = try? jsonEncoder.encode([mockArticles])
        MockURLProtocol.setMockResponse(for: "https://api.spaceflightnewsapi.net/v3/articles/count", statusCode: 200, result: .success(mockCount.description.data(using: .utf8)))
        MockURLProtocol.setMockResponse(for: "https://api.spaceflightnewsapi.net/v3/articles?_start=0", statusCode: 200, result: .success(jsonResultData))
        URLProtocol.registerClass(MockURLProtocol.self)
    }
}
