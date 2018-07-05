//
//  ReadingBreakPageViewController.m
//  ViewerGridMode
//
//  Created by Son Pham on 6/28/18.
//  Copyright © 2018 ThanhSon. All rights reserved.
//

#import "ReadingBreakPageViewController.h"
#import "ReadingBreakTransition.h"
#import "ReadingBreakPageCell.h"

@interface ReadingBreakPageViewController () <UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;


@end

@implementation ReadingBreakPageViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.clvContent registerNib:[UINib nibWithNibName:@"ReadingBreakPageCell" bundle:nil] forCellWithReuseIdentifier:@"ReadingBreakPageCell"];
    
    [self.clvContent reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButton
     
- (IBAction)didSelectDismissCredits:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark <UICollectionViewFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ReadingBreakPageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ReadingBreakPageCell" forIndexPath:indexPath];
    
    cell.imv.image = [UIImage imageNamed:[NSString stringWithFormat:@"image%ld.jpg",(long)indexPath.row%10]];
    
    return cell;
}

@end
