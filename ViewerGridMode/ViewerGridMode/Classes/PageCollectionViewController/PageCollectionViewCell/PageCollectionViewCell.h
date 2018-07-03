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
- (void)pageCollectionViewCell:(PageCollectionViewCell *)cell finishInteractiveTransition:(BOOL)finished;

@end


@interface PageCollectionViewCell : UICollectionViewCell

@property (nonatomic) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, weak) IBOutlet UIImageView *imv;
@property (nonatomic) NSInteger indexPage;
@property (nonatomic) BOOL enableGesture;

@property (nonatomic, weak) id<PageCollectionViewCellDelegate> delegate;

@end
