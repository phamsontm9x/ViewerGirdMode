//
//  ViewerTransition.h
//  ViewerGridMode
//
//  Created by Son Pham on 6/18/18.
//  Copyright © 2018 Son Pham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>



typedef NS_ENUM(NSInteger, ViewerTransitionMode) {
    ViewerTransitionModePage = 0,
    ViewerTransitionModeAds,
    ViewerTransitionModeCollection,
};

@protocol ViewerTransitionProtocol <NSObject>;

- (UIImageView *)getImageViewPresent;
- (UIImageView *)getImageViewPresentWithInteractive;

@end



@interface ViewerTransition : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) BOOL isPresent;
@property (nonatomic, assign) BOOL enabledInteractive;
@property (nonatomic) CGRect fromViewDefault;
@property (nonatomic) CGRect toViewDefault;
@property (nonatomic) UIImageView *snapShot;
@property (nonatomic) CGRect frameSnapShot;

@property (nonatomic) ViewerTransitionMode transitionMode;

@end
