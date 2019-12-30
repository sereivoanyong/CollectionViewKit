import UIKit

extension UICollectionReusableView {
  
  @inlinable final public var layoutAttributes: UICollectionViewLayoutAttributes? {
    return value(forKey: "_layoutAttributes") as? UICollectionViewLayoutAttributes
  }
}

open class CollectionViewCell: UICollectionViewCell {
  
  open var layoutInsetReference: CollectionLayoutInsetReference = .fromContentInset
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
  
  open override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
    let collectionView = superview as? UICollectionView ?? value(forKey: "collectionView") as! UICollectionView
    var parentLayoutSize = Lazy<CGSize>(wrappedValue: {
      switch layoutInsetReference {
      case .fromContentInset:
        return collectionView.bounds.inset(by: collectionView.contentInset).size
      case .fromSafeArea:
        return collectionView.bounds.inset(by: collectionView.safeAreaInsets).size
      case .fromLayoutMargins:
        return collectionView.bounds.inset(by: collectionView.layoutMargins).size
      }
    }())
    var estimatedSize = Lazy<CGSize>(wrappedValue: {
      let targetView = contentView
      return targetView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: .greatestFiniteMagnitude), withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
    }())
    let width: CGFloat
    switch layoutSize.widthDimension {
    case .fractional(let value):
      let itemsPerRow = Int(1 / value)
      if itemsPerRow > 1 {
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let minimumInteritemSpacing = (collectionView.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView, layout: flowLayout, minimumInteritemSpacingForSectionAt: layoutAttributes!.indexPath.section) ?? flowLayout.minimumInteritemSpacing
        width = floor((parentLayoutSize.wrappedValue.width - minimumInteritemSpacing * CGFloat(itemsPerRow - 1)) / CGFloat(itemsPerRow))
      } else {
        width = parentLayoutSize.wrappedValue.width * value
      }
    case .absolute(let value):
      width = value
    case .estimated:
      width = estimatedSize.wrappedValue.width
    }
    let height: CGFloat
    switch layoutSize.heightDimension {
    case .fractional(let value):
      height = parentLayoutSize.wrappedValue.height * value
      
    case .absolute(let value):
      height = value
      
    case .estimated:
      if targetSize.width != width {
        height = contentView.systemLayoutSizeFitting(CGSize(width: width, height: .greatestFiniteMagnitude), withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority).height
      } else {
        height = estimatedSize.wrappedValue.height
      }
    }
    return CGSize(width: width, height: height)
  }
}

private enum Lazy<Value> {
  
  case uninitialized(() -> Value)
  case initialized(Value)

  init(wrappedValue: @autoclosure @escaping () -> Value) {
    self = .uninitialized(wrappedValue)
  }

  var wrappedValue: Value {
    mutating get {
      switch self {
      case .uninitialized(let initializer):
        let value = initializer()
        self = .initialized(value)
        return value
      case .initialized(let value):
        return value
      }
    }
    set {
      self = .initialized(newValue)
    }
  }
}
