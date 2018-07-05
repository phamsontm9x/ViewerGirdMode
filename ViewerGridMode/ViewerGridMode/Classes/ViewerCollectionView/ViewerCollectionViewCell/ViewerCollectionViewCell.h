//
//  ViewerCollectionViewCell.h
//  ViewerGridMode
//
//  Created by Son Pham on 6/18/18.
//  Copyright © 2018 Son Pham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewerCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imv;
@property (nonatomic, weak) IBOutlet UIView *imvBg;
@property (nonatomic, weak) IBOutlet UILabel *lblNumberOfPage;

@end
