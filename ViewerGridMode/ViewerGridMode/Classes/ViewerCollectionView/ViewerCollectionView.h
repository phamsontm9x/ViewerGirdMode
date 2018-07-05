//
//  ViewerCollectionView.h
//  ViewerGridMode
//
//  Created by Son Pham on 6/18/18.
//  Copyright © 2018 Son Pham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewerInteractiveTransitioning.h"


@class ViewerCollectionView;

@protocol ViewerCollectionViewDelegate <NSObject>

- (void)viewerCollectionView:(ViewerCollectionView *)vc DismissViewController:(NSInteger)index;

@end



@interface ViewerCollectionView : UICollectionViewController

@property (nonatomic, weak) id<ViewerCollectionViewDelegate> delegate;
@property (nonatomic, strong) ViewerInteractiveTransitioning *interactiveTransition;

@property (nonatomic) NSIndexPath *currentIndexPath;
@property (nonatomic) NSInteger totalItems;
@property (nonatomic) BOOL isProcessingTransition;
@property (nonatomic) BOOL isProcessingInteractiveTransition;

- (CGRect)getFrameCellWithIndexPath:(NSIndexPath *)indexPath;


@end
