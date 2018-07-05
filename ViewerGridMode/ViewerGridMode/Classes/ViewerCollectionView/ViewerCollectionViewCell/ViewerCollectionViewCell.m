//
//  ViewerCollectionViewCell.m
//  ViewerGridMode
//
//  Created by Son Pham on 6/18/18.
//  Copyright © 2018 Son Pham. All rights reserved.
//

#import "ViewerCollectionViewCell.h"

@implementation ViewerCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imvBg.layer.borderWidth = 1;
    self.imvBg.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

@end
