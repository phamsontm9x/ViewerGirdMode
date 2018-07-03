//
//  ViewerInteractiveTransitioning.m
//  ViewerGridMode
//
//  Created by Son Pham on 6/18/18.
//  Copyright © 2018 Son Pham. All rights reserved.
//

#import "ViewerInteractiveTransitioning.h"
#import <objc/runtime.h>
#import "ViewerPageViewController.h"
#import "ViewerCollectionView.h"


@interface ViewerInteractiveTransitioning () <UIGestureRecognizerDelegate>
@property (nonatomic, assign) CGFloat startScale;
@property (nonatomic) ViewerPageViewController *viewController;
@property (nonatomic) ViewerCollectionView<ViewerTransitionProtocol> *presentViewController;

@end



@implementation ViewerInteractiveTransitioning {

}


- (void)attachToViewController:(ViewerPageViewController *)viewController withView:(UIView *)view presentViewController:(ViewerCollectionView<ViewerTransitionProtocol> *)presentViewController {
    
    self.viewController = viewController;
    self.presentViewController = presentViewController;
}


- (CGFloat)completionSpeed {
    return 1 - self.percentComplete;
}


@end
