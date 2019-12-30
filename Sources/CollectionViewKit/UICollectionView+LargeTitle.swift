import UIKit

extension CGFloat {
  
  static let pixel: CGFloat = 1/UIScreen.main.scale
  
  @inlinable var ceiledToScreenScale: CGFloat {
    let scale = UIScreen.main.scale
    return ceil(self * scale) / scale
  }
  
  @inlinable var flooredToScreenScale: CGFloat {
    let scale = UIScreen.main.scale
    return floor(self * scale) / scale
  }
}

extension UIEdgeInsets {
  
  static func + (lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
    return UIEdgeInsets(top: lhs.top + rhs.top, left: lhs.left + rhs.left, bottom: lhs.bottom + rhs.bottom, right: lhs.right + rhs.right)
  }
}

open class CollectionLargeTitleHeaderView: UICollectionReusableView {
  
  public static var titleFont: UIFont?
  public static let height: CGFloat = 14 + (titleFont ?? .systemFont(ofSize: 19, weight: .bold)).lineHeight.ceiledToScreenScale + 4
  
  public let titleLabel: UILabel = {
    let label = UILabel()
    label.font = CollectionLargeTitleHeaderView.titleFont ?? .systemFont(ofSize: 19, weight: .bold)
    label.textAlignment = .left
    if #available(iOS 13.0, *) {
      label.textColor = .label
    } else {
      label.textColor = .black
    }
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    preservesSuperviewLayoutMargins = true
    addSubview(titleLabel)
    
    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
      titleLabel.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
      bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4)
    ])
  }
  
  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

open class CollectionLargeTitleFooterView: UICollectionReusableView {
  
  public static let height: CGFloat = 14 + .pixel
  
  public let separatorView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    preservesSuperviewLayoutMargins = true
    addSubview(separatorView)
    
    NSLayoutConstraint.activate([
      separatorView.heightAnchor.constraint(equalToConstant: .pixel),
      separatorView.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
      layoutMarginsGuide.rightAnchor.constraint(equalTo: separatorView.rightAnchor),
      bottomAnchor.constraint(equalTo: separatorView.bottomAnchor)
    ])
  }
  
  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

public protocol UICollectionViewLargeTitleDataSource: AnyObject {
  
  func collectionView(_ collectionView: UICollectionView, largeTitleForSection section: Int) -> String?
}

extension UICollectionView {
  
  private static var largeTitleKey: Void?
  final public var largeTitle: LargeTitle {
    if let largeTitle = objc_getAssociatedObject(self, &Self.largeTitleKey) as? LargeTitle {
      return largeTitle
    }
    let largeTitle = LargeTitle(self)
    objc_setAssociatedObject(self, &Self.largeTitleKey, largeTitle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return largeTitle
  }
  
  final public class LargeTitle {
    
    unowned private let collectionView: UICollectionView
    weak public var dataSource: UICollectionViewLargeTitleDataSource?
    
    /// Color to apply to footer view separators. Default is `.separator`.
    public var sectionSeparatorColor: UIColor
    
    fileprivate init(_ collectionView: UICollectionView) {
      if #available(iOS 13.0, *) {
        sectionSeparatorColor = .separator
      } else {
        // https://noahgilmore.com/blog/dark-mode-uicolor-compatibility/
        sectionSeparatorColor = UIColor(red: 60/255.0, green: 60/255.0, blue: 67/255.0, alpha: 0.29)
      }
      self.collectionView = collectionView
    }
    
    public func registerHeaderFooterViews() {
      collectionView.register(CollectionLargeTitleHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "LargeTitleHeaderView")
      collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "EmptyLargeTitleHeaderView")
      collectionView.register(CollectionLargeTitleFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "EmptyLargeTitleFooterView")
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
      switch kind {
      case UICollectionView.elementKindSectionHeader:
        if let title = dataSource?.collectionView(collectionView, largeTitleForSection: indexPath.section) {
          let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "LargeTitleHeaderView", for: indexPath) as! CollectionLargeTitleHeaderView
          headerView.titleLabel.text = title
          return headerView
        } else {
          return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EmptyLargeTitleHeaderView", for: indexPath)
        }
        
      case UICollectionView.elementKindSectionFooter:
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EmptyLargeTitleFooterView", for: indexPath) as! CollectionLargeTitleFooterView
        footerView.separatorView.backgroundColor = sectionSeparatorColor
        return footerView
        
      default:
        fatalError()
      }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
      if dataSource?.collectionView(collectionView, largeTitleForSection: section) == nil {
        return CGSize(width: collectionView.bounds.width, height: 14)
      } else {
        return CGSize(width: collectionView.bounds.width, height: CollectionLargeTitleHeaderView.height)
      }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
      return CGSize(width: collectionView.bounds.width, height: CollectionLargeTitleFooterView.height)
    }
  }
}
