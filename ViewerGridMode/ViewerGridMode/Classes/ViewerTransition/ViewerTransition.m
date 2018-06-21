//
//  ViewerTransition.m
//  ViewerGridMode
//
//  Created by Son Pham on 6/18/18.
//  Copyright © 2018 Son Pham. All rights reserved.
//

#import "ViewerTransition.h"
#import "ViewerCollectionView.h"
#import "ViewerPageViewController.h"



@interface ViewerTransition ()

@end


@implementation ViewerTransition

- (id)init {
    if (self = [super init]) {
        self.duration = 0.3;
        _enabledInteractive = YES;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController<ViewerTransitionProtocol> * fromVC = (id)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController<ViewerTransitionProtocol> *toVC = (id)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toVC.view;
    UIView *fromView = fromVC.view;
    
    [self animateTransition:transitionContext fromVC:fromVC toVC:toVC fromView:fromView toView:toView];
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController<ViewerTransitionProtocol> *)fromVC toVC:(UIViewController<ViewerTransitionProtocol> *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    
    UIView* containerView = [transitionContext containerView];
    
    UIView *toViewSnapshot = [toView resizableSnapshotViewFromRect:toView.frame afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
    
    
    UIImageView *viewBegin = [[UIImageView alloc] init];
    UIImageView *viewEnd = [[UIImageView alloc] init];
    
    if (_isPresent) {
        if (_enabledInteractive) {
            
            
            if ([toVC respondsToSelector:@selector(getImageViewPresent)]) {
                viewEnd = [toVC getImageViewPresent];
            } else {
                viewEnd.frame = toView.frame;
            }
            //
            [viewBegin setFrame:toView.frame];
            viewBegin.backgroundColor = [UIColor whiteColor];
            viewBegin.alpha = 1.0;
            fromView.alpha = 1.0;
            fromView.backgroundColor = [UIColor clearColor];
            toView.alpha = 1.0;
        
            [containerView addSubview:toView];
            [containerView addSubview:viewBegin];
            [containerView addSubview:fromView];
            
        } else {
            
            viewBegin = [self snapshotImageViewFromView:_snapShot];
            _frameSnapShot.origin.y = 20;
            [viewBegin setFrame:_frameSnapShot];
            
            // get frame and image view begin
            if ([toVC respondsToSelector:@selector(getImageViewPresent)]) {
                viewEnd = [toVC getImageViewPresent];
            } else {
                viewEnd.frame = toView.frame;
            }

            viewBegin.alpha = 1.0;
            fromView.alpha = 0.0;
            toView.alpha = 1.0;
            [containerView addSubview:toView];
            [containerView addSubview:fromView];
            [containerView addSubview:viewBegin];
        }
    } else {
        
        // get frame and image view begin
        if ([fromVC respondsToSelector:@selector(getImageViewPresent)]) {
            UIImageView *view = [fromVC getImageViewPresent];
            
            viewBegin = [self snapshotImageViewFromView:view];
            viewBegin.frame = view.frame;
        } else {
            viewBegin.frame = fromView.frame;
        }
        [containerView addSubview:toView];
        [containerView addSubview:fromView];
        [containerView addSubview:viewBegin];
        _toViewDefault.origin.y = 20;
        viewEnd.frame = _toViewDefault;
        fromView.alpha = 1.0;
        toView.alpha = 0;
    }
    
    
    // animate
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if (_isPresent) {
                             if (!_enabledInteractive) {
                                 [viewBegin setFrame:viewEnd.frame];
                                 toView.alpha = 1;
                                 viewBegin.alpha = 1;
                             } else {
                                 viewBegin.alpha = 0;
                             }
                         } else {
                             [viewBegin setFrame:viewEnd.frame];
                         }
                         
                     } completion:^(BOOL finished) {
                         _enabledInteractive = YES;
                         if ([transitionContext transitionWasCancelled]) {
                             fromView.alpha = 1;
                             [toView removeFromSuperview];
                             [viewBegin removeFromSuperview];
//                             //[_snapShot removeFromSuperview];
                         } else {
                             toView.alpha = 1.0;
                             [fromView removeFromSuperview];
                             [viewBegin removeFromSuperview];
                             [_snapShot removeFromSuperview];
                    
                         }
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
}

-(UIImageView *)snapshotImageViewFromView:(UIView *)view {
    UIImage * snapshot = [self dt_takeSnapshotWihtView:view];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:snapshot];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.clipsToBounds = YES;
    return imageView;
}


-(UIImage *)dt_takeSnapshotWihtView:(UIView*)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshot;
}

@end
