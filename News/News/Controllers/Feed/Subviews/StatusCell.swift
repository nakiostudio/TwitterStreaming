//
//  Created by Carlos Vidal Pallin on 16/10/2016.
//  Copyright © 2016 nakioStudio. All rights reserved.
//

import UIKit
import Service

class StatusCell: UICollectionViewCell {
    
    private static let padding: CGFloat = 10.0
    private static let nameLabelHeight: CGFloat = 24.0
    private static let imageWidth: CGFloat = 48.0
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var textLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }
    
    // MARK: - Public methods
    
    func configure(withStatus status: Status) {
        self.nameLabel.text = status.user?.screenName
        self.dateLabel.text = String((status.timestamp ?? 0))
        self.textLabel.attributedText = StatusCell.attributedTextString(withStatus: status, highlightWords: true)
    }
    
    static func height(withStatus status: Status, width: CGFloat) -> CGFloat {
        let realWidth = width - (StatusCell.padding * 3) - StatusCell.imageWidth
        let attributedText = StatusCell.attributedTextString(withStatus: status, highlightWords: false)
        let textSize = attributedText.boundingRectWithSize(
            CGSize(width: realWidth, height:  CGFloat(FLT_MAX)),
            options: [.UsesFontLeading, .UsesLineFragmentOrigin],
            context: nil
        )
        
        let height = (StatusCell.padding * 3) + textSize.height + StatusCell.nameLabelHeight
        return height
    }
    
    static func nib() -> UINib {
        let name = NSStringFromClass(StatusCell.self).componentsSeparatedByString(".").last ?? ""
        return UINib(nibName: name, bundle: nil)
    }
    
}

/**
 Attributed string helpers
 */
extension StatusCell {
    
    private static func attributedTextString(withStatus status: Status, highlightWords: Bool) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.15
        let attributes = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: UIFont.news_secondaryFont(withSize: 16),
            NSForegroundColorAttributeName: UIColor.news_lightText()
        ]
        
        let attributedString = NSMutableAttributedString(string: status.text ?? "", attributes: attributes)
        
        if highlightWords == false {
            return attributedString
        }
        
        // Attribute hashtags
        status.hashtags?.forEach { hashtag in
            if let hashtag = hashtag as? Hashtag, text = hashtag.text {
                attributedString.hightlight(string: "#\(text)")
            }
        }
        
        // Attribute urls
        status.urls?.forEach { url in
            if let url = url as? Url, text = url.url {
                attributedString.hightlight(string: text)
            }
        }
        
        // Attribtue mentions
        status.mentions?.forEach { mention in
            if let mention = mention as? Mention, text = mention.screenName {
                attributedString.hightlight(string: "@\(text)")
            }
        }
        
        return attributedString
    }
    
}

extension NSMutableAttributedString {
    
    func hightlight(string string: String) {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.news_highlightText()
        ]
        let range = (self.string as NSString).rangeOfString(string)
        self.addAttributes(attributes, range: range)
    }
    
}
