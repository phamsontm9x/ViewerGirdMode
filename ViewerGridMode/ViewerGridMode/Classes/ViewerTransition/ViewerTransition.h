//
//  ViewerTransition.h
//  ViewerGridMode
//
//  Created by Son Pham on 6/18/18.
//  Copyright © 2018 Son Pham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>



@protocol ViewerTransitionProtocol <NSObject>;

- (UIImageView *)getImageViewPresent;

@end



@interface ViewerTransition : NSObject<UIViewControllerAnimatedTransitioning>

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView;


@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) BOOL isPresent;
@property (nonatomic, assign) BOOL enabledInteractive;
@property (nonatomic) CGRect fromViewDefault;
@property (nonatomic) CGRect toViewDefault;
@property (nonatomic) UIImageView *snapShot;
@property (nonatomic) CGRect frameSnapShot;
@property (nonatomic, assign) UIViewKeyframeAnimationOptions transitionAnimationOption;

@end
