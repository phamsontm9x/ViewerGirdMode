//
//  ViewerInteractiveTransitioning.h
//  ViewerGridMode
//
//  Created by Son Pham on 6/18/18.
//  Copyright © 2018 Son Pham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewerTransition.h"



@class ViewerInteractiveTransitioning;

@protocol ViewerInteractiveTransitioningDelegate <NSObject>

- (void)endGesture;

@end



@interface ViewerInteractiveTransitioning : UIPercentDrivenInteractiveTransition

@property (nonatomic) BOOL interactionInProgress;
@property (nonatomic) BOOL isPresent;
@property (nonatomic) BOOL enableGesture;

@property (nonatomic) UIPanGestureRecognizer *panGesture;
@property (nonatomic) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic) UIRotationGestureRecognizer *roationGesture;

@property (nonatomic, weak) id<ViewerInteractiveTransitioningDelegate> delegateGesture;

- (void)attachToViewController:(UIViewController *)viewController withView:(UIView *)view presentViewController:(UICollectionViewController *)presentViewController;

@end
