//
//  BaseViewerPageViewController.h
//  ViewerGridMode
//
//  Created by Son Pham on 7/2/18.
//  Copyright © 2018 ThanhSon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewerCollectionView.h"

NS_ASSUME_NONNULL_BEGIN

@class BaseViewerPageViewController;

@protocol BaseViewerPageViewControllerDelegate <NSObject>

- (void)viewerPageViewController:(BaseViewerPageViewController *)vc clv:(ViewerCollectionView*)clv jumpToViewControllerAtIndex:(NSInteger)index;

@end

@interface BaseViewerPageViewController : UIViewController

@property (nonatomic, strong) ViewerCollectionView<ViewerTransitionProtocol> *vcPresent;
@property (nonatomic, weak) id<BaseViewerPageViewControllerDelegate> delegate;

@property (nonatomic) NSInteger indexPath;
@property (nonatomic) CGPoint contentOffSetClv;

- (void)didTapOnGirdMode;
- (void)viewerPageViewControllerDelegate:(BaseViewerPageViewController *)vc clv:(ViewerCollectionView*)clv jumpToViewControllerAtIndex:(NSInteger)index;

@end



NS_ASSUME_NONNULL_END
