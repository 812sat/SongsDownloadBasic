//
//  Track.swift
//  SongPV2
//
//  Created by W1! on 20/06/2023.
//

import UIKit

struct Track: Codable {
    let artist: String
    let title: String
    let album: String
    let url: String
}

struct TracksResponse: Codable {
    let tracks: [Track]
}
