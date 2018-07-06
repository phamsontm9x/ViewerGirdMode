//
//  PageCollectionViewCell.h
//  ViewerGridMode
//
//  Created by Son Pham on 7/2/18.
//  Copyright © 2018 ThanhSon. All rights reserved.
//

#import <UIKit/UIKit.h>



@class PageCollectionViewCell;

@protocol PageCollectionViewCellDelegate <NSObject>

- (void)pageCollectionViewCell:(PageCollectionViewCell *)cell dismissViewController:(NSInteger)index;
- (void)pageCollectionViewCell:(PageCollectionViewCell *)cell updateInteractiveTransition:(CGFloat)vaule;
- (void)pageCollectionViewCell:(PageCollectionViewCell *)cell andGesture:(UIPinchGestureRecognizer*)gesture finishInteractiveTransition:(BOOL)finished;
- (void)pageCollectionViewCell:(PageCollectionViewCell *)cell isZoomingWithSize:(CGSize)size;

- (void)pageCollectionViewCell:(PageCollectionViewCell *)cell isZoomingEndAtIndex:(NSInteger)index;

@end


@interface PageCollectionViewCell : UICollectionViewCell


@property (nonatomic, weak) IBOutlet UIImageView *imv;
@property (nonatomic, weak) IBOutlet UIScrollView *scrPageView;

@property (nonatomic) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic) NSInteger indexPage;
@property (nonatomic) BOOL enableGesture;
@property (nonatomic) BOOL isZoomImage;

@property (nonatomic, weak) id<PageCollectionViewCellDelegate> delegate;

@end
