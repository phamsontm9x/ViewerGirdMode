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



NS_ASSUME_NONNULL_BEGIN

@class ViewerPageViewController;

@protocol ViewerPageViewControllerDelegate <NSObject>

- (void)viewerPageViewController:(ViewerPageViewController *)vc clv:(ViewerCollectionView*)clv jumpToViewControllerAtIndex:(NSInteger)index;

@end


@interface ViewerPageViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIImageView *imv;
@property (nonatomic, weak) IBOutlet UIView *defaultView;
@property (nonatomic, weak) IBOutlet UIButton *btnShowList;
@property (nonatomic) NSInteger indexPath;

@property (nonatomic, weak) id<ViewerPageViewControllerDelegate> delegate;

@end



NS_ASSUME_NONNULL_END
