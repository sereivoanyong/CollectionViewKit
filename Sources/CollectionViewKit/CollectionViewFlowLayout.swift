import UIKit

/// The purpose of this class is to fix incorrect alignment when `itemSize` is automatic as `UICollectionViewFlowLayout` does not correctly align content from left.
open class CollectionViewFlowLayout: UICollectionViewFlowLayout {
  
  open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    let allLayoutAttributes = super.layoutAttributesForElements(in: rect) ?? []
    if let collectionView = collectionView {
      let allCellLayoutAttributes = allLayoutAttributes.filter { $0.representedElementCategory == .cell }
      for (section, allSectionCellLayoutAttributes) in Dictionary(grouping: allCellLayoutAttributes, by: { $0.indexPath.section }) {
        let delegateFlowLayout = collectionView.delegate as? UICollectionViewDelegateFlowLayout
        let sectionInset = delegateFlowLayout?.collectionView?(collectionView, layout: self, insetForSectionAt: section) ?? self.sectionInset
        let minimumInteritemSpacing = delegateFlowLayout?.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: section) ?? self.minimumInteritemSpacing
        var maxX: CGFloat = sectionInset.left
        var maxY: CGFloat = -100000
        for sectionCellLayoutAttributes in allSectionCellLayoutAttributes.sorted(by: { $0.frame.minY > $1.frame.minY && $0.frame.minX > $1.frame.minX }) {
          if sectionCellLayoutAttributes.frame.minY > maxY {
            maxX = sectionInset.left
            maxY = sectionCellLayoutAttributes.frame.minY
          }
          sectionCellLayoutAttributes.frame.origin.x = maxX
          maxX += sectionCellLayoutAttributes.frame.width + minimumInteritemSpacing
        }
      }
    }
    return allLayoutAttributes
  }
}
