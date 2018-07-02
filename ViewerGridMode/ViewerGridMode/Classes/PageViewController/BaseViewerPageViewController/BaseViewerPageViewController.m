//
//  BaseViewerPageViewController.m
//  ViewerGridMode
//
//  Created by Son Pham on 7/2/18.
//  Copyright © 2018 ThanhSon. All rights reserved.
//

#import "BaseViewerPageViewController.h"

@interface BaseViewerPageViewController ()

@end

@implementation BaseViewerPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didTapOnGirdMode {

}

#pragma mark - ViewerCollectionViewDelegate

- (void)viewerPageViewControllerDelegate:(BaseViewerPageViewController *)vc clv:(ViewerCollectionView*)clv jumpToViewControllerAtIndex:(NSInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewerPageViewController:clv:jumpToViewControllerAtIndex:)]) {
        [self.delegate viewerPageViewController:vc clv:clv jumpToViewControllerAtIndex:index];
    }
}

@end
