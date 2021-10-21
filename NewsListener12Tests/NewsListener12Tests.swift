//
//  NewsListener12Tests.swift
//  NewsListener12Tests
//
//  Created by ivan chelovekov on 13.08.2021.
//

import XCTest
import Foundation
@testable import NewsListener12

extension FavoriteChannelsManager {

}


class NewsListener12Tests: XCTestCase {
    
    
    var favoriteCM : FavoriteChannelsManager!
    var newsM : NewsManager!
   

    override func setUpWithError() throws {
        favoriteCM = FavoriteChannelsManager()
        newsM = NewsManager()
        newsM.favoriteChannelsManager = favoriteCM
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        
        LocalFileManager.instance.deleteFile(name: "Articles.json")
        LocalFileManager.instance.deleteFile(name: "Channels.json")
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func initialLoadChannels (){
        let loadingExpectation = expectation(description: "LoadingExpectation")
         favoriteCM.initialLoad {
             loadingExpectation.fulfill()
         }
         wait(for: [loadingExpectation], timeout: 2.0)
    }
    
    func reloadChannels() {
        let loadingExpectation = expectation(description: "LoadingExpectation")
        favoriteCM.loadChannels(reload: true) {
            loadingExpectation.fulfill()
        }
        wait(for: [loadingExpectation], timeout: 2.0)
    }
    
    func loadArticles(){
        initialLoadChannels()
        let loadingExpectation = expectation(description: "LoadingExpectation")
        newsM.loadArticles {
            loadingExpectation.fulfill()
        }
        wait(for: [loadingExpectation], timeout: 2.0)
    }
    
    func reloadArticles() {
        let loadingExpectation = expectation(description: "LoadingExpectation")
        newsM.loadArticles(needsReload: true) {
            loadingExpectation.fulfill()
        }
        wait(for: [loadingExpectation], timeout: 2.0)
    }
    
    func loadMoreArticles() {
        let loadingExpectation = expectation(description: "LoadingExpectation")
        newsM.loadMoreArticlesPages {
            loadingExpectation.fulfill()
        }
        wait(for: [loadingExpectation], timeout: 2.0)
    }
    
    func waitForSaving() {
        let waitExpectation = expectation(description: "waitForSavingToFile")
        DispatchQueue.main.asyncAfter(deadline: .now() +  2) {
            waitExpectation.fulfill()
        }
        wait(for: [waitExpectation], timeout: 2.5)
    }

    func testInitialLoading() throws{
        initialLoadChannels()
        XCTAssertTrue(favoriteCM.channelsCount() == 128)
        XCTAssertTrue(favoriteCM.channelAtIndex(index: 3).name == "Al Jazeera English")
        XCTAssertFalse(favoriteCM.channelAtIndex(index: 7).favored)
    }
    
    func testFavoitesManagement() throws{
        initialLoadChannels()
        favoriteCM.addChannelToFavorites(atIndex: 3)
        favoriteCM.addChannelToFavorites(atIndex: 2)
        favoriteCM.addChannelToFavorites(atIndex: 4)
        favoriteCM.addChannelToFavorites(atIndex: 9)
        XCTAssertEqual(favoriteCM.favoriteAtIndex(0), "Aftenposten")
        XCTAssertEqual(favoriteCM.favoriteAtIndex(2), "ANSA.it")
        XCTAssertEqual(favoriteCM.favoritesCount(), 4)
        
        favoriteCM.removeFavorite(name: "Some channel name")
        XCTAssertEqual(favoriteCM.favoritesCount(), 4)
        
        favoriteCM.removeFavorite(name: "Aftenposten")
        XCTAssertNotEqual(favoriteCM.favoriteAtIndex(2), "ANSA.it")
        XCTAssertTrue(favoriteCM.channelAtIndex(index: 9).favored)
        favoriteCM.removeChannelFromFavorites(atIndex: 3)
        XCTAssertEqual(favoriteCM.favoriteAtIndex(0), "ANSA.it")
        XCTAssertEqual(favoriteCM.sourcesIdString(), "ansa,australian-financial-review")
    }
    
    func testSaveLoadChannels() throws {
        initialLoadChannels()
        favoriteCM.addChannelToFavorites(atIndex: 2)
        favoriteCM.addChannelToFavorites(atIndex: 3)
        XCTAssertEqual(favoriteCM.favoriteAtIndex(1), "Al Jazeera English")
        
        //Trigger recieving app notifictaion and wait while it save
        favoriteCM.appResignActive()
        waitForSaving()
        
        favoriteCM = FavoriteChannelsManager()
        initialLoadChannels()
        XCTAssertEqual(favoriteCM.favoritesCount(),2)
        XCTAssertEqual(favoriteCM.favoriteAtIndex(1), "Al Jazeera English")
        XCTAssertEqual(favoriteCM.sourcesIdString(), "aftenposten,al-jazeera-english")
    }
    
    func testRefreshLoadChannels() throws {
        initialLoadChannels()
        favoriteCM.addChannelToFavorites(atIndex: 2)
        favoriteCM.addChannelToFavorites(atIndex: 3)
        XCTAssertEqual(favoriteCM.favoriteAtIndex(1), "Al Jazeera English")
        
        reloadChannels()
        XCTAssertEqual(favoriteCM.favoritesCount(),2)
        XCTAssertEqual(favoriteCM.favoriteAtIndex(1), "Al Jazeera English")
        XCTAssertEqual(favoriteCM.sourcesIdString(), "aftenposten,al-jazeera-english")
    }
    
    func testLoadingArticles() throws {
        loadArticles()
        XCTAssertEqual(newsM.articlesCount(),20)
        XCTAssertEqual(newsM.article(at: 0)?.title, "Living in lava in Cape Verde")
        XCTAssertEqual(newsM.article(at: 9)?.source.name, "Aftenposten")
        XCTAssertFalse(newsM.isLoading())
        XCTAssertFalse(newsM.loadingLimitReached)
        XCTAssertEqual(newsM.currentSources(), "")
    }
    
    func testLoadingMoreArticlesPages() throws {
        loadArticles()
        loadMoreArticles()
        XCTAssertEqual(newsM.articlesCount(), 40)
        loadMoreArticles()
        loadMoreArticles()
        XCTAssertEqual(newsM.article(at: 70)?.publishedAt, "2021-10-12T16:56:39Z")
        loadMoreArticles()
        XCTAssertNil(newsM.article(at:82)?.urlToImage)
        loadMoreArticles()
        XCTAssertEqual(newsM.articlesCount(), 100)
        XCTAssert(newsM.loadingLimitReached)
    }
    
    func testSaveLoadArticlesToFile() throws {
        loadArticles()
        loadMoreArticles()
        
        newsM.appResignActive()
        waitForSaving()
        
        //then initialized news manager assyb load data from file
        newsM = NewsManager()
        waitForSaving()
        
        XCTAssertEqual(newsM.articlesCount(), 40)
        XCTAssertEqual(newsM.article(at: 9)?.source.name, "Aftenposten")
        XCTAssert(newsM.loadingLimitReached)
        
        loadArticles()
        XCTAssertEqual(newsM.articlesCount(), 40)
    }
    
    func testReloadPages(){
        loadArticles()
        loadMoreArticles()
        reloadArticles()
        XCTAssertEqual(newsM.articlesCount(), 20)
        
        newsM.appResignActive()
        waitForSaving()
        
        newsM = NewsManager()
        waitForSaving()
        
        XCTAssertEqual(newsM.articlesCount(), 20)
        loadMoreArticles()
        XCTAssertNotEqual(newsM.articlesCount(), 40)
        XCTAssert(newsM.loadingLimitReached)
        
        reloadArticles()
        loadMoreArticles()
        XCTAssertEqual(newsM.articlesCount(), 40)
        XCTAssertFalse(newsM.loadingLimitReached)
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}
