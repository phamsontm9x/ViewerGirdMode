//
//  ReadingBreakController.h
//  ViewerGridMode
//
//  Created by Son Pham on 6/28/18.
//  Copyright © 2018 ThanhSon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewerCollectionView.h"



@class ReadingBreakController;

@protocol ReadingBreakControllerDelegate <NSObject>

- (void)readingBreakController:(ReadingBreakController *)vc clv:(ViewerCollectionView*)clv jumpToViewControllerAtIndex:(NSInteger)index;

@end


@interface ReadingBreakController : UIViewController

@property (nonatomic) NSInteger indexPath;
@property (nonatomic) CGPoint contentOffSetClv;
@property (nonatomic, strong) ViewerCollectionView<ViewerTransitionProtocol> *vcPresent;
@property (nonatomic, weak) id<ReadingBreakControllerDelegate> delegate;

- (void)didTapOnGirdMode;

@end
