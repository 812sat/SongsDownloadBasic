//
//  ViewController.swift
//  SongPV2
//
//  Created by W1! on 20/06/2023.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.frame = .zero
        return progressView
    }()
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(named: "black")
        label.font = UIFont(name: "Inter-SemiBold", size: 35)
        label.textColor = UIColor.white
        label.text = "Downloadr"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TrackTableViewCell.self, forCellReuseIdentifier: TrackTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    private var tracks: [Track] = []
    private var downloadTasks: [DownloadTask] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(progressView)
        progressView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width - 20, height: 40)
        progressView.center = view.center
        
        view.addSubview(tableView)
        view.addSubview(titleLabel)
        
        downloadTracks()
        setUpConstraints()
    }
    
    private func setUpConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func downloadTracks() {
        guard let url = URL(string: "https://vibze.github.io/downloadr-task/tracks.json") else {
            print("Invalid JSON API URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(TracksResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self?.tracks = response.tracks
                    self?.tableView.reloadData()
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        task.resume()
    }
    
    private func downloadTrack(at index: Int) {
        let track = tracks[index]
        
        let progressHandler: (Float) -> Void = { [weak self] progress in
            DispatchQueue.main.async {
                if let cell = self?.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TrackTableViewCell {
                    cell.updateProgress(progress)
                }
            }
        }
        
        let completionHandler: () -> Void = { [weak self] in
            DispatchQueue.main.async {
                if let cell = self?.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TrackTableViewCell {
                    cell.downloadCompleted()
                }
            }
        }
        
        let downloadTask = DownloadTask(progressHandler: progressHandler, completion: completionHandler)
        downloadTask.downloadAndPlayAudio(urlString: track.url)
        downloadTasks.append(downloadTask)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrackTableViewCell.reuseIdentifier, for: indexPath) as! TrackTableViewCell
        
        let track = tracks[indexPath.row]
        cell.configure(with: track)
        
        cell.downloadAction = { [weak self] in
            self?.downloadTrack(at: indexPath.row)
        }
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
