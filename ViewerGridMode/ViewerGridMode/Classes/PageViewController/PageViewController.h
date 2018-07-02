//
//  PageViewController.h
//  ViewerGridMode
//
//  Created by Son Pham on 6/18/18.
//  Copyright © 2018 Son Pham. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BaseViewerPageViewController;

@interface PageViewController : UIPageViewController

@property (nonatomic) NSInteger index;
@property (nonatomic) BaseViewerPageViewController *currentVC;

- (void)initData;
- (void)didTapOnGirdMode;
- (NSInteger)getIndexViewController;

@end
