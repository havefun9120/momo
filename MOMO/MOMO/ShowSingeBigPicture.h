//
//  ShowSingeBigPicture.h
//  MOE
//
//  Created by xiayin on 14-7-19.
//  Copyright (c) 2014年 viewtool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Tool.h"

#import <AssetsLibrary/ALAsset.h>

#import <AssetsLibrary/ALAssetsLibrary.h>

#import <AssetsLibrary/ALAssetsGroup.h>

#import <AssetsLibrary/ALAssetRepresentation.h>






#import "ANBlurredImageView.h"
//#import "SearchTags.h"
//#import "ViewController.h"

#import "TagInfo.h"
#import "opFile.h"

#define TabBarItem_More_Tag   0
#define TabBarItem_Favo_Tag_UnSelect   0
#define TabBarItem_Favo_Tag_Selected   1
@interface ShowSingeBigPicture : UIViewController<NSURLConnectionDelegate,NSURLConnectionDataDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>{
    UIActivityIndicatorView *mProgressIndicatorView;
    UILabel *mShowPer;
    Tool *mTool;
    
    BOOL finished;
    NSString *filePath;
    NSURLConnection *connt;
    
    CGRect oldFrame;    //保存图片原来的大小
    CGRect largeFrame;  //确定图片放大最大的程度
    CGPoint center;     //保存图片中心位置
    
    UIButton *mBtn_Back_To_Posts_List;
    UIButton *mBtn_Save_To_Photo;
    UIImageView *uiimageview_foot_view;
    UIView *uiview_BigPicture_detail;
    UIButton *mBtn_Show_Detail;
    
    NSMutableArray *mMu_Array_Tags;
    NSString *length;//test
    UITableView *mTableViewTabs_List;
    float table_cell_h;
    float table_cell_w;
    float tableview_h;
    float tableview_w;
    
    BOOL tapClicks;
    
    
    TagInfo *tagInfo;
}
@property (nonatomic,strong) UIImageView *smallImageView;

@property (nonatomic,strong) NSString *jpeg_url;
@property (nonatomic,strong) NSString *file_size;
@property (nonatomic,strong) NSString *jpeg_file_size;
@property (nonatomic,strong) NSString *jpeg_w_h_size;
@property (nonatomic,strong) NSString *tags;
@property (strong,nonatomic) UIImage *uiimage;
@property (strong,nonatomic) UIImageView *uiimageview;
@property (weak, nonatomic) IBOutlet UIScrollView *imageviewScroll;
@property (weak, nonatomic) IBOutlet ANBlurredImageView *imageViewBlurredBG;
@property (strong,nonatomic) UIImageView *uiimageviewloading;

@property(nonatomic,strong)NSMutableData *fileData;
@property(nonatomic,strong)NSFileHandle *writeHandle;
@property(nonatomic,assign)long long currentLength;
@property(nonatomic,assign)long long sumLength;
@property(strong,nonatomic)UIProgressView *progress;
@property(strong,nonatomic)NSData *picture_data;
@property(atomic,strong)NSString *validTagName;
@property(atomic,strong)NSMutableDictionary *aMutDictTagsInfo;
@property(atomic,strong)NSString *cacheTagFileFullNamePath;




@property CGRect oldScrollRect;
@property CGFloat scale;
@property CGPoint centerPoint;

@property (weak, nonatomic) IBOutlet UIButton *favoritesBtn;
- (IBAction)addFavorites:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
- (IBAction)showMoreInfo:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *zoomBtn;
- (IBAction)zoomFitImage:(id)sender;

@property(strong,nonatomic) NSMutableData *tag_data;
@property int tagIndex;

@end
