//
//  MomoMainViewController.m
//  MOMO
//
//  Created by xiayin on 15-4-20.
//  Copyright (c) 2015年 xiayin. All rights reserved.
//

#import "MomoMainViewController.h"

@interface MomoMainViewController ()


@end

@implementation MomoMainViewController
int post_page = 1;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self registerNotifications];
        stratDownloadThreadFlag = YES;
        self.title = @"全部";
        mNavigationRightBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        mNavigationRightBtn.frame = CGRectMake(0, 0, 40, 40);
        [mNavigationRightBtn setTitle:@"搜索" forState:UIControlStateNormal];
        progressView = [[PICircularProgressView alloc] initWithFrame:CGRectMake(0,0, 30, 30)];
        UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:progressView];
        self.navigationItem.rightBarButtonItem = menuButton;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    [self createTagCacheFileWithFileName:strTagCacheFileName withType:strTagCacheFileType];
    
    mTool = [[Tool alloc]init];
    
    mfloat_load_url = 0.01;
    
    [self.mUserSetBackgroundPhoto setFramesCount:20];
    [self.mUserSetBackgroundPhoto setBlurAmount:0.4];//雾化程度
    
    [NSThread detachNewThreadSelector:@selector(Load_XML:)toTarget:self withObject:Nil];//定义一个线程加载xml文件
    
}

-(void)registerNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnReceivingRsp:) name: kDidReceiving object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnFinishLoadingRsp:) name: kDidFinishLoading object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnFailConnectionRsp:) name: kDidFailConnection object:nil];
    
}

-(void)didConnReceivingRsp:(NSNotification *)noti{
    mfloat_load_url++;
    NSString *temp = [NSString stringWithFormat:@"%f",mfloat_load_url];
//    [self upDateProgressView:temp];
    [self performSelectorOnMainThread:@selector(upDateProgressView:) withObject:temp waitUntilDone:YES];
}

-(void)didConnFinishLoadingRsp:(NSNotification *)noti{
    stratDownloadThreadFlag = YES;
    
    mfloat_load_url = 100.0;
    NSString *temp = [NSString stringWithFormat:@"%f",mfloat_load_url];
//    [self upDateProgressView:temp];
    [self performSelectorOnMainThread:@selector(upDateProgressView:) withObject:temp waitUntilDone:YES];
    
    if ([noti.object isKindOfClass:[NSMutableData class]]) {
        NSString * data_Str = [[NSString alloc] initWithData:noti.object encoding:NSUTF8StringEncoding];
        
        pictureinfos = [[NSMutableArray alloc]initWithCapacity:3];
        
        [self packageXML2PostDict:data_Str];
    }
}

-(void)didConnFailConnectionRsp:(NSNotification *)noti{
    NSLog(@"error : %@",(NSError *)noti.object);
    [self updateUI4ConnError:(NSError *)noti.object];
    
}

#pragma mark - init fuctions
-(void)createTagCacheFileWithFileName:(NSString *)fileName withType:(NSString *)fileType{
    NSString *filePath = [opFile createFile:fileName withType:fileType];
    NSLog(@"createTagCacheFilePath :%@",filePath);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)Load_XML:(id)sender{
    NSLog(@"*Load_XML");
    NSString *urlString =[NSString stringWithFormat:@"%@%@",BASE_POST_URL,sender];
    NSMutableURLRequest *Mu_url_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    
    [Mu_url_request setHTTPMethod:@"GET"];
    
    [Mu_url_request addValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    
    [[MyConn sharedInstance] pubInitWithRequest:Mu_url_request startImmediately:YES];
    
    [NSThread exit];
}

-(void)packageXML2PostDict:(NSString *)xmlStr{
    _xml_posts = [xmlStr componentsSeparatedByString:@"/>"];
    self.postsDict = [[NSMutableDictionary alloc]init];
    
    if (!self.array4cell) {
        self.array4cell = [[NSMutableArray alloc] init];
    }else{
        [self.array4cell removeAllObjects];
    }
    
    for (int i =0; i<[_xml_posts count]-1; i++) {
        pictureinfo = [[PictureInfo alloc]init];
        NSString *xml_post = [_xml_posts objectAtIndex:i];
        pictureinfo.actual_preview_width = [[[[xml_post componentsSeparatedByString:@"actual_preview_width=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
        pictureinfo.actual_preview_height = [[[[xml_post componentsSeparatedByString:@"actual_preview_height=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
        pictureinfo.preview_url = [[[[xml_post componentsSeparatedByString:@"preview_url=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
        pictureinfo.jpeg_width = [[[[xml_post componentsSeparatedByString:@"jpeg_width=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
        pictureinfo.jpeg_height = [[[[xml_post componentsSeparatedByString:@"jpeg_height=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
        pictureinfo.jpeg_url = [[[[xml_post componentsSeparatedByString:@"jpeg_url=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
        pictureinfo.file_size = [[[[xml_post componentsSeparatedByString:@"file_size=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
        pictureinfo.jpeg_file_size = [[[[xml_post componentsSeparatedByString:@"jpeg_file_size=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
        pictureinfo.post_id = [[[[xml_post componentsSeparatedByString:@"id=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
        pictureinfo.is_held = [[[[xml_post componentsSeparatedByString:@"is_held=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
        pictureinfo.tags = [[[[xml_post componentsSeparatedByString:@"tags=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
        pictureinfo.rating = [[[[xml_post componentsSeparatedByString:@"rating=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
        
        pictureinfo.sample_url = [[[[xml_post componentsSeparatedByString:@"sample_url=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
        pictureinfo.sample_width = [[[[xml_post componentsSeparatedByString:@"sample_width=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
        pictureinfo.sample_height = [[[[xml_post componentsSeparatedByString:@"sample_height=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
        pictureinfo.sample_file_size = [[[[xml_post componentsSeparatedByString:@"sample_file_size=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
        if (i%3==0) {
            if (i!=0) {
                [self.array4cell addObject:_dict1];
            }
            _dict1 = [[NSMutableDictionary alloc]init];
            [_dict1 setObject:pictureinfo forKey:pictureinfo.post_id];
            
        }else{
            [_dict1 setObject:pictureinfo forKey:pictureinfo.post_id];
            
        }
        
    }
    _int_per = 0;
    
    [self.array4cell addObject:_dict1];
    
//    [self download_Images:self.array4cell];
    [self stratMutableDownload:self.array4cell];
    
    
    [self.mUserSetBackgroundPhoto setBlurTintColor:[UIColor clearColor]];
    [self.mUserSetBackgroundPhoto generateBlurFramesWithCompletion:^{
        [self.mUserSetBackgroundPhoto blurInAnimationWithDuration:0.25f];
    }];
    
    NSLog(@"------------");
}



-(void)download_Images:(NSMutableArray *)array{
    
    [NSThread detachNewThreadSelector:@selector(stratDownload:)toTarget:self withObject:array];
    
}

-(void)stratDownload:(NSArray *)array{
    for (NSMutableDictionary *adict in array) {
        for (NSString *key_post_id in [adict allKeys]) {
            
            if ([adict objectForKey:key_post_id]){
                PictureInfo *pic_info = [adict objectForKey:key_post_id];
                pic_info.preview_url_uiimage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:pic_info.preview_url]]];
                
                [adict setObject:pic_info forKey:key_post_id];
                _int_per++;
                
                [self performSelectorOnMainThread:@selector(updataUI:) withObject:[NSString stringWithFormat:@"%d",_int_per] waitUntilDone:YES];
                
                if (stratDownloadThreadFlag == NO) {
                    NSLog(@"*NSThread exit");
                    [NSThread exit];
                }
            }
            
        }
    }
    [NSThread exit];
}

-(void)stratMutableDownload:(NSArray *)array{
    _threads=[NSMutableArray arrayWithCapacity:1];
    for (NSMutableDictionary *adict in array) {
        for (NSString *key_post_id in [adict allKeys]) {
            
            if ([adict objectForKey:key_post_id]){
                NSThread *thread=[[NSThread alloc]initWithTarget:self selector:@selector(loadAImage:) object:key_post_id];
                [_threads addObject:thread];
            }
            
        }
    }
    //循环启动线程
    for (int i=0; i<[_threads count]; ++i) {
        NSThread *thread= _threads[i];
        [thread start];
    }
}

#pragma mark 加载图片
-(void)loadAImage:(NSString *)index{
    NSData *imageData ;
    for (NSMutableDictionary *adict in self.array4cell) {
        for (NSString *key_post_id in [adict allKeys]) {
            
            if ([key_post_id isEqualToString:index]){
                
                PictureInfo *pic_info = [adict objectForKey:index];
                
//                pic_info.preview_url_uiimage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:pic_info.preview_url]]];
                
                imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:pic_info.preview_url]];
                
                
            }
            
        }
    }
    
    NSThread *currentThread=[NSThread currentThread];
    
    //    如果当前线程处于取消状态，则退出当前线程
    if (currentThread.isCancelled) {
        NSLog(@"thread(%@) will be cancelled!",currentThread);
        [NSThread exit];//取消当前线程
    }
    
    NSMutableDictionary *aDictData = [[NSMutableDictionary alloc]init];
    if (imageData == nil) {
        [self performSelectorOnMainThread:@selector(updataUIImage:) withObject:nil waitUntilDone:YES];
        [NSThread exit];
    }
    [aDictData setObject:imageData forKey:index];
    
    [self performSelectorOnMainThread:@selector(updataUIImage:) withObject:aDictData waitUntilDone:YES];
}

-(void)updataUIImage:(id)sender{
    NSMutableDictionary *aDict = sender;
    NSString *index = [[aDict allKeys] objectAtIndex:0];
    NSData *data = [[aDict allValues] objectAtIndex:0];
    for (NSMutableDictionary *adict in self.array4cell) {
        for (NSString *key_post_id in [adict allKeys]) {
            
            if ([key_post_id isEqualToString:index]){
                PictureInfo *pic_info = [adict objectForKey:key_post_id];
                pic_info.preview_url_uiimage = [UIImage imageWithData:data];
                
                [adict setObject:pic_info forKey:key_post_id];
                _int_per++;
                [self show_progressView];
                NSLog(@"%f",(float)_int_per / ([_xml_posts count]-1));
                progressView.progress = (float)_int_per / ([_xml_posts count]-1);
                
                if (_int_per == ([_xml_posts count]-1)) {
                    
                    progressView.progress = 1.0;
                    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hidden_progressView) userInfo:nil repeats:NO];
                    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
                    _int_per = 0;
                }
                
                [self.mPictureTable reloadData];
            }
            
        }
    }
}

-(void)updataUI:(NSNumber *)sender{
    NSLog(@"sender count = %f",[sender floatValue]);
    
    [self show_progressView];
    
    progressView.progress = ([sender floatValue] / ([_xml_posts count]-1));
    
    NSLog(@"progress per = %f",([sender floatValue] / ([_xml_posts count]-1)));
    if ([sender floatValue] == ([_xml_posts count]-1)) {
        
        progressView.progress = 1.0;
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hidden_progressView) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        _int_per = 0;
    }else{
        
    }
    [self.mPictureTable reloadData];
}

-(void)updateUI4ConnError:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@",[error description]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)upDateProgressView:(NSString *)sender{
    [self show_progressView];
    progressView.progress = [sender floatValue]/100;
    
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.array4cell != nil) {
        return [self.array4cell count];
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 150;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    int rows = (int)[indexPath indexAtPosition:1];//Rows
    
    MainTableListCell *cell = (MainTableListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    for (id subview in cell.contentView.subviews){
        [subview removeFromSuperview];
    }
    if (cell == nil) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MainTableListCell" owner:self options:nil];
        cell = [array objectAtIndex:0];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSMutableDictionary *pic_info_dict = [self.array4cell objectAtIndex:rows];
    
    if (pic_info_dict != nil) {
        NSArray *array = [pic_info_dict allValues];
        
        if ([array count]!=1 && [array count]==3) {
            
            PictureInfo *pic_info = [array objectAtIndex:0];
            
            if (([pic_info.jpeg_height intValue]<=2500 && [pic_info.jpeg_height intValue]>0)||([pic_info.jpeg_width intValue]<=2500 && [pic_info.jpeg_width intValue]>0)) {
                [cell.uiLabelImageSizeLeft setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.3]];
            }
            if (([pic_info.jpeg_height intValue]<=5500 && [pic_info.jpeg_height intValue]>2500)||([pic_info.jpeg_width intValue]<=5500 && [pic_info.jpeg_width intValue]>2500)) {
                [cell.uiLabelImageSizeLeft setBackgroundColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.3]];
            }
            if (([pic_info.jpeg_height intValue]>5500)||([pic_info.jpeg_width intValue]>5500)) {
                [cell.uiLabelImageSizeLeft setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.3]];
            }
            
            UITapGestureRecognizer *uiimageview_picture_click_left = [[UITapGestureRecognizer alloc] init];
            
            [uiimageview_picture_click_left addTarget:self action:@selector(imageClick:)];
            
            cell.uiImageViewLeft.userInteractionEnabled = YES;//打开手势支持
            [cell.uiImageViewLeft addGestureRecognizer:uiimageview_picture_click_left];
            [cell.uiImageViewLeft setTag:rows*ROW_IN_MAX+ROW_IN_LEFT];
            [cell.uiImageViewLeft setImage:pic_info.preview_url_uiimage];
            cell.uiImageViewLeft.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            [cell.uiLabelImageSizeLeft setText:[NSString stringWithFormat:@"%@ x %@",pic_info.jpeg_width,pic_info.jpeg_height]];
            
            [cell.uiLabelImageIDLeft setText:pic_info.post_id];
            
            pic_info = [array objectAtIndex:1];
            if (([pic_info.jpeg_height intValue]<=2500 && [pic_info.jpeg_height intValue]>0)||([pic_info.jpeg_width intValue]<=2500 && [pic_info.jpeg_width intValue]>0)) {
                [cell.uiLabelImageSizeMiddle setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.3]];
            }
            if (([pic_info.jpeg_height intValue]<=5500 && [pic_info.jpeg_height intValue]>2500)||([pic_info.jpeg_width intValue]<=5500 && [pic_info.jpeg_width intValue]>2500)) {
                [cell.uiLabelImageSizeMiddle setBackgroundColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.3]];
            }
            if (([pic_info.jpeg_height intValue]>5500)||([pic_info.jpeg_width intValue]>5500)) {
                [cell.uiLabelImageSizeMiddle setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.3]];
            }
            
            UITapGestureRecognizer *uiimageview_picture_click_middle = [[UITapGestureRecognizer alloc] init];
            
            [uiimageview_picture_click_middle addTarget:self action:@selector(imageClick:)];
           
            cell.uiImageViewMiddle.userInteractionEnabled = YES;//打开手势支持
            [cell.uiImageViewMiddle addGestureRecognizer:uiimageview_picture_click_middle];
            [cell.uiImageViewMiddle setTag:rows*ROW_IN_MAX+ROW_IN_MIDDLE];
            [cell.uiImageViewMiddle setImage:pic_info.preview_url_uiimage];
            cell.uiImageViewLeft.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            [cell.uiLabelImageSizeMiddle setText:[NSString stringWithFormat:@"%@ x %@",pic_info.jpeg_width,pic_info.jpeg_height]];
            
            [cell.uiLabelImageIDMiddle setText:pic_info.post_id];
            
            pic_info = [array objectAtIndex:2];
            if (([pic_info.jpeg_height intValue]<=2500 && [pic_info.jpeg_height intValue]>0)||([pic_info.jpeg_width intValue]<=2500 && [pic_info.jpeg_width intValue]>0)) {
                [cell.uiLabelImageSizeRight setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.3]];
            }
            if (([pic_info.jpeg_height intValue]<=5500 && [pic_info.jpeg_height intValue]>2500)||([pic_info.jpeg_width intValue]<=5500 && [pic_info.jpeg_width intValue]>2500)) {
                [cell.uiLabelImageSizeRight setBackgroundColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.3]];
            }
            if (([pic_info.jpeg_height intValue]>5500)||([pic_info.jpeg_width intValue]>5500)) {
                [cell.uiLabelImageSizeRight setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.3]];
            }
            
            UITapGestureRecognizer *uiimageview_picture_click_right = [[UITapGestureRecognizer alloc] init];
            [uiimageview_picture_click_right addTarget:self action:@selector(imageClick:)];
            
            cell.uiImageViewRight.userInteractionEnabled = YES;
            [cell.uiImageViewRight addGestureRecognizer:uiimageview_picture_click_right];
            [cell.uiImageViewRight setTag:rows*ROW_IN_MAX+ROW_IN_RIGHT];
            [cell.uiImageViewRight setImage:pic_info.preview_url_uiimage];
            cell.uiImageViewLeft.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            [cell.uiLabelImageSizeRight setText:[NSString stringWithFormat:@"%@ x %@",pic_info.jpeg_width,pic_info.jpeg_height]];
            
            [cell.uiLabelImageIDRight setText:pic_info.post_id];
            
        }
        if ([array count]==1) {
            PictureInfo *pic_info = [array objectAtIndex:0];
            if (([pic_info.jpeg_height intValue]<=2500 && [pic_info.jpeg_height intValue]>0)||([pic_info.jpeg_width intValue]<=2500 && [pic_info.jpeg_width intValue]>0)) {
                [cell.uiLabelImageSizeLeft setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.3]];
            }
            if (([pic_info.jpeg_height intValue]<=5500 && [pic_info.jpeg_height intValue]>2500)||([pic_info.jpeg_width intValue]<=5500 && [pic_info.jpeg_width intValue]>2500)) {
                [cell.uiLabelImageSizeLeft setBackgroundColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.3]];
            }
            if (([pic_info.jpeg_height intValue]>5500)||([pic_info.jpeg_width intValue]>5500)) {
                [cell.uiLabelImageSizeLeft setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.3]];
            }
            
            UITapGestureRecognizer *uiimageview_picture_click_left = [[UITapGestureRecognizer alloc] init];
            [uiimageview_picture_click_left addTarget:self action:@selector(imageClick:)];
            
            cell.uiImageViewLeft.userInteractionEnabled = YES;
            [cell.uiImageViewLeft addGestureRecognizer:uiimageview_picture_click_left];
            [cell.uiImageViewLeft setTag:rows*ROW_IN_MAX+ROW_IN_LEFT];
            [cell.uiImageViewLeft setImage:pic_info.preview_url_uiimage];
            cell.uiImageViewLeft.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            [cell.uiLabelImageSizeLeft setText:[NSString stringWithFormat:@"%@ x %@",pic_info.jpeg_width,pic_info.jpeg_height]];
            [cell.uiImageViewMiddle setImage:nil];
            [cell.uiImageViewRight setImage:nil];
            
            [cell.uiLabelImageIDLeft setText:pic_info.post_id];
            
        }
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int rows = (int)[indexPath indexAtPosition:1];//Rows
    NSLog(@"rows = %d",rows);
}

-(void)imageClick:(id)sender{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    UIImageView *image = (UIImageView *)tap.view;
    int rowIdx =(int)(image.tag)/ROW_IN_MAX;
    int colIdx =(int)(image.tag)%ROW_IN_MAX;
    NSLog(@"xxx row = %d",rowIdx);
    NSLog(@"xxx col = %d",colIdx);
    NSMutableDictionary *pic_info_dict = [self.array4cell objectAtIndex:rowIdx];
    NSArray *array = [pic_info_dict allValues];
    PictureInfo *pic_info = [array objectAtIndex:colIdx];
    
    ShowSingeBigPicture *m_ShowSingeBigPicture = [[ShowSingeBigPicture alloc]init];
    m_ShowSingeBigPicture.smallImageView = [[UIImageView alloc]initWithImage:pic_info.preview_url_uiimage];
    m_ShowSingeBigPicture.jpeg_url = pic_info.sample_url;
    m_ShowSingeBigPicture.file_size = pic_info.file_size;
    m_ShowSingeBigPicture.jpeg_file_size = pic_info.sample_file_size;
    m_ShowSingeBigPicture.tags = pic_info.tags;
    [self.navigationController pushViewController:m_ShowSingeBigPicture animated:YES];
}

-(void)hidden_progressView{
    [progressView setHidden:YES];
}
-(void)show_progressView{
    [progressView setHidden:NO];
}

- (IBAction)beforePage:(id)sender {
    [self stopLoadImage];
    mfloat_load_url = 0.01;
    
    _int_per = 0;
    
    [progressView setHidden:NO];
    progressView.progress = 0;
    if (post_page != 1) {
        post_page--;
        NSLog(@"*post_page = %d",post_page);
        ns_post_page = [NSString stringWithFormat:@"%d",post_page];
        
        [NSThread detachNewThreadSelector:@selector(Load_XML:)toTarget:self withObject:ns_post_page];
        
        
        
    }else{
        NSLog(@"*已经是第一页了");
        post_page = 1;
        ns_post_page = [NSString stringWithFormat:@"%d",post_page];
        
        [NSThread detachNewThreadSelector:@selector(Load_XML:)toTarget:self withObject:ns_post_page];
       
        
    }
}

- (IBAction)nextPage:(id)sender {
    [self stopLoadImage];
#if 0
    mfloat_load_url = 0.01;
    
    _int_per = 0;
    
    [progressView setHidden:NO];
    progressView.progress = 0;
    post_page++;
    NSLog(@"*post_page = %d",post_page);
    ns_post_page = [NSString stringWithFormat:@"%d",post_page];
    
    [NSThread detachNewThreadSelector:@selector(Load_XML:)toTarget:self withObject:ns_post_page];
#endif
}
#pragma mark 停止加载图片
-(void)stopLoadImage{
    for (int i=0; i<[_threads count]; i++) {
        NSThread *thread= _threads[i];
        //判断线程是否完成，如果没有完成则设置为取消状态
        //注意设置为取消状态仅仅是改变了线程状态而言，并不能终止线程
        if (!thread.isFinished) {
            [thread cancel];
            
        }
    }
}
@end
