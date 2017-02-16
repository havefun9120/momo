//
//  PictureInfo.h
//  MOE
//
//  Created by xiayin on 14-7-16.
//  Copyright (c) 2014年 viewtool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PictureInfo : NSObject
@property(nonatomic,strong)NSString *actual_preview_width;//预览图的尺寸 宽
@property(nonatomic,strong)NSString *actual_preview_height;//预览图的尺寸 高
@property(nonatomic,strong)NSString *preview_url;
@property(nonatomic,strong)UIImage  *preview_url_uiimage;
@property(nonatomic,strong)NSString *jpeg_width;//原图的尺寸 宽
@property(nonatomic,strong)NSString *jpeg_height;//原图的尺寸 高
@property(nonatomic,strong)NSString *jpeg_url;
@property(nonatomic,strong)UIImage  *jpeg_url_uiimage;
@property(nonatomic,strong)NSString *file_size;
@property(nonatomic,strong)NSString *jpeg_file_size;
@property(nonatomic,strong)NSString *post_id;//对应xml的id属性
@property(nonatomic,strong)NSString *is_held;//是否隐藏
@property(nonatomic,strong)NSString *tags;//tag
@property(nonatomic,strong)NSString *rating;//分级:s/q/e
@property(nonatomic,strong)NSString *no_photo;//分级:s/q/e
@end
