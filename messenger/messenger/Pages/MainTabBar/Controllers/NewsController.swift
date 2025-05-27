//
//  NewsController.swift
//  messenger
//
//  Created by Тофик Мамедов on 21.01.2025.
//

import Foundation
import UIKit


class NewsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var NewsTable: UITableView!

    var news: [NewsItem] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        news.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 490
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomNewsCell", for: indexPath) as! NewsCell
        let item = news[indexPath.row]
        cell.setupCell(newsitem: item)
        return cell
    }
    
    
    override func viewDidLoad() {
        self.NewsTable.delegate = self
        self.NewsTable.dataSource = self
        
        self.NewsTable.separatorStyle = .singleLine
    
        self.navigationItem.setHidesBackButton(true, animated: true)
        let nib = UINib(nibName: "CustomNewsCell", bundle: nil)
        self.NewsTable.register(nib, forCellReuseIdentifier: "CustomNewsCell")
        
        
        APIService.shared.getNewsPaper { news in
            guard let news = news else {
                AlertManager.pushPrimitiveAlert(to: self, title: "Ошибка", desc: "Не удалось загрузить новости...")
                return
            }
            
            self.news = news
            
            DispatchQueue.main.async {
                self.NewsTable.reloadData()
            }
        }
    }
}
