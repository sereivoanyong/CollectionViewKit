import UIKit

extension UICollectionReusableView {
  
  final weak public var collectionView: UICollectionView? {
    return value(forKey: "_collectionView") as? UICollectionView
  }
}

open class CollectionViewCell: UICollectionViewCell {
  
  @objc open class var _contentViewClass: UIView.Type {
    return UIView.self
  }
  
  open var layoutSize: CollectionLayoutSize = CollectionLayoutSize(widthDimension: .estimated, heightDimension: .estimated)
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    commonInit()
  }
  
  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    commonInit()
  }
  
  private func commonInit() {
    contentView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: topAnchor),
      contentView.leftAnchor.constraint(equalTo: leftAnchor),
      bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      rightAnchor.constraint(equalTo: contentView.rightAnchor)
    ])
  }
  
  open override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    let layoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
    guard let collectionView = collectionView, let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
      return layoutAttributes
    }
    let section = layoutAttributes.indexPath.section
    let parentSize: CGSize
    do {
      var sectionInset = (collectionView.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: flowLayout, insetForSectionAt: section) ?? flowLayout.sectionInset
      switch flowLayout.sectionInsetReference {
      case .fromContentInset:
        sectionInset = sectionInset + collectionView.contentInset
      case .fromSafeArea:
        sectionInset = sectionInset + collectionView.safeAreaInsets
      case .fromLayoutMargins:
        sectionInset = sectionInset + collectionView.layoutMargins
      @unknown default:
        break
      }
      parentSize = collectionView.bounds.inset(by: sectionInset).size
    }
    var lastEstimatedSize: CGSize?
    let width: CGFloat
    switch layoutSize.widthDimension {
    case .fractional(let value):
      let itemsPerRow = Int(1 / value)
      if itemsPerRow > 1 {
        let minimumInteritemSpacing = (collectionView.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: flowLayout, minimumInteritemSpacingForSectionAt: section) ?? flowLayout.minimumInteritemSpacing
        width = floor((parentSize.width - minimumInteritemSpacing * CGFloat(itemsPerRow - 1)) / CGFloat(itemsPerRow))
      } else {
        width = parentSize.width * value
      }
    case .absolute(let value):
      width = value
    case .estimated:
      let estimatedSize = contentView.systemLayoutSizeFitting(CGSize(width: parentSize.width, height: .greatestFiniteMagnitude))
      lastEstimatedSize = estimatedSize
      width = estimatedSize.width
    }
    
    let height: CGFloat
    switch layoutSize.heightDimension {
    case .fractional(let value):
      height = parentSize.height * value
    case .absolute(let value):
      height = value
    case .estimated:
      if let lastEstimatedSize = lastEstimatedSize {
        height = lastEstimatedSize.height
      } else {
        height = contentView.systemLayoutSizeFitting(CGSize(width: width, height: 0), withHorizontalFittingPriority: .defaultHigh, verticalFittingPriority: .fittingSizeLevel).height
      }
    }
    layoutAttributes.size = CGSize(width: width, height: height)
    
    return layoutAttributes
  }
}
