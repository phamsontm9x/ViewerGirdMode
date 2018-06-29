//
//  ReadingBreakController.h
//  ViewerGridMode
//
//  Created by Son Pham on 6/28/18.
//  Copyright © 2018 ThanhSon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewerCollectionView.h"

@interface ReadingBreakController : UIViewController

@property (nonatomic) NSInteger indexPath;
@property (nonatomic, strong) ViewerCollectionView<ViewerTransitionProtocol> *vcPresent;

- (void)didTapOnGirdMode;

@end
