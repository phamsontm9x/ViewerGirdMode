//
//  PageCollectionViewFlowLayout.m
//  ViewerGridMode
//
//  Created by Son Pham on 7/4/18.
//  Copyright © 2018 ThanhSon. All rights reserved.
//

#import "PageCollectionViewFlowLayout.h"

@implementation PageCollectionViewFlowLayout

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    
    return self;
}

- (void)prepareLayout {

}

//- (NSArray <UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
//    NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributesArray = [NSMutableArray new];
//    
//    for (UICollectionViewLayoutAttributes *layoutAttributes in _layoutArray.allValues) {
//        if (CGRectIntersectsRect(layoutAttributes.frame, rect)) {
//            [layoutAttributesArray addObject:layoutAttributes];
//        }
//    }
//    
//    return layoutAttributesArray;
//}
//
//- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return _layoutArray[indexPath];
//}

@end
