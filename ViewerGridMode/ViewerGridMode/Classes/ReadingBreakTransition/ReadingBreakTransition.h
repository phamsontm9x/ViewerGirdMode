//
//  ReadingBreakTransition.h
//  ViewerGridMode
//
//  Created by Son Pham on 6/28/18.
//  Copyright © 2018 ThanhSon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIkit.h"



@protocol ReadingBreakTransitionProtocol <NSObject>;

- (UIImageView *)getImageViewPresentWithTransition;
- (UIImageView *)getImageViewDismissWithTransition;

@end



@interface ReadingBreakTransition : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic) CGFloat duration;
@property (nonatomic, assign) BOOL isPresent;
@property (nonatomic, assign) BOOL enabledInteractive;

@end
