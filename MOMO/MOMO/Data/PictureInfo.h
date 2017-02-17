//
//  PictureInfo.h
//  MOE
//
//  Created by xiayin on 14-7-16.
//  Copyright (c) 2014年 viewtool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PictureInfo : NSObject
@property(nonatomic,strong)NSString *preview_url;/*lv:1 pic*/
@property(nonatomic,strong)UIImage  *preview_url_uiimage;
@property(nonatomic,strong)NSString *actual_preview_width;
@property(nonatomic,strong)NSString *actual_preview_height;

@property(nonatomic,strong)NSString *sample_url;/*lv:2 pic*/
@property(nonatomic,strong)NSString *sample_width;
@property(nonatomic,strong)NSString *sample_height;
@property(nonatomic,strong)NSString *sample_file_size;
@property(nonatomic,strong)UIImage  *sample_url_uiimage;

@property(nonatomic,strong)NSString *jpeg_width;/*lv:3 pic*/
@property(nonatomic,strong)NSString *jpeg_height;
@property(nonatomic,strong)NSString *jpeg_url;
@property(nonatomic,strong)UIImage  *jpeg_url_uiimage;
@property(nonatomic,strong)NSString *jpeg_file_size;

@property(nonatomic,strong)NSString *file_size;/*max lv:4 pic*/
@property(nonatomic,strong)NSString *file_ext;
@property(nonatomic,strong)NSString *file_url;
@property(nonatomic,strong)UIImage  *file_url_uiimage;

@property(nonatomic,strong)NSString *post_id;//对应xml的id属性
@property(nonatomic,strong)NSString *is_held;//是否隐藏
@property(nonatomic,strong)NSString *tags;//tag
@property(nonatomic,strong)NSString *rating;//分级:s/q/e


@end
