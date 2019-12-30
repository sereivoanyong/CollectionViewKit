import UIKit

public enum CollectionLayoutDimension {
  
  case fractional(CGFloat)
  case absolute(CGFloat)
  case estimated//(CGFloat)
}

public struct CollectionLayoutSize {
  
  public var widthDimension: CollectionLayoutDimension
  public var heightDimension: CollectionLayoutDimension
  
  public init(widthDimension: CollectionLayoutDimension, heightDimension: CollectionLayoutDimension) {
    self.widthDimension = widthDimension
    self.heightDimension = heightDimension
  }
}
