//
//  NewsTableViewCell.swift
//  TheNewsApp
//
//  Created by Edu Caubilla on 19/07/2023.
//

import UIKit

class NewsTableViewCellViewModel{
    let title: String
    let subtitle: String
    let date: Date
    let imageURL: URL?
    var imageData: Data? = nil

    init(title: String,
        subtitle: String,
        imageURL: URL?,
        date: Date){
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.date = date
    }
}

class NewsTableViewCell: UITableViewCell {

    static let identifier = "NewsTableViewCell"
    
    private let newsTitleLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize:18, weight:.regular)
        return label
    }()
    
    private let dateLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize:12, weight:.light)
        return label
    }()
    
    private let subtitleLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize:15, weight:.light)
        return label
    }()
    
    private let newsImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(newsTitleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(newsImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        newsTitleLabel.frame = CGRect(x: 10,
                                      y: 5,
                                      width: contentView.frame.size.width - 150,
                                      height: 65)
        newsTitleLabel.numberOfLines = 0
        
        dateLabel.frame = CGRect(x: 10,
                                 y: 74,
                                 width: newsTitleLabel.frame.size.width,
                                 height: 14)
        dateLabel.numberOfLines = 0
        
        subtitleLabel.frame = CGRect(x: 10,
                                     y: 90,
                                     width: newsTitleLabel.frame.size.width,
                                     height: 65)
        subtitleLabel.numberOfLines = 0
        
        newsImageView.frame = CGRect(x: contentView.frame.size.width - 135,
                                     y: 10,
                                     width: 125,
                                     height: contentView.frame.size.height - 20)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        newsTitleLabel.text = nil
        dateLabel.text = nil
        subtitleLabel.text = nil
        newsImageView.image = nil
    }
    
    func configure(with viewModel: NewsTableViewCellViewModel){
        newsTitleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a E, d MM Y"
        dateLabel.text = formatter.string(from: viewModel.date) 
        
        //Image
        if let data = viewModel.imageData{
            newsImageView.image = UIImage(data:data)
        }
        else if let url = viewModel.imageURL {
            //fetch image
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                viewModel.imageData = data
                DispatchQueue.main.async {
                    self?.newsImageView.image = UIImage(data: data)
                }
            }.resume()
        }
    }
}
