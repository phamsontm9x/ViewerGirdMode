//
//  ReadingBreakTransition.m
//  ViewerGridMode
//
//  Created by Son Pham on 6/28/18.
//  Copyright © 2018 ThanhSon. All rights reserved.
//

#import "ReadingBreakTransition.h"



@interface ReadingBreakTransition ()

@end



@implementation ReadingBreakTransition

- (id)init {
    if (self = [super init]) {
        self.duration = 0.3f;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController * fromVC = (id)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *fromView = fromVC.view;
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toVC.view;
    
    [self animateTransition:transitionContext fromVC:fromVC toVC:toVC fromView:fromView toView:toView];
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    
    UIView* containerView = [transitionContext containerView];
    
    CGRect frameEnd = toView.frame;
    
    if (_isPresent) {
        
        toView.frame = CGRectMake(0, frameEnd.size.height, frameEnd.size.width, frameEnd.size.height);
        [containerView addSubview:toView];
        
    } else {
        [containerView addSubview:fromView];
        frameEnd = CGRectMake(0, toView.frame.size.height, toView.frame.size.width, toView.frame.size.height);
    }
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         if (_isPresent) {
                             fromView.alpha = 0.5;
                             toView.frame = frameEnd;
                         } else {
                             toView.alpha = 1.0;
                             fromView.frame = frameEnd;
                         }
                         
                     } completion:^(BOOL finished) {
                         if ([transitionContext transitionWasCancelled]) {
                             if (!_isPresent) {
                                [containerView bringSubviewToFront:fromView];
                             }
                         }
                         
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
}


#pragma mark - TakeSnapShot

-(UIImageView *)snapshotImageViewFromView:(UIView *)view {
    UIImage * snapshot = [self dt_takeSnapshotWihtView:view];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:snapshot];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
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
