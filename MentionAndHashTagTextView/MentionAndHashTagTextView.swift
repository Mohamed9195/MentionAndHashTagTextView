//
//  MHTextView.swift
//  MentionAndHashTagTextView
//
//  Created by mohamed hashem on 07/01/2021.
//

import UIKit

public var friendsAre: [String]?
public var MHTextView: MentionAndHashTagTextView?

open class MentionAndHashTagTextView: UITextView {
    var prefixes = ["@", "#"]
    var tags = [HashTagInfo]()
    let transparentView = UIView()
    let tableView = UITableView()
    public var parentView: UIViewController?


    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }

    func addTransparentView(frames: CGRect) {
        let window = UIApplication.shared.keyWindow
        transparentView.frame = window?.frame ?? parentView!.view.frame
        parentView?.view.addSubview(transparentView)

        tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: 200.0, height: 0)
        parentView?.view.addSubview(tableView)
        tableView.layer.cornerRadius = 10

        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        tableView.reloadData()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0.5
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: 200, height: 200)
        }, completion: nil)
    }

    @objc func removeTransparentView() {
        let frames = MHTextView?.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.tableView.frame = CGRect(x: frames!.origin.x, y: frames!.origin.y + frames!.height, width: frames!.width, height: 0)
        }, completion: nil)
    }
}

extension MentionAndHashTagTextView: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        guard let string = textView.text else { return }
        if string.last == "@" || string.last == "#" {
            self.attributedText = self.detect(string: string)
            self.addTransparentView(frames: self.self.frame)
        }
        let range = textView.selectedRange
        textView.attributedText = detect(string: string)
        textView.selectedRange = range
    }

    func detect(string: String) -> NSMutableAttributedString {
        let regex = try? NSRegularExpression(pattern: "[\(prefixes.joined())]\\w+", options: [.caseInsensitive])

        let attributeString = NSMutableAttributedString(string: string, attributes: [
            .font : UIFont.init(name: "Segoe UI", size: 15) ?? UIFont.systemFont(ofSize: 15),
            .foregroundColor : #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        ])

        guard let words = regex?.matches(in: string, options: [], range: NSRange(location: 0, length: string.count)).map ({ (result) -> HashTagInfo in
            let startIndex = string.index(string.startIndex, offsetBy: result.range.location)
            let endIndex = string.index(string.startIndex, offsetBy: result.range.location + result.range.length)

            var string = String(string[startIndex..<endIndex])
            let prefix = hasPrefix(string: string).1
            if string.isArabic {
                string = ""
            }
            if string.contains("@") {
                let range = NSRange(location: startIndex.utf16Offset(in: string), length: endIndex.utf16Offset(in: string) - startIndex.utf16Offset(in: string))
                return HashTagInfo(string: string, prefix: prefix ?? "", range: range)
            } else {
                let range = NSRange(location: startIndex.utf16Offset(in: string), length: endIndex.utf16Offset(in: string) - startIndex.utf16Offset(in: string))
                return HashTagInfo(string: string, prefix: prefix ?? "", range: range)
            }
        }) else {
            return attributeString
        }
        tags = words
        for tag in tags {
            attributeString.addAttributes([.link : tag.string], range: tag.range)
        }
        return attributeString
    }

    func hasPrefix(string: String) -> (Bool, String?) {
        for prefix in prefixes where string.hasPrefix(prefix) {
            return (true, prefix)
        }
        return (false, nil)
    }

    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        guard let string = textView.text else {return true}
        let startIndex = string.index(string.startIndex, offsetBy: characterRange.location)
        let endIndex = string.index(startIndex, offsetBy: characterRange.length)
        let substring = string[startIndex..<endIndex]
        let (isPrefix, prefix) = hasPrefix(string: String(substring))
        guard isPrefix, let prefixString = prefix else { return true }
        if prefixString.contains("@") {
            didTouchClosure(isTag: .mention)
        } else if prefixString.contains("#") {
            didTouchClosure(isTag: .tags)
        } else {
            didTouchClosure(isTag: .normal)
        }
        return false
    }

    func didTouchClosure(isTag: MentionTypes) {
        if isTag == .mention {
        } else if isTag == .tags {
        } else {
            didTouchClosure(isTag: .normal)
        }
    }
}

extension String {
    var isArabic: Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "(?s).*\\p{Arabic}.*")
        return predicate.evaluate(with: self)
    }
}

extension UIViewController : UITableViewDelegate, UITableViewDataSource {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsAre?.count ?? 0
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AllFriendTableViewCell", for: indexPath) as? AllFriendTableViewCell else {
            fatalError()
        }
        cell.nameLabel.text = friendsAre?[indexPath.row] ?? ""
        return cell
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let text = MHTextView?.text ?? ""
        MHTextView?.text = text + (friendsAre?[indexPath.row] ?? "").replacingOccurrences(of: " ", with: "")
        MHTextView?.removeTransparentView()
    }
}

public class HashTagInfo: NSObject {
    var prefix: String
    var string: String
    var word: String
    var range: NSRange
    var isTag:MentionTypes = .normal

    public override var description: String {
        return "string: \(string), prefix(\(prefix)), word(\(word)), range(location: \(range.location), length: \(range.length))"
    }

    init(string: String, prefix: String, range: NSRange) {
        self.string = string
        self.prefix = prefix
        self.range = range
        self.word = string.replacingOccurrences(of: prefix, with: "")
    }
}

enum MentionTypes {
    case tags
    case mention
    case normal
}
