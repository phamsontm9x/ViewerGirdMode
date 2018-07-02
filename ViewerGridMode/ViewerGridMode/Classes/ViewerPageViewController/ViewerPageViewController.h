//
//  ViewerPageViewController.h
//  ViewerGridMode
//
//  Created by Son Pham on 6/18/18.
//  Copyright © 2018 Son Pham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewerCollectionView.h"
#import "ViewerTransition.h"
#import "BaseViewerPageViewController.h"



NS_ASSUME_NONNULL_BEGIN

//@class ViewerPageViewController;
//
//@protocol ViewerPageViewControllerDelegate <NSObject>
//
//- (void)viewerPageViewController:(ViewerPageViewController *)vc clv:(ViewerCollectionView*)clv jumpToViewControllerAtIndex:(NSInteger)index;
//
//@end


@interface ViewerPageViewController : BaseViewerPageViewController


@property (nonatomic, weak) IBOutlet UIView *defaultView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrPageView;
@property (nonatomic) BOOL isZoomImage;

//@property (nonatomic) NSInteger indexPath;
//@property (nonatomic) CGPoint contentOffSetClv;

//@property (nonatomic, strong) ViewerCollectionView<ViewerTransitionProtocol> *vcPresent;
//@property (nonatomic, weak) id<ViewerPageViewControllerDelegate> delegate;
@property (nonatomic, strong) ViewerInteractiveTransitioning *interactiveTransitionPresent;

//- (void)didTapOnGirdMode;

@end



NS_ASSUME_NONNULL_END
