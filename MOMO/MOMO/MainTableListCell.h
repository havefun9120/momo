//
//  MainTableListCell.h
//  MOMO
//
//  Created by xiayin on 16/4/30.
//  Copyright © 2016年 xiayin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTableListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *uiImageViewLeft;
@property (weak, nonatomic) IBOutlet UIImageView *uiImageViewMiddle;
@property (weak, nonatomic) IBOutlet UIImageView *uiImageViewRight;
@property (weak, nonatomic) IBOutlet UILabel *uiLabelImageSizeLeft;
@property (weak, nonatomic) IBOutlet UILabel *uiLabelImageSizeMiddle;
@property (weak, nonatomic) IBOutlet UILabel *uiLabelImageSizeRight;
@property (weak, nonatomic) IBOutlet UILabel *uiLabelImageIDLeft;
@property (weak, nonatomic) IBOutlet UILabel *uiLabelImageIDMiddle;
@property (weak, nonatomic) IBOutlet UILabel *uiLabelImageIDRight;

@end
