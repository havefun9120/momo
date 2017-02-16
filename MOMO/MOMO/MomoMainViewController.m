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
    
    
    [self.mUserSetBackgroundPhoto setFramesCount:20];
    [self.mUserSetBackgroundPhoto setBlurAmount:0.4];//雾化程度
    [NSThread detachNewThreadSelector:@selector(Load_XML:)toTarget:self withObject:Nil];//定义一个线程加载xml文件
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
    self.m_data = [[NSMutableData alloc]init];
    NSString *urlString =[NSString stringWithFormat:@"https://yande.re/post.xml?page=%@",sender];
    NSMutableURLRequest *Mu_url_request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    //[urlString release];
    //设置请求方式为get
    [Mu_url_request setHTTPMethod:@"GET"];
    //添加用户会话id
    [Mu_url_request addValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    //连接发送请求
    //finished = false;
    self.conn = [[NSURLConnection alloc] initWithRequest:Mu_url_request delegate:self startImmediately:YES];
    //[conn description]
    NSLog(@"*self.conn = %@",[self.conn description]);
    //堵塞线程，等待结束
    mLoadFinish = NO;
    while(!mLoadFinish) {
        NSLog(@"*!finished");
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}
#pragma mark - NSURLConnectionDelegate & NSURLConnectionDataDelegate
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response{
    NSLog(@"*willSendRequest");
    mfloat_load_url = 0.01;
    NSString *temp = [NSString stringWithFormat:@"%f",mfloat_load_url];
    [self performSelectorOnMainThread:@selector(upDateProgressView:) withObject:temp waitUntilDone:YES];
    return request;
}
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection{
    NSLog(@"*connectionShouldUseCredentialStorage");
    mfloat_load_url++;
    NSString *temp = [NSString stringWithFormat:@"%f",mfloat_load_url];
    [self performSelectorOnMainThread:@selector(upDateProgressView:) withObject:temp waitUntilDone:YES];
    return NO;
}
//下面两段是重点，要服务器端单项HTTPS 验证，iOS 客户端忽略证书验证。
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    NSLog(@"*canAuthenticateAgainstProtectionSpace");
    mfloat_load_url++;
    NSString *temp = [NSString stringWithFormat:@"%f",mfloat_load_url];
    [self performSelectorOnMainThread:@selector(upDateProgressView:) withObject:temp waitUntilDone:YES];
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSLog(@"*didReceiveAuthenticationChallenge");
    mfloat_load_url++;
    NSString *temp = [NSString stringWithFormat:@"%f",mfloat_load_url];
    [self performSelectorOnMainThread:@selector(upDateProgressView:) withObject:temp waitUntilDone:YES];
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        [[challenge sender]  useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        [[challenge sender]  continueWithoutCredentialForAuthenticationChallenge: challenge];
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse*)response{
    NSLog(@"*didReceiveResponse");
    mfloat_load_url++;
    NSString *temp = [NSString stringWithFormat:@"%f",mfloat_load_url];
    [self performSelectorOnMainThread:@selector(upDateProgressView:) withObject:temp waitUntilDone:YES];}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    [self.m_data appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"*connectionDidFinishLoading");
    mfloat_load_url++;
    NSString *temp = [NSString stringWithFormat:@"%f",mfloat_load_url];
    [self performSelectorOnMainThread:@selector(upDateProgressView:) withObject:temp waitUntilDone:YES];
    mLoadFinish = YES;
    NSString * data_Str = [[NSString alloc] initWithData:self.m_data encoding:NSUTF8StringEncoding];
    //NSLog(@"*data_Str = %@", data_Str);
    pictureinfos = [[NSMutableArray alloc]initWithCapacity:3];
    
    [self packageXML2PostDict:data_Str];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError");
}
-(void)packageXML2PostDict:(NSString *)xmlStr{
    _xml_posts = [xmlStr componentsSeparatedByString:@"/>"];
    self.postsDict = [[NSMutableDictionary alloc]init];
    
    self.array4cell = [[NSMutableArray alloc] init];

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
    
    [self download_Images:self.array4cell];
    
    [self.mUserSetBackgroundPhoto setBlurTintColor:[UIColor clearColor]];
    [self.mUserSetBackgroundPhoto generateBlurFramesWithCompletion:^{
        [self.mUserSetBackgroundPhoto blurInAnimationWithDuration:0.25f];
    }];
    
    NSLog(@"------------");
}

-(void)download_Images:(NSMutableArray *)array{
    
    for (NSMutableDictionary *adict in array) {
        for (NSString *key_post_id in [adict allKeys]) {
            [NSThread detachNewThreadSelector:@selector(stratDownload:)toTarget:self withObject:(NSString *)key_post_id];
        }
    }
}

-(void)stratDownload:(NSString *)userinfo{
    
    NSString *post_id = userinfo;
    
    for (int i = 0; i<[self.array4cell count]; i++) {
        NSMutableDictionary *adict = [self.array4cell objectAtIndex:i];
        if ([adict objectForKey:post_id]) {
            PictureInfo *pic_info = [adict objectForKey:post_id];
            pic_info.preview_url_uiimage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:pic_info.preview_url]]];
            
            [adict setObject:pic_info forKey:post_id];
            _int_per++;
            
            NSLog(@"stratDownload id = %@  | %d",post_id,_int_per);
            
            [self performSelectorOnMainThread:@selector(updataUI:) withObject:[NSNumber numberWithInt:_int_per] waitUntilDone:YES];
            
        }
    }
    
}
-(void)updataUI:(NSNumber *)sender{
    NSLog(@"sender count = %f",[sender floatValue]);
    progressView.progress = ([sender floatValue]*(100/([_xml_posts count]-1)))/100.0;
    NSLog(@"progress per = %f",([sender floatValue]*(100/[_xml_posts count])));
    if ([sender floatValue] == ([_xml_posts count]-1)) {
        progressView.progress = 1.0;
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hidden_progressView) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        _int_per = 0;
    }else{
        
    }
    [self.mPictureTable reloadData];
}
-(void)DL_Image:(NSMutableArray *)sender{
    NSMutableArray *mPictureinfosReady = sender;
    float f =100/[mPictureinfosReady count];
    progressView.progress = f;
    for (PictureInfo *pictureInfo in mPictureinfosReady) {
        NSString *ns_preview_url = pictureInfo.preview_url;
        NSLog(@"*:ns_preview_url = %@",ns_preview_url);
        NSURL *ns_url = [NSURL URLWithString:ns_preview_url];
        UIImage *image_preview = [UIImage imageWithData:[NSData dataWithContentsOfURL:ns_url]];
        pictureInfo.preview_url_uiimage = image_preview;
        [pictureinfos addObject:pictureInfo];
        f = f+100/[mPictureinfosReady count];
        NSString *temp = [NSString stringWithFormat:@"%f",f];
        [self performSelectorOnMainThread:@selector(upDateProgressView:) withObject:temp waitUntilDone:YES];
        //[self upDateProgressView:f];
        NSLog(@"%f",f);
    }
}
-(void)upDateProgressView:(NSString *)sender{
    progressView.progress = [sender floatValue]/100;
    if ([sender floatValue]>=100) {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hidden_progressView) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    }
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
//    int i = [indexPath indexAtPosition:0];//Sections
    int rows = (int)[indexPath indexAtPosition:1];//Rows
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    MainTableListCell *cell = (MainTableListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    for (id subview in cell.contentView.subviews){
        [subview removeFromSuperview];
    }
    if (cell == nil) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MainTableListCell" owner:self options:nil];
        cell = [array objectAtIndex:0];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;//关闭cell点击选中的颜色变化
    }
    NSMutableDictionary *pic_info_dict = [self.array4cell objectAtIndex:rows];
    
    
    
    //设置rect
    cell.uiImageViewLeft.frame = CGRectMake(0, 0, [mTool getScreenWidthPix]/3.0, 150);
    cell.uiImageViewMiddle.frame = CGRectMake([mTool getScreenWidthPix]/3.0+1, 0, [mTool getScreenWidthPix]/3.0, 150);
    cell.uiImageViewRight.frame = CGRectMake([mTool getScreenWidthPix]*2/3.0+1, 0, [mTool getScreenWidthPix]/3.0, 150);
    
    
    cell.uiLabelImageSizeLeft.frame = CGRectMake(0, 150-20, [mTool getScreenWidthPix]/3.0, 20);
    cell.uiLabelImageSizeMiddle.frame = CGRectMake([mTool getScreenWidthPix]/3.0+1, 150-20, [mTool getScreenWidthPix]/3.0, 20);
    cell.uiLabelImageSizeRight.frame = CGRectMake([mTool getScreenWidthPix]*2/3.0+1, 150-20, [mTool getScreenWidthPix]/3.0, 20);
    
    
    cell.uiLabelImageIDLeft.frame = CGRectMake(0, 0, [mTool getScreenWidthPix]/3.0, 20);
    cell.uiLabelImageIDMiddle.frame = CGRectMake([mTool getScreenWidthPix]/3.0+1, 0, [mTool getScreenWidthPix]/3.0, 20);
    cell.uiLabelImageIDRight.frame = CGRectMake([mTool getScreenWidthPix]*2/3.0+1, 0, [mTool getScreenWidthPix]/3.0, 20);
    
    //设置内容
    if (pic_info_dict != nil) {
        NSArray *array = [pic_info_dict allValues];
        
        if ([array count]!=1 && [array count]==3) {
            
            
            /*填充   列1*/
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
            
            
            UITapGestureRecognizer *uiimageview_picture_click_left = [[UITapGestureRecognizer alloc] init];//给微缩图的控件容器UIImageView添加手势点击事件
            [uiimageview_picture_click_left addTarget:self action:@selector(imageClick:)];
            //设置事件
            cell.uiImageViewLeft.userInteractionEnabled = YES;//打开手势支持
            [cell.uiImageViewLeft addGestureRecognizer:uiimageview_picture_click_left];
            [cell.uiImageViewLeft setTag:rows*ROW_IN_MAX+ROW_IN_LEFT];
            [cell.uiImageViewLeft setImage:pic_info.preview_url_uiimage];
            cell.uiImageViewLeft.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            [cell.uiLabelImageSizeLeft setText:[NSString stringWithFormat:@"%@ X %@",pic_info.jpeg_width,pic_info.jpeg_height]];
            
            [cell.uiLabelImageIDLeft setText:pic_info.post_id];
            
            
            
            /*填充   列2*/
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
            
            
            
            UITapGestureRecognizer *uiimageview_picture_click_middle = [[UITapGestureRecognizer alloc] init];//给微缩图的控件容器UIImageView添加手势点击事件
            [uiimageview_picture_click_middle addTarget:self action:@selector(imageClick:)];
            //设置事件
            cell.uiImageViewMiddle.userInteractionEnabled = YES;//打开手势支持
            [cell.uiImageViewMiddle addGestureRecognizer:uiimageview_picture_click_middle];
            [cell.uiImageViewMiddle setTag:rows*ROW_IN_MAX+ROW_IN_MIDDLE];
            [cell.uiImageViewMiddle setImage:pic_info.preview_url_uiimage];
            cell.uiImageViewLeft.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            [cell.uiLabelImageSizeMiddle setText:[NSString stringWithFormat:@"%@ X %@",pic_info.jpeg_width,pic_info.jpeg_height]];
            
            
            [cell.uiLabelImageIDMiddle setText:pic_info.post_id];
            
            
            
            /*填充   列3*/
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
            
            
            UITapGestureRecognizer *uiimageview_picture_click_right = [[UITapGestureRecognizer alloc] init];//给微缩图的控件容器UIImageView添加手势点击事件
            [uiimageview_picture_click_right addTarget:self action:@selector(imageClick:)];
            //设置事件
            cell.uiImageViewRight.userInteractionEnabled = YES;//打开手势支持
            [cell.uiImageViewRight addGestureRecognizer:uiimageview_picture_click_right];
            [cell.uiImageViewRight setTag:rows*ROW_IN_MAX+ROW_IN_RIGHT];
            [cell.uiImageViewRight setImage:pic_info.preview_url_uiimage];
            cell.uiImageViewLeft.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            [cell.uiLabelImageSizeRight setText:[NSString stringWithFormat:@"%@ X %@",pic_info.jpeg_width,pic_info.jpeg_height]];
            
            
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
            
            
            
            UITapGestureRecognizer *uiimageview_picture_click_left = [[UITapGestureRecognizer alloc] init];//给微缩图的控件容器UIImageView添加手势点击事件
            [uiimageview_picture_click_left addTarget:self action:@selector(imageClick:)];
            //设置事件
            cell.uiImageViewLeft.userInteractionEnabled = YES;//打开手势支持
            [cell.uiImageViewLeft addGestureRecognizer:uiimageview_picture_click_left];
            [cell.uiImageViewLeft setTag:rows*ROW_IN_MAX+ROW_IN_LEFT];
            [cell.uiImageViewLeft setImage:pic_info.preview_url_uiimage];
            cell.uiImageViewLeft.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            [cell.uiLabelImageSizeLeft setText:[NSString stringWithFormat:@"%@ X %@",pic_info.jpeg_width,pic_info.jpeg_height]];
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
    m_ShowSingeBigPicture.jpeg_url = pic_info.jpeg_url;
    m_ShowSingeBigPicture.file_size = pic_info.file_size;
    m_ShowSingeBigPicture.jpeg_file_size = pic_info.jpeg_file_size;
    m_ShowSingeBigPicture.tags = pic_info.tags;
    [self.navigationController pushViewController:m_ShowSingeBigPicture animated:YES];
}


-(UITableViewCell *)myDefineCell:(UITableViewCell *)myDefineCell
                       withArray:(NSMutableArray *)array//自定义的数组供tableviewcell显示=3in1.
                         withrow:(NSInteger )row{
    for (id subview in myDefineCell.contentView.subviews){
		[subview removeFromSuperview];
	}
    //NSLog(@"*withrow = %d",row);
    NSMutableArray *Singe_NSMutableArray = array;
    /*第一列*/
    int p_w = [[[Singe_NSMutableArray objectAtIndex:0] actual_preview_width] intValue]/2;
    int p_h = [[[Singe_NSMutableArray objectAtIndex:0] actual_preview_height] intValue]/2;
    int i_w = [[[Singe_NSMutableArray objectAtIndex:0] jpeg_width] intValue];
    int i_h = [[[Singe_NSMutableArray objectAtIndex:0] jpeg_height] intValue];
    UILabel *uilable_jpeg_url = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [uilable_jpeg_url setText:[[Singe_NSMutableArray objectAtIndex:0] jpeg_url]];
    //放入原图的URL地址用于传递到下一个界面(不在cell显示)
    UILabel *uilable_file_size = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [uilable_file_size setText:[[Singe_NSMutableArray objectAtIndex:0] file_size]];
    //放入png原图大小用于传递到下一个界面(不在cell显示)
    UILabel *uilable_jpeg_file_size = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [uilable_jpeg_file_size setText:[[Singe_NSMutableArray objectAtIndex:0] jpeg_file_size]];
    //放入jpeg原图大小用于传递到下一个界面(不在cell显示)
    //NSLog(@"*uilable_jpeg_url = %@",uilable_jpeg_url.text);
    NSString *ns_i_w = [NSString stringWithFormat:@"%d",i_w];
    NSString *ns_i_h = [NSString stringWithFormat:@"%d",i_h];
    //NSLog(@"ns_i_w,ns_i_h = %@ X %@",ns_i_w,ns_i_h);
    
    UILabel *uilable_i_w_i_h = [[UILabel alloc]initWithFrame:CGRectMake(0, 150.0-20.0, [mTool getScreenWidthPix]/3.0, 20.0)];
    //在微缩图上显示原图大小信息
    [uilable_i_w_i_h setText:[NSString stringWithFormat:@"%@ X %@",ns_i_w,ns_i_h]];
    //原图大小信息用颜色区分begin
    if (i_w*i_h<=3000000 && i_w*i_h>0) {
        [uilable_i_w_i_h setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.3]];
    }
    if (i_w*i_h<=5000000 && i_w*i_h>3000000) {
        [uilable_i_w_i_h setBackgroundColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.3]];
    }
    if (i_w*i_h<=10000000 && i_w*i_h>5000000) {
        [uilable_i_w_i_h setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.3]];
    }
    //原图大小信息用颜色区分end
    UILabel *lable_tabs = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0,0)];
    [lable_tabs setText:(NSString *)[[Singe_NSMutableArray objectAtIndex:0] tags]];
    //装载图片的tags信息(不显示共传递)
    UIImageView *cell_image;//显示微缩图的控件容器UIImageView
    cell_image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [mTool getScreenWidthPix]/3.0, p_h)];
    cell_image.userInteractionEnabled = YES;//打开手势支持
    cell_image.image = [[Singe_NSMutableArray objectAtIndex:0] preview_url_uiimage];
    cell_image.contentMode =  UIViewContentModeScaleAspectFill;//自适应图片大小
    cell_image.autoresizingMask = UIViewAutoresizingFlexibleWidth;//以宽度为标准
    cell_image.clipsToBounds  = YES;
    UITapGestureRecognizer *uiimageview_into_ori_picture_click = [[UITapGestureRecognizer alloc] init];//给微缩图的控件容器UIImageView添加手势点击事件
    [uiimageview_into_ori_picture_click addTarget:self action:@selector(into_ori_picture:)];
    //设置事件
    [cell_image addGestureRecognizer:uiimageview_into_ori_picture_click];
    //微缩图的控件容器UIImageView加入手势
    uiimageview_into_ori_picture_click.view.tag = row;
    //这个好像没用,空了来确认
    
    [myDefineCell.contentView addSubview:cell_image];
    //cell加入微缩图的控件容器UIImageView
    //[cell_image release];
    [myDefineCell.contentView addSubview:uilable_jpeg_url];
    //cell加入原图的url信息(不显示)
    [myDefineCell.contentView addSubview:uilable_file_size];
    //cell加入png原图的大小信息(不显示)
    [myDefineCell.contentView addSubview:uilable_jpeg_file_size];
    //cell加入jpeg原图的大小信息(不显示)
    //[uilable_jpeg_url release];
    //[uiimageview_into_ori_picture_click release];
    //首次加载uitableview时的判断没有信息就不加载begin
    if (i_h != 0 && i_w != 0) {
        [myDefineCell.contentView addSubview:uilable_i_w_i_h];
        //cell加入原图的大小信息
        //[uilable_i_w_i_h release];
    }
    //首次加载uitableview时的判断没有信息就不加载end
    [myDefineCell.contentView addSubview:lable_tabs];
    /*第二列*/
    if ([Singe_NSMutableArray count]>1) {
        int p_w1 = [[[Singe_NSMutableArray objectAtIndex:1] actual_preview_width] intValue]/2;
        int p_h1 = [[[Singe_NSMutableArray objectAtIndex:1] actual_preview_height] intValue]/2.0;
        int i_w1 = [[[Singe_NSMutableArray objectAtIndex:1] jpeg_width] intValue];
        int i_h1 = [[[Singe_NSMutableArray objectAtIndex:1] jpeg_height] intValue];
        UILabel *uilable_jpeg_url1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        [uilable_jpeg_url1 setText:[[Singe_NSMutableArray objectAtIndex:1] jpeg_url]];
        UILabel *uilable_file_size1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        [uilable_file_size1 setText:[[Singe_NSMutableArray objectAtIndex:1] file_size]];
        UILabel *uilable_jpeg_file_size1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        [uilable_jpeg_file_size1 setText:[[Singe_NSMutableArray objectAtIndex:1] jpeg_file_size]];
        NSString *ns_i_w1 = [NSString stringWithFormat:@"%d",i_w1];
        NSString *ns_i_h1 = [NSString stringWithFormat:@"%d",i_h1];
        UILabel *uilable_i_w_i_h1 = [[UILabel alloc]initWithFrame:CGRectMake([mTool getScreenWidthPix]/3.0+(0.25), 150.0-20, [mTool getScreenWidthPix]/3.0, 20.0)];
        [uilable_i_w_i_h1 setText:[NSString stringWithFormat:@"%@ X %@",ns_i_w1,ns_i_h1]];
        if (i_w1*i_h1<=3000000 && i_w1*i_h1>0) {
            [uilable_i_w_i_h1 setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.3]];
        }
        if (i_w1*i_h1<=5000000 && i_w1*i_h1>3000000) {
            [uilable_i_w_i_h1 setBackgroundColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.3]];
        }
        if (i_w1*i_h1<=10000000 && i_w1*i_h1>5000000) {
            [uilable_i_w_i_h1 setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.3]];
        }
        UILabel *lable_tabs1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0,0)];
        [lable_tabs1 setText:(NSString *)[[Singe_NSMutableArray objectAtIndex:1] tags]];
        UIImageView *cell_image1;
        cell_image1 = [[UIImageView alloc]initWithFrame:CGRectMake([mTool getScreenWidthPix]/3.0+(0.25), 0, [mTool getScreenWidthPix]/3.0, p_h1)];
        cell_image1.userInteractionEnabled = YES;
        cell_image1.image = [[Singe_NSMutableArray objectAtIndex:1] preview_url_uiimage];
        cell_image1.contentMode =  UIViewContentModeScaleAspectFill;
        cell_image1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        cell_image1.clipsToBounds  = YES;
        UITapGestureRecognizer *uiimageview_into_ori_picture_click1 = [[UITapGestureRecognizer alloc] init];
        [uiimageview_into_ori_picture_click1 addTarget:self action:@selector(into_ori_picture1:)];
        [cell_image1 addGestureRecognizer:uiimageview_into_ori_picture_click1];
        uiimageview_into_ori_picture_click1.view.tag = row;
        [myDefineCell.contentView addSubview:cell_image1];
        [myDefineCell.contentView addSubview:uilable_jpeg_url1];
        [myDefineCell.contentView addSubview:uilable_file_size1];
        [myDefineCell.contentView addSubview:uilable_jpeg_file_size1];
        if (i_h1 != 0 && i_w1 != 0) {
            [myDefineCell.contentView addSubview:uilable_i_w_i_h1];
        }
        [myDefineCell.contentView addSubview:lable_tabs1];
    }
    /*第三列*/
    if ([Singe_NSMutableArray count]>2) {
        int p_w2 = [[[Singe_NSMutableArray objectAtIndex:2] actual_preview_width] intValue]/2;
        int p_h2 = [[[Singe_NSMutableArray objectAtIndex:2] actual_preview_height] intValue]/2.0;
        int i_w2 = [[[Singe_NSMutableArray objectAtIndex:2] jpeg_width] intValue];
        int i_h2 = [[[Singe_NSMutableArray objectAtIndex:2] jpeg_height] intValue];
        UILabel *uilable_jpeg_url2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        [uilable_jpeg_url2 setText:[[Singe_NSMutableArray objectAtIndex:2] jpeg_url]];
        UILabel *uilable_file_size2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        [uilable_file_size2 setText:[[Singe_NSMutableArray objectAtIndex:2] file_size]];
        UILabel *uilable_jpeg_file_size2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        [uilable_jpeg_file_size2 setText:[[Singe_NSMutableArray objectAtIndex:2] jpeg_file_size]];
        NSString *ns_i_w2 = [NSString stringWithFormat:@"%d",i_w2];
        NSString *ns_i_h2 = [NSString stringWithFormat:@"%d",i_h2];
        //NSLog(@"ns_i_w,ns_i_h = %@ X %@",ns_i_w2,ns_i_h2);
        UILabel *uilable_i_w_i_h2 = [[UILabel alloc]initWithFrame:CGRectMake([mTool getScreenWidthPix]*2.0/3.0+1.0, 150.0-20.0, [mTool getScreenWidthPix]/3.0, 20.0)];
        [uilable_i_w_i_h2 setText:[NSString stringWithFormat:@"%@ X %@",ns_i_w2,ns_i_h2]];
        if (i_w2*i_h2<=3000000 && i_w2*i_h2>0) {
            [uilable_i_w_i_h2 setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.3]];
        }
        if (i_w2*i_h2<=5000000 && i_w2*i_h2>3000000) {
            [uilable_i_w_i_h2 setBackgroundColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.3]];
        }
        if (i_w2*i_h2<=10000000 && i_w2*i_h2>5000000) {
            [uilable_i_w_i_h2 setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.3]];
        }
        UILabel *lable_tabs2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0,0)];
        [lable_tabs2 setText:(NSString *)[[Singe_NSMutableArray objectAtIndex:2] tags]];
        UIImageView *cell_image2;
        cell_image2 = [[UIImageView alloc]initWithFrame:CGRectMake([mTool getScreenWidthPix]*2.0/3.0+1.0, 0, [mTool getScreenWidthPix]/3.0, p_h2)];
        cell_image2.userInteractionEnabled = YES;
        cell_image2.image = [[Singe_NSMutableArray objectAtIndex:2] preview_url_uiimage];
        //cell_image.tag = 1;
        cell_image2.contentMode =  UIViewContentModeScaleAspectFill;
        cell_image2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        cell_image2.clipsToBounds  = YES;
        UITapGestureRecognizer *uiimageview_into_ori_picture_click2 = [[UITapGestureRecognizer alloc] init];
        [uiimageview_into_ori_picture_click2 addTarget:self action:@selector(into_ori_picture2:)];
        [cell_image2 addGestureRecognizer:uiimageview_into_ori_picture_click2];
        uiimageview_into_ori_picture_click2.view.tag = row;
        [myDefineCell.contentView addSubview:cell_image2];
        //[cell_image2 release];
        [myDefineCell.contentView addSubview:uilable_jpeg_url2];
        [myDefineCell.contentView addSubview:uilable_file_size2];
        [myDefineCell.contentView addSubview:uilable_jpeg_file_size2];
        //[uilable_jpeg_url2 release];
        //[uiimageview_into_ori_picture_click2 release];
        if (i_h2 != 0 && i_w2 != 0) {
            [myDefineCell.contentView addSubview:uilable_i_w_i_h2];
            //[uilable_i_w_i_h2 release];
        }
        [myDefineCell.contentView addSubview:lable_tabs2];
    }
    [[Singe_NSMutableArray objectAtIndex:0] preview_url];
    [[Singe_NSMutableArray objectAtIndex:0] preview_url_uiimage];
    [[Singe_NSMutableArray objectAtIndex:0] jpeg_url];
    [[Singe_NSMutableArray objectAtIndex:0] jpeg_url_uiimage];
    [[[Singe_NSMutableArray objectAtIndex:0] post_id] intValue];
    [[Singe_NSMutableArray objectAtIndex:0] is_held];
    
    return myDefineCell;
}
#pragma mark - function
-(void)into_ori_picture:(id)sender{
    NSLog(@"into_ori_picture");
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    ShowSingeBigPicture *m_ShowSingeBigPicture = [[ShowSingeBigPicture alloc]init];
    m_ShowSingeBigPicture.smallImageView = (UIImageView *)[[[tap.view superview] subviews] objectAtIndex:0];
    m_ShowSingeBigPicture.jpeg_url = [(UILabel *)[[[tap.view superview] subviews] objectAtIndex:1] text];
    m_ShowSingeBigPicture.file_size =[(UILabel *)[[[tap.view superview] subviews] objectAtIndex:2] text];
    m_ShowSingeBigPicture.jpeg_file_size =[(UILabel *)[[[tap.view superview] subviews] objectAtIndex:3] text];
    m_ShowSingeBigPicture.jpeg_w_h_size =[(UILabel *)[[[tap.view superview] subviews] objectAtIndex:4] text];
    m_ShowSingeBigPicture.tags =[(UILabel *)[[[tap.view superview] subviews] objectAtIndex:5] text];
    //[self presentViewController:m_ShowSingeBigPicture animated:YES completion:nil];
    [self.navigationController pushViewController:m_ShowSingeBigPicture animated:YES];
    //[m_ShowSingeBigPicture release];
}
-(void)into_ori_picture1:(id)sender{
    NSLog(@"into_ori_picture1");
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;

    ShowSingeBigPicture *m_ShowSingeBigPicture = [[ShowSingeBigPicture alloc]init];
    m_ShowSingeBigPicture.smallImageView = (UIImageView *)[[[tap.view superview] subviews] objectAtIndex:6];
    m_ShowSingeBigPicture.jpeg_url = [(UILabel *)[[[tap.view superview] subviews] objectAtIndex:7] text];
    m_ShowSingeBigPicture.file_size =[(UILabel *)[[[tap.view superview] subviews] objectAtIndex:8] text];
    m_ShowSingeBigPicture.jpeg_file_size =[(UILabel *)[[[tap.view superview] subviews] objectAtIndex:9] text];
    m_ShowSingeBigPicture.jpeg_w_h_size =[(UILabel *)[[[tap.view superview] subviews] objectAtIndex:10] text];
    m_ShowSingeBigPicture.tags =[(UILabel *)[[[tap.view superview] subviews] objectAtIndex:11] text];
    //[self presentViewController:m_ShowSingeBigPicture animated:YES completion:nil];
    [self.navigationController pushViewController:m_ShowSingeBigPicture animated:YES];
    //[m_ShowSingeBigPicture release];
}
-(void)into_ori_picture2:(id)sender{
    NSLog(@"into_ori_picture2");
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    //UIImageView *view = (UIImageView *)tap.view;
    ShowSingeBigPicture *m_ShowSingeBigPicture = [[ShowSingeBigPicture alloc]init];
    m_ShowSingeBigPicture.smallImageView = (UIImageView *)[[[tap.view superview] subviews] objectAtIndex:12];
    m_ShowSingeBigPicture.jpeg_url = [(UILabel *)[[[tap.view superview] subviews] objectAtIndex:13] text];
    m_ShowSingeBigPicture.file_size =[(UILabel *)[[[tap.view superview] subviews] objectAtIndex:14] text];
    m_ShowSingeBigPicture.jpeg_file_size =[(UILabel *)[[[tap.view superview] subviews] objectAtIndex:15] text];
    m_ShowSingeBigPicture.jpeg_w_h_size =[(UILabel *)[[[tap.view superview] subviews] objectAtIndex:16] text];
    m_ShowSingeBigPicture.tags =[(UILabel *)[[[tap.view superview] subviews] objectAtIndex:17] text];
    //[self presentViewController:m_ShowSingeBigPicture animated:YES completion:nil];
    [self.navigationController pushViewController:m_ShowSingeBigPicture animated:YES];
    //[m_ShowSingeBigPicture release];
}
-(void)hidden_progressView{
    [progressView setHidden:YES];
}
- (IBAction)beforePage:(id)sender {
    [progressView setHidden:NO];
    progressView.progress = 0;
    if (post_page != 1) {
        post_page--;
        NSLog(@"*post_page = %d",post_page);
        NSString *ns_post_page = [NSString stringWithFormat:@"%d",post_page];
        [NSThread detachNewThreadSelector:@selector(Load_XML:)toTarget:self withObject:ns_post_page];
    }else{
        NSLog(@"*已经是第一页了");
        post_page = 1;
        NSString *ns_post_page = [NSString stringWithFormat:@"%d",post_page];
        [NSThread detachNewThreadSelector:@selector(Load_XML:)toTarget:self withObject:ns_post_page];
    }
}

- (IBAction)nextPage:(id)sender {
    [progressView setHidden:NO];
    progressView.progress = 0;
    post_page++;
    NSLog(@"*post_page = %d",post_page);
    NSString *ns_post_page = [NSString stringWithFormat:@"%d",post_page];
    [NSThread detachNewThreadSelector:@selector(Load_XML:)toTarget:self withObject:ns_post_page];
}
@end
