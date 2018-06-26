//
//  ViewerController.h
//  ViewerGridMode
//
//  Created by Son Pham on 6/22/18.
//  Copyright © 2018 ThanhSon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageViewController.h"
#import "ViewerPageViewController.h"



@class ViewerController;


@interface ViewerController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *btnHorizontol;
@property (nonatomic, weak) IBOutlet UIButton *btnVertical;
@property (nonatomic, weak) IBOutlet UIButton *btnpageCurl;
@property (nonatomic, weak) IBOutlet UIView *topView;

@property (nonatomic, weak) IBOutlet UIView *botView;
@property (nonatomic, weak) IBOutlet UIButton *btnTapOnGrid;

@end
