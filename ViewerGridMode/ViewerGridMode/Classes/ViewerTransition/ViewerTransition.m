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
        self.duration = 0.5;
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
    
    switch (_transitionMode) {
        case ViewerTransitionModePage:
            [self animateTransitionModePage:transitionContext fromVC:fromVC toVC:toVC fromView:fromView toView:toView];
            break;
            
        case ViewerTransitionModeAds:
            [self animateTransitionModeAds:transitionContext fromVC:fromVC toVC:toVC fromView:fromView toView:toView];
            break;
            
        case ViewerTransitionModeCollection:
            [self animateTransitionModeCollection:transitionContext fromVC:fromVC toVC:toVC fromView:fromView toView:toView];
            break;
            
        default:
            [self animateTransitionModePage:transitionContext fromVC:fromVC toVC:toVC fromView:fromView toView:toView];
            break;
    }
}

- (void)animateTransitionModePage:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController<ViewerTransitionProtocol> *)fromVC toVC:(UIViewController<ViewerTransitionProtocol> *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    
    UIView* containerView = [transitionContext containerView];
//    UIView *toViewSnapshot = [toView resizableSnapshotViewFromRect:toView.frame afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
    
    UIImageView *viewBegin = [[UIImageView alloc] init];
    UIImageView *viewEnd = [[UIImageView alloc] init];
    
    viewBegin.contentMode = UIViewContentModeScaleAspectFit;
    viewEnd.contentMode = UIViewContentModeScaleAspectFit;
    
    viewBegin.alpha = 1.0;
    fromView.alpha = 1.0;
    toView.alpha = 1.0;
    
    if (_isPresent) {
        
        // Disable collectionView when present
        ViewerCollectionView *vc = (ViewerCollectionView*)toVC;
        vc.collectionView.userInteractionEnabled = NO;
        
        if ([toVC respondsToSelector:@selector(getImageViewPresent)]) {
            viewEnd = [toVC getImageViewPresent];
        } else {
            viewEnd.frame = toView.frame;
        }
        
        if (_enabledInteractive) {
            
            [viewBegin setFrame:toView.frame];
            viewBegin.backgroundColor = [UIColor blackColor];
            fromView.backgroundColor = [UIColor clearColor];
        
        } else {
            
            [viewBegin setFrame:_frameSnapShot];
            viewBegin.image = _snapShot.image;
        
            fromView.alpha = 0.0;
        }
        
        [containerView addSubview:toView];
        [containerView addSubview:viewBegin];
        [containerView addSubview:fromView];
        
    } else {
        
        // get frame and image view begin
        if ([fromVC respondsToSelector:@selector(getImageViewPresent)]) {
            UIImageView *view = [fromVC getImageViewPresent];
            viewBegin = [self snapshotImageViewFromView:view];
            viewBegin.image = view.image;
            viewBegin.frame = view.frame;
        } else {
            viewBegin.frame = fromView.frame;
        }
        
        [containerView addSubview:toView];
        [containerView addSubview:fromView];
        [containerView addSubview:viewBegin];
        viewEnd.frame = _toViewDefault;
        fromView.alpha = 1.0;
        toView.alpha = 0;
    }
    
    
    // animate
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (_isPresent) {
            if (_enabledInteractive) {
                viewBegin.alpha = 0;
            } else {
                [viewBegin setFrame:viewEnd.frame];
                toView.alpha = 1;
                viewBegin.alpha = 1;
            }
        } else {
            [viewBegin setFrame:viewEnd.frame];
            fromView.alpha = 0.0;
        }
    } completion:^(BOOL finished) {
        if (![transitionContext transitionWasCancelled]) {
            toView.alpha = 1.0;
            [fromView removeFromSuperview];
            [viewBegin removeFromSuperview];
            [_snapShot removeFromSuperview];
            
            if (_isPresent) {
                ViewerCollectionView *vc = (ViewerCollectionView*)toVC;
                if (!_enabledInteractive) {
                    vc.isProcessingTransition = NO;
                }
                vc.collectionView.userInteractionEnabled = YES;
            }
            
        } else {
            fromView.alpha = 1;
            [toView removeFromSuperview];
            [viewBegin removeFromSuperview];
        }
        
        _enabledInteractive = YES;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];

}

- (void)animateTransitionModeAds:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController<ViewerTransitionProtocol> *)fromVC toVC:(UIViewController<ViewerTransitionProtocol> *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    
    UIView* containerView = [transitionContext containerView];
    UIView *toViewSnapshot = [toView resizableSnapshotViewFromRect:toView.frame afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
    
    UIImageView *viewBegin = [[UIImageView alloc] init];
    UIImageView *viewEnd = [[UIImageView alloc] init];
    
    UIView *vFade = [[UIView alloc] initWithFrame:toView.frame];
    
    viewBegin.contentMode = UIViewContentModeScaleAspectFit;
    viewEnd.contentMode = UIViewContentModeScaleAspectFit;
    
    viewBegin.alpha = 1.0;
    toView.alpha = 1.0;
    fromView.alpha = 1.0;
    
    if (_isPresent) {
        
        // Disable collectionView when present
        ViewerCollectionView *vc = (ViewerCollectionView*)toVC;
        vc.collectionView.userInteractionEnabled = NO;
        
        if ([toVC respondsToSelector:@selector(getImageViewPresent)]) {
            viewEnd = [toVC getImageViewPresent];
        } else {
            viewEnd.frame = toView.frame;
        }
        
        if (_enabledInteractive) {
            
            [viewBegin setFrame:toView.frame];
            viewBegin.backgroundColor = [UIColor clearColor];
            fromView.backgroundColor = [UIColor clearColor];
            
        } else {
            
            [viewBegin setFrame:_frameSnapShot];
            viewBegin.image = _snapShot.image;
            
            vFade.backgroundColor = [UIColor whiteColor];
            vFade.alpha = 1.0;
            fromView.alpha = 0.0;
        }
        
        [containerView addSubview:toView];
        [containerView addSubview:vFade];
        [containerView addSubview:viewBegin];
        [containerView addSubview:fromView];
        
    } else {
        
        // get frame and image view begin
        if ([fromVC respondsToSelector:@selector(getImageViewPresent)]) {
            UIImageView *view = [fromVC getImageViewPresent];
            viewBegin = [self snapshotImageViewFromView:toView];
            viewBegin.frame = view.frame;
        } else {
            viewBegin.frame = fromView.frame;
        }
        
        [containerView addSubview:toView];
        [containerView addSubview:fromView];
        [containerView addSubview:viewBegin];
        viewEnd.frame = _toViewDefault;
        fromView.alpha = 1.0;
        toView.alpha = 0;
    }
    
    
    // animate
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (_isPresent) {
            if (_enabledInteractive) {
                viewBegin.alpha = 0;
            } else {
                [viewBegin setFrame:viewEnd.frame];
                toView.alpha = 1;
                viewBegin.alpha = 1;
                vFade.alpha = 0.0;
            }
        } else {
            [viewBegin setFrame:viewEnd.frame];
            fromView.alpha = 0.0;
        }
    } completion:^(BOOL finished) {
        if (![transitionContext transitionWasCancelled]) {
            toView.alpha = 1.0;
            [fromView removeFromSuperview];
            [vFade removeFromSuperview];
            [viewBegin removeFromSuperview];
            [_snapShot removeFromSuperview];
            
            if (_isPresent) {
                ViewerCollectionView *vc = (ViewerCollectionView*)toVC;
                if (!_enabledInteractive) {
                    vc.isProcessingTransition = NO;
                }
                vc.collectionView.userInteractionEnabled = YES;
            }
            
        } else {
            fromView.alpha = 1;
            [toView removeFromSuperview];
            [viewBegin removeFromSuperview];
        }
        
        _enabledInteractive = YES;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (void)animateTransitionModeCollection:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController<ViewerTransitionProtocol> *)fromVC toVC:(UIViewController<ViewerTransitionProtocol> *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    
    UIView* containerView = [transitionContext containerView];
    UIView *toViewSnapshot = [toView resizableSnapshotViewFromRect:toView.frame afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
    
    UIImageView *viewBegin = [[UIImageView alloc] init];
    UIImageView *viewEnd = [[UIImageView alloc] init];
    
    viewBegin.contentMode = UIViewContentModeScaleAspectFit;
    viewEnd.contentMode = UIViewContentModeScaleAspectFit;
    
    viewBegin.alpha = 1.0;
    toView.alpha = 1.0;
    fromView.alpha = 1.0;
    
    if (_isPresent) {
        
        // Disable collectionView when present
        ViewerCollectionView *vc = (ViewerCollectionView*)toVC;
        vc.collectionView.userInteractionEnabled = NO;
        
        if ([toVC respondsToSelector:@selector(getImageViewPresent)]) {
            viewEnd = [toVC getImageViewPresent];
        } else {
            viewEnd.frame = toView.frame;
        }
        
        if (_enabledInteractive) {
            
            [viewBegin setFrame:toView.frame];
            viewBegin.backgroundColor = [UIColor whiteColor];
            fromView.backgroundColor = [UIColor clearColor];
            
        } else {
            
            [viewBegin setFrame:_snapShot.frame];
            viewBegin.image = _snapShot.image;
            
            fromView.alpha = 0.0;
        }
        
        [containerView addSubview:toView];
        [containerView addSubview:viewBegin];
        [containerView addSubview:fromView];
        
    } else {
        
        // get frame and image view begin
        if ([fromVC respondsToSelector:@selector(getImageViewPresent)]) {
            UIImageView *view = [fromVC getImageViewPresent];
            viewBegin = [self snapshotImageViewFromView:view];
            viewBegin.image = view.image;
            viewBegin.frame = view.frame;
        } else {
            viewBegin.frame = fromView.frame;
        }
        
        [containerView addSubview:toView];
        [containerView addSubview:fromView];
        [containerView addSubview:viewBegin];
        viewEnd.frame = _toViewDefault;
        fromView.alpha = 1.0;
        toView.alpha = 0;
    }
    
    
    // animate
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (_isPresent) {
            if (_enabledInteractive) {
                viewBegin.alpha = 0;
            } else {
                [viewBegin setFrame:viewEnd.frame];
                toView.alpha = 1;
                viewBegin.alpha = 1;
            }
        } else {
            [viewBegin setFrame:viewEnd.frame];
            fromView.alpha = 0.0;
        }
    } completion:^(BOOL finished) {
        if (![transitionContext transitionWasCancelled]) {
            toView.alpha = 1.0;
            [fromView removeFromSuperview];
            [viewBegin removeFromSuperview];
            [_snapShot removeFromSuperview];
            
            if (_isPresent) {
                ViewerCollectionView *vc = (ViewerCollectionView*)toVC;
                if (!_enabledInteractive) {
                    vc.isProcessingTransition = NO;
                }
                vc.collectionView.userInteractionEnabled = YES;
            }
            
        } else {
            fromView.alpha = 1;
            [toView removeFromSuperview];
            [viewBegin removeFromSuperview];
        }
        
        _enabledInteractive = YES;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}


#pragma mark - SnapShot

-(UIImageView *)snapshotImageViewFromView:(UIView *)view {
    UIImage * snapshot = [self dt_takeSnapshotWihtView:view];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:snapshot];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds = YES;
    return imageView;
}


-(UIImage *)dt_takeSnapshotWihtView:(UIView*)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshot;
}

@end
