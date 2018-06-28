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
        self.duration = 0.4f;
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

    UIImageView *viewBegin = [self snapshotImageViewFromView:fromView];
    UIImageView *viewEnd = [self snapshotImageViewFromView:toView];
    
    CGRect frame = toView.frame;
    frame.origin.y = 100;
    
    //toView.frame = frame;
    
    //viewEnd.frame = CGRectMake(0, toView.frame.size.height, viewEnd.frame.size.width, viewEnd.frame.size.height);
    
    toView.alpha = 0;
    fromView.alpha = 0;
    
    [containerView addSubview:toView];
    [containerView addSubview:fromView];
    
    //[containerView addSubview:viewBegin];
    //[containerView addSubview:viewEnd];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         if (_isPresent) {
                             //viewBegin.alpha = 0.5;
                             //viewEnd.frame = frame;
                         } else {
                             
                         }
                         
                     } completion:^(BOOL finished) {
                         if ([transitionContext transitionWasCancelled]) {
                         
                         } else {
                             toView.alpha = 1.0;
                             fromView.alpha = 1.0;
                             //[viewBegin removeFromSuperview];
                             //[viewEnd removeFromSuperview];
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
