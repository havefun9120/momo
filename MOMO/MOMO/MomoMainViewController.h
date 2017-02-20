//
//  MomoMainViewController.h
//  MOMO
//
//  Created by xiayin on 15-4-20.
//  Copyright (c) 2015年 xiayin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureInfo.h"
#import "PICircularProgressView.h"
#import "Tool.h"
#import "ANBlurredImageView.h"
#import "ShowSingeBigPicture.h"

#import "MainTableListCell.h"


#import "opFile.h"
#import "MyConn.h"



typedef enum
{
    ROW_IN_LEFT,
    ROW_IN_MIDDLE,
    ROW_IN_RIGHT,
    ROW_IN_MAX,//3
}enumIdxTagInRow;

@interface MomoMainViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    BOOL mLoadFinish;
    Tool *mTool;
    PICircularProgressView *progressView;
    NSMutableArray *pictureinfos;//照片对象集合
    PictureInfo *pictureinfo;//照片对象
    NSMutableArray *mMuArrayForCell;
    CALayer *loadingLayer;
    float mfloat_load_url;
    UIButton *mNavigationRightBtn;
    
    BOOL stratDownloadThreadFlag;
    
    NSString *ns_post_page;
    
    NSMutableArray *_threads;
}
@property (strong) IBOutlet ANBlurredImageView *mUserSetBackgroundPhoto;
- (IBAction)beforePage:(id)sender;
- (IBAction)nextPage:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *mPictureTable;
@property (strong, nonatomic) NSURLConnection *conn;
@property (strong, nonatomic) NSMutableData *m_data;


@property (nonatomic,strong) NSArray *xml_posts;
@property (nonatomic,strong) NSString *posts_all_count;
@property (strong, nonatomic) NSMutableDictionary *postsDict;
@property (strong, nonatomic) NSMutableArray *array4cell;
@property int int_per;
@property (strong, nonatomic) NSMutableDictionary *dict1;
@property (strong, nonatomic) NSMutableDictionary *dict2;
@property (strong, nonatomic) NSMutableDictionary *dict3;
@property (strong, nonatomic) NSMutableDictionary *dict4;
@property (strong, nonatomic) NSMutableDictionary *dict5;
@property (strong, nonatomic) NSMutableDictionary *dict6;

@property CGRect oldImageCgrect;

/** 存储线程*/

@property(nonatomic,strong) NSMutableArray * threadArray;

@property int countThreads;

@end
