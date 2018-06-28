//
//  ReadingBreakInteractiveTransitioning.h
//  ViewerGridMode
//
//  Created by Son Pham on 6/28/18.
//  Copyright © 2018 ThanhSon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReadingBreakInteractiveTransitioning : UIPercentDrivenInteractiveTransition

@property (nonatomic) BOOL interactionInProgress;
@property (nonatomic) BOOL isPresent;

- (void)attachToViewController:(UIViewController *)viewController withView:(UIView *)view presentViewController:(UIViewController *)presentViewController;

- (void)attachToPresentViewController:(UIViewController *)presentController withView:(UIView *)view;

@end
