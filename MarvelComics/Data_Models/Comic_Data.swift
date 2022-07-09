//
//  Comic_Data.swift
//  MarvelComics
//
//  Created by Daniel on 7/6/22.
//

import Foundation
import UIKit

struct ComicDataWrapper: Codable {
    let code: Int? // (int, optional): The HTTP status code of the returned result.,
    let status: String? // (string, optional): A string description of the call status.,
    let copyright: String? // (string, optional): The copyright notice for the returned result.,
    let attributionText: String? // (string, optional): The attribution notice for this result. Please display either this notice or the contents of the attributionHTML field on all screens which contain data from the Marvel Comics API.,
    let attributionHTML: String? // (string, optional): An HTML representation of the attribution notice for this result. Please display either this notice or the contents of the attributionText field on all screens which contain data from the Marvel Comics API.,
    let data: ComicDataContainer? // (ComicDataContainer, optional): The results returned by the call.,
    let etag: String? // (string, optional): A digest value of the content returned by the call.
}
struct ComicDataContainer: Codable {
    let offset: Int? // (int, optional): The requested offset (number of skipped results) of the call.,
    let limit: Int? // (int, optional): The requested result limit.,
    let total: Int? // (int, optional): The total number of resources available given the current filter set.,
    let count: Int? // (int, optional): The total number of results returned by this call.,
    let results: [Comic]? // (Array[Comic], optional): The list of comics returned by the call
}

struct Comic: Codable {
    let id: Int? // (int, optional): The unique ID of the comic resource.,
    let digitalId: Int? // (int, optional): The ID of the digital comic representation of this comic. Will be 0 if the comic is not available digitally.,
    let title: String? // (string, optional): The canonical title of the comic.,
    let issueNumber: Double? // (double, optional): The number of the issue in the series (will generally be 0 for collection formats).,
    let variantDescription: String? // (string, optional): If the issue is a variant (e.g. an alternate cover, second printing, or director’s cut), a text description of the variant.,
    let description: String? // (string, optional): The preferred description of the comic.,
    //TODO: - implement date formatter to properly parse
    let modified: String? // (Date, optional): The date the resource was most recently modified.,
    let isbn: String? // (string, optional): The ISBN for the comic (generally only populated for collection formats).,
    let upc: String? // (string, optional): The UPC barcode number for the comic (generally only populated for periodical formats).,
    let diamondCode: String? // (string, optional): The Diamond code for the comic.,
    let ean: String? // (string, optional): The EAN barcode for the comic.,
    let issn: String? // (string, optional): The ISSN barcode for the comic.,
    let format: String? // (string, optional): The publication format of the comic e.g. comic, hardcover, trade paperback.,
    let pageCount: Int? // (int, optional): The number of story pages in the comic.,
    let textObjects: [TextObject]? // (Array[TextObject], optional): A set of descriptive text blurbs for the comic.,
    let resourceURI: String? // (string, optional): The canonical URL identifier for this resource.,
    let urls: [Url]? // (Array[Url], optional): A set of public web site URLs for the resource.,
    let series: SeriesSummary? // (SeriesSummary, optional): A summary representation of the series to which this comic belongs.,
    let variants: [ComicSummary]? // (Array[ComicSummary], optional): A list of variant issues for this comic (includes the "original" issue if the current issue is a variant).,
    let collections: [ComicSummary]? // (Array[ComicSummary], optional): A list of collections which include this comic (will generally be empty if the comic's format is a collection).,
    let collectedIssues: [ComicSummary]? // (Array[ComicSummary], optional): A list of issues collected in this comic (will generally be empty for periodical formats such as "comic" or "magazine").,
    let dates: [ComicDate]? // (Array[ComicDate], optional): A list of key dates for this comic.,
    let prices: [ComicPrice]? // (Array[ComicPrice], optional): A list of prices for this comic.,
    let thumbnail: Image? // (Image, optional): The representative image for this comic.,
    let images: [Image]? // (Array[Image], optional): A list of promotional images associated with this comic.,
    let creators: CreatorList? // (CreatorList, optional): A resource list containing the creators associated with this comic.,
    let characters: CharacterList? // (CharacterList, optional): A resource list containing the characters which appear in this comic.,
    let stories: StoryList? // (StoryList, optional): A resource list containing the stories which appear in this comic.,
    let events: EventList? // (EventList, optional): A resource list containing the events in which this comic appears.
}

struct TextObject: Codable {
    let type: String? // (string, optional): The canonical type of the text object (e.g. solicit text, preview text, etc.).,
    let language: String? // (string, optional): The IETF language tag denoting the language the text object is written in.,
    let text: String? // (string, optional): The text.
}

struct Url: Codable {
    let type: String? // (string, optional): A text identifier for the URL.,
    let url: String? // (string, optional): A full URL (including scheme, domain, and path).
}

struct SeriesSummary: Codable  {
    let resourceURI: String? // (string, optional): The path to the individual series resource.,
    let name: String? // (string, optional): The canonical name of the series.
}

struct ComicSummary: Codable {
    let resourceURI: String? //(string, optional): The path to the individual comic resource.,
    let name: String? // (string, optional): The canonical name of the comic.
}

struct ComicDate: Codable {
    let type: String? // (string, optional): A description of the date (e.g. onsale date, FOC date).,
    let date: String? // (Date, optional): The date.
}

struct ComicPrice: Codable {
    let type: String? // (string, optional): A description of the price (e.g. print price, digital price).,
    let price: CGFloat? // (float, optional): The price (all prices in USD).
}

struct Image: Codable {
    let path: String? // (string, optional): The directory path of to the image.,
    let image_extension: String? // (string, optional): The file extension for the image.
    
    enum CodingKeys: String, CodingKey {
        case image_extension = "extension"
        case path
    }
}
struct CreatorList: Codable {
    let available: Int? // (int, optional): The number of total available creators in this list. Will always be greater than or equal to the "returned" value.,
    let returned: Int? // (int, optional): The number of creators returned in this collection (up to 20).,
    let collectionURI: String? // (string, optional): The path to the full list of creators in this collection.,
    let items: [CreatorSummary]? // (Array[CreatorSummary], optional): The list of returned creators in this collection.
}

struct CreatorSummary: Codable {
    let resourceURI: String? // (string, optional): The path to the individual creator resource.,
    let name: String? // (string, optional): The full name of the creator.,
    let role: String? // (string, optional): The role of the creator in the parent entity.
}

struct CharacterList: Codable {
    let available: Int? // (int, optional): The number of total available characters in this list. Will always be greater than or equal to the "returned" value.,
        let returned: Int? // (int, optional): The number of characters returned in this collection (up to 20).,
        let collectionURI: String? // (string, optional): The path to the full list of characters in this collection.,
        let items: [CharacterSummary]? // (Array[CharacterSummary], optional): The list of returned characters in this collection.
}

struct CharacterSummary: Codable {
    let resourceURI: String? // (string, optional): The path to the individual character resource.,
    let name: String? // (string, optional): The full name of the character.,
    let role: String? // (string, optional): The role of the creator in the parent entity.
}

struct StoryList: Codable {
    let available: Int? // (int, optional): The number of total available stories in this list. Will always be greater than or equal to the "returned" value.,
    let returned: Int? // (int, optional): The number of stories returned in this collection (up to 20).,
    let collectionURI: String? // (string, optional): The path to the full list of stories in this collection.,
    let items: [StorySummary]? // (Array[StorySummary], optional): The list of returned stories in this collection.
}

struct StorySummary: Codable {
    let resourceURI: String? // (string, optional): The path to the individual story resource.,
    let name: String? // (string, optional): The canonical name of the story.,
    let type: String? // (string, optional): The type of the story (interior or cover).
}

struct EventList: Codable {
    let available: Int? // (int, optional): The number of total available events in this list. Will always be greater than or equal to the "returned" value.,
    let returned: Int? // (int, optional): The number of events returned in this collection (up to 20).,
    let collectionURI: String? // (string, optional): The path to the full list of events in this collection.,
    let items: [EventSummary]? // (Array[EventSummary], optional): The list of returned events in this collection.
}

struct EventSummary: Codable {
    let resourceURI: String? // (string, optional): The path to the individual event resource.,
    let name: String? // (string, optional): The name of the event.
}
