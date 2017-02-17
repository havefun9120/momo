//
//  ShowSingeBigPicture.m
//  MOE
//
//  Created by xiayin on 14-7-19.
//  Copyright (c) 2014年 viewtool. All rights reserved.
//

#import "ShowSingeBigPicture.h"

@implementation ShowSingeBigPicture
@synthesize
jpeg_url,
file_size,
jpeg_file_size,
tags,
uiimage,
uiimageview,
uiimageviewloading,
fileData,
writeHandle,
currentLength,
sumLength,
progress,
picture_data;
- (id)init{
    
    if (self) {
        // Initialization code
        UIView *navBarCusView = [[UIView alloc]initWithFrame:CGRectMake(0,0, 40, 40)];
        mProgressIndicatorView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        [mProgressIndicatorView setColor:[UIColor grayColor]];
        mBtn_Save_To_Photo = [UIButton buttonWithType:UIButtonTypeCustom];
        mBtn_Save_To_Photo.frame = CGRectMake(0, 0, 40, 40);
        [mBtn_Save_To_Photo setBackgroundImage:[UIImage imageNamed:@"save3.png"] forState:UIControlStateNormal];
        //[mBtn_Save_To_Photo setTitle:@"保存到相册" forState:UIControlStateNormal];
        [mBtn_Save_To_Photo setTag:0];
        [mBtn_Save_To_Photo addTarget:self action:@selector(Save_To_Photo:) forControlEvents:UIControlEventTouchUpInside];
        [navBarCusView addSubview:mBtn_Save_To_Photo];
        [navBarCusView addSubview:mProgressIndicatorView];
        UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:navBarCusView];
        self.navigationItem.rightBarButtonItem = menuButton;
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"*ShowSingeBigPicture_viewWillAppear");
}
- (void)viewDidLoad{
    [super viewDidLoad];
    NSLog(@"*ShowSingeBigPicture_viewDidLoad");
    [self.view setUserInteractionEnabled:YES];
    
    mTool = [[Tool alloc]init];
    mMu_Array_Tags = [[NSMutableArray alloc]initWithCapacity:1];
    mMu_Array_Tags = [self parse_get_tags:self.tags];
    
    [self initTagOperat];
    
    [self.view setBackgroundColor:[UIColor grayColor]];

    [self initLoadingView];
    
    NSString *filename = [self parse_get_filename:self.jpeg_url];
    self.title = [[filename componentsSeparatedByString:@"."] objectAtIndex:0];
    NSString *cachePath = [self checkPicCacheWithCacheFileName:filename];
    if (cachePath) {
        self.uiimage = [[UIImage alloc]initWithContentsOfFile:cachePath];
    }
    self.uiimageview = [[UIImageView alloc]initWithImage:self.uiimage];
    
    UITapGestureRecognizer *uiimageview_picture_double_click = [[UITapGestureRecognizer alloc] init];//给微缩图的控件容器UIImageView添加手势点击事件
    [uiimageview_picture_double_click addTarget:self action:@selector(handleDoubleTap:)];
    [uiimageview_picture_double_click setNumberOfTapsRequired:2];
    
    //设置事件
    self.uiimageview.userInteractionEnabled = YES;//打开手势支持
    [self.uiimageview addGestureRecognizer:uiimageview_picture_double_click];
    
    
    [self initImageviewScroll];
    
    if (self.uiimage == nil) {
        NSLog(@"jpeg_url = %@",self.jpeg_url);
        NSLog(@"没有下载过");
        [self star:self.jpeg_url];
    }else if(self.uiimage != nil){
        NSLog(@"下载过");
        if(([self.file_size longLongValue] == [self fileSizeAtPath:cachePath])||([self.jpeg_file_size longLongValue] == [self fileSizeAtPath:cachePath])){
            [self hiddenLoadingView];
            
            [self loadImageviewScrollWithImage:self.uiimage];
            
        }else{
            NSLog(@"但没有下载完全的");
            [self star:self.jpeg_url];
            return;
        }
    }
    
    
}
-(void)initTagOperat{
    self.tagIndex = 0;
    self.aMutDictTagsInfo = [[NSMutableDictionary alloc]init];
    self.cacheTagFileFullNamePath = [opFile getFilePath:strTagCacheFileFullName];
    NSMutableDictionary *cacheTagDict = [[NSMutableDictionary alloc]initWithContentsOfFile:self.cacheTagFileFullNamePath];
    if ([cacheTagDict count] > 0) {
        int i_count_tag_num = 0;
        for (NSString *key in [cacheTagDict allKeys]) {
            for (int i = 0; i<[mMu_Array_Tags count]; i++) {
                NSString *tag = [mMu_Array_Tags objectAtIndex:i];
                if ([key isEqualToString:tag]) {
                    i_count_tag_num = i_count_tag_num+1;
                }
            }
        }
        NSLog(@"");
        if (i_count_tag_num == [mMu_Array_Tags count]) {
            NSLog(@"存在tag匹配的缓存");
        }else{
            NSLog(@"tag的缓存存在但是不匹配");
            [self starGetTagWithUrl:BASE_TAG_URL withTagName:[mMu_Array_Tags objectAtIndex:self.tagIndex]];
        }
    }else{
        [self starGetTagWithUrl:BASE_TAG_URL withTagName:[mMu_Array_Tags objectAtIndex:self.tagIndex]];
    }
    
    
}
-(void)doImageViewBlurredWithImage:(UIImage *)image{
    [self.imageViewBlurredBG setBaseImage:image];
    [self.imageViewBlurredBG setFramesCount:20];
    [self.imageViewBlurredBG setBlurAmount:0.4];//雾化程度
    [self.imageViewBlurredBG setBlurTintColor:[UIColor clearColor]];
    // Recalculate normal blur without tint.
    [self.imageViewBlurredBG generateBlurFramesWithCompletion:^{
        
        [self.imageViewBlurredBG blurInAnimationWithDuration:0.25f];
        
    }];
}


#pragma mark - Zoom methods


- (void)handleDoubleTap:(UIGestureRecognizer *)gesture
{
    
    float newScale;
#if 1
    if (!tapClicks) {
        newScale = self.imageviewScroll.zoomScale *2.0;
    }
    else{
        newScale = self.imageviewScroll.zoomScale *1.0;
    }
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
    [self.imageviewScroll zoomToRect:zoomRect animated:YES];
    tapClicks = !tapClicks;
#endif
    
}

#pragma mark - CommonMethods
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center1
{
    CGRect zoomRect;
    zoomRect.size.height =self.imageviewScroll.frame.size.height / scale;
    zoomRect.size.width  =self.imageviewScroll.frame.size.width  / scale;
    zoomRect.origin.x = center1.x - (zoomRect.size.width  /2.0);
    zoomRect.origin.y = center1.y - (zoomRect.size.height /2.0);
    return zoomRect;
}


-(void)initImageviewScroll{
    
    self.imageviewScroll.delegate = self;
    
    self.centerPoint = self.imageviewScroll.center;
    
    _oldScrollRect = self.imageviewScroll.frame;
    //设置最大伸缩比例
    self.imageviewScroll.maximumZoomScale=5.0;
    //设置最小伸缩比例
    self.imageviewScroll.minimumZoomScale=0.1;
}
-(void)loadImageviewScrollWithImage:(UIImage *)image{
//    [self.view setBackgroundColor:[UIColor colorWithPatternImage:image]];
//    [self.view setContentMode:UIViewContentModeScaleAspectFill];
    
    [self matchWidthOrHeight:image.size];
    
    [self.uiimageview setContentMode:UIViewContentModeScaleAspectFit];
    [self.imageviewScroll addSubview:self.uiimageview];
    
}
-(void)initLoadingView{
    [self doImageViewBlurredWithImage:self.smallImageView.image];
    self.progress = [[UIProgressView alloc]initWithFrame:CGRectMake(([mTool getScreenWidthPix]-187)/2, ([mTool getScreenheightPix]-72)/2,187,20)];
    mShowPer = [[UILabel alloc]initWithFrame:CGRectMake(([mTool getScreenWidthPix]-40)/2, ([mTool getScreenheightPix]-82)/2-5, 40, 20)];
    [mShowPer setHidden:NO];
    [mShowPer setBackgroundColor:[UIColor clearColor]];
    self.uiimageviewloading = [[UIImageView alloc]initWithFrame:CGRectMake(([mTool getScreenWidthPix]-187)/2, ([mTool getScreenheightPix]-72)/2, 187, 72)];
    self.uiimageviewloading.image = [UIImage imageNamed:@"moe_time_out.png"];
    
    
    
    
    [self.view addSubview:self.uiimageviewloading];
    [self.view addSubview:self.progress];
    [self.view addSubview:mShowPer];
}
-(void)hiddenLoadingView{
    [mShowPer setHidden:YES];
    [self.progress setHidden:YES];
    [self.uiimageviewloading setHidden:YES];
}
-(NSString *)checkPicCacheWithCacheFileName:(NSString *)name{
    NSArray *cache = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cache objectAtIndex:0];
    cachePath = [cachePath stringByAppendingString:[NSString stringWithFormat:@"/%@",name]];
    NSLog(@"*cachePath = %@",cachePath);
    return cachePath;
}
-(void)matchCenter{
    UIView *subView = [self.imageviewScroll.subviews objectAtIndex:0];
    
//    CGFloat offsetX = MAX((self.imageviewScroll.bounds.size.width - self.imageviewScroll.contentSize.width) * 0.5, 0.0);
    
    CGFloat offsetY = MAX((self.imageviewScroll.bounds.size.height - self.imageviewScroll.contentSize.height) * 0.5, 0.0);
    
    subView.center = CGPointMake(self.imageviewScroll.contentSize.width,self.imageviewScroll.contentSize.height * 0.5 + offsetY);
}
-(void)matchWidthOrHeight:(CGSize)size {//size是原图的

    // 重置UIImageView的Frame，让图片居中显示
    
    
    CGFloat a_width = self.imageviewScroll.frame.size.width;
    CGFloat a_height = self.imageviewScroll.frame.size.width*size.height/size.width;
    
    CGFloat a_Y = (_oldScrollRect.size.height-a_height)/2.0;
    if (a_Y<=0) {
        a_Y = 0;
    }
    
    self.uiimageview.frame = CGRectMake(_oldScrollRect.origin.x,
                                        a_Y,
                                        a_width,
                                        a_height);
    
    
    CGSize maxSize = self.imageviewScroll.frame.size;
    
    CGFloat widthRatio = maxSize.width/size.width;
    
    CGFloat heightRatio = maxSize.height/size.height;
    
    CGFloat initialZoom = (widthRatio > heightRatio) ? heightRatio : widthRatio;
    
    self.imageviewScroll.minimumZoomScale=initialZoom;
    [self.imageviewScroll setZoomScale:1.0];
    
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"scrollViewDidScroll : %@",scrollView.description);
    self.centerPoint = scrollView.contentOffset;
}


-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView//告诉scrollview要缩放的是哪个子控件
{
    return self.uiimageview;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale{
    
    CGFloat zs = scrollView.zoomScale;
    zs = MAX(zs, 0.1);
    zs = MIN(zs, 5.0);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    scrollView.zoomScale = zs;
    [UIView commitAnimations];
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
    UIImageView *imageView = [[scrollView subviews] objectAtIndex:0];
    CGFloat a_width = scrollView.frame.size.width;
    CGFloat a_height = scrollView.frame.size.width*imageView.frame.size.height/imageView.frame.size.width;
    NSLog(@"a_width = %f",a_width);
    NSLog(@"a_height = %f",a_height);
    //NSLog(@"atScale = %f",scale);
    NSLog(@"zoomScale = %f",[scrollView zoomScale]);
    NSLog(@"contentSize = width:%f , height:%f",[scrollView contentSize].width,[scrollView contentSize].height);
    NSLog(@"self uiimage size = width:%f , height:%f",self.uiimage.size.width,self.uiimage.size.height);
    CGFloat a_Y = (_oldScrollRect.size.height-scrollView.contentSize.height)/2;
    if (a_Y<=0) {
        a_Y = 0;
    }
    self.uiimageview.frame = CGRectMake(_oldScrollRect.origin.x,
                                        a_Y,
                                        scrollView.contentSize.width,
                                        scrollView.contentSize.height);
    NSLog(@" y = %f",(_oldScrollRect.size.height-scrollView.contentSize.height)/2);
    if (scrollView.zoomScale <= 1.0) {
        [scrollView setZoomScale:1.0];
        
    }
    if (scrollView.zoomScale >= 1.0 && scrollView.zoomScale < 4.0) {
        [self.zoomBtn setImage:[UIImage imageNamed:@"zoom_in.png"] forState:UIControlStateNormal];
    }else{
        [self.zoomBtn setImage:[UIImage imageNamed:@"fit.png"] forState:UIControlStateNormal];
    }
}


- (void)star:(id)sender{
    NSString *stringurl = (NSString *)sender;
    NSURL *url=[NSURL URLWithString:[stringurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //创建一个请求
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15] ;
    //发送请求（使用代理的方式）
    connt=[NSURLConnection connectionWithRequest:request delegate:self];
    [connt start];
}


- (void)starGetTagWithUrl:(id)tag_baseurl withTagName:(id)name{
    self.tag_data = [[NSMutableData alloc]init];
    self.validTagName = name;
    NSString *stringurl = [NSString stringWithFormat:@"%@?name=%@",(NSString *)tag_baseurl,self.validTagName];
    NSURL *url=[NSURL URLWithString:[stringurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //创建一个请求
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15] ;
    //发送请求（使用代理的方式）
    connt=[NSURLConnection connectionWithRequest:request delegate:self];
    [connt start];
}


-(void)Save_To_Photo:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (btn.tag==1) {
        [self jump_to_pickerImage];
    }
    if (btn.tag==0) {
        [mProgressIndicatorView startAnimating];
        UIImageWriteToSavedPhotosAlbum(self.uiimage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if(error != NULL){
        NSLog(@"图片保存失败 error = %@",error);
    }else{
        [mProgressIndicatorView stopAnimating];
        NSLog(@"图片保存成功");
        [mBtn_Save_To_Photo setTag:1];
        [self jump_to_pickerImage];
    }
}
-(void)jump_to_pickerImage{
    UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pickerImage.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerImage.sourceType];
        
    }
    pickerImage.delegate = self;
    pickerImage.allowsEditing = NO;
    [self presentViewController:pickerImage animated:YES completion:nil];
}

/*
 *当接收到服务器的响应（连通了服务器）时会调用
 */
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSURLRequest *ori_Request = connection.originalRequest;
    if ([[ori_Request.URL absoluteString] rangeOfString:BASE_TAG_URL].length>0) {
        
    }else{
        //0.得到文件名
        NSString *filename = [self parse_get_filename:self.jpeg_url];
        //1.创建文件存储路径
        NSString *caches=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        filePath=[caches stringByAppendingPathComponent:filename];
        //2.创建一个空的文件,到沙盒中
        NSFileManager *mgr=[NSFileManager defaultManager];
        //刚创建完毕的大小是0字节
        [mgr createFileAtPath:filePath contents:nil attributes:nil];
        //3.创建写数据的文件句柄
        self.writeHandle=[NSFileHandle fileHandleForWritingAtPath:filePath];
        //4.获取完整的文件的长度
        self.sumLength=response.expectedContentLength;
        NSLog(@"*获取完整的文件的长度 = %d",(int)self.sumLength);
        [self.file_size longLongValue];
        NSLog(@"*[self.file_size longLongValue] = %lld",[self.file_size longLongValue]);
        NSLog(@"*[self.jpeg_file_size longLongValue] = %lld",[self.jpeg_file_size longLongValue]);
    }
    
}

/*
 *当接收到服务器的数据时会调用（可能会被调用多次，每次只传递部分数据）
 */
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSURLRequest *ori_Request = connection.originalRequest;
    if ([[ori_Request.URL absoluteString] rangeOfString:BASE_TAG_URL].length>0) {
        [self.tag_data appendData:data];
    }else{
        //累加接收到的数据
        self.currentLength+=data.length;
        //计算当前进度(转换为double型的)
        double d = (double)(self.currentLength*100.00/self.sumLength);
        [mShowPer setText:[NSString stringWithFormat:@"%.0f",d]];
        [mShowPer setTextColor:[UIColor blackColor]];
        double _progress = (double)self.currentLength/self.sumLength;
        self.progress.progress = _progress;
        //一点一点接收数据。
        NSLog(@"接收到服务器的数据！---%lu",(unsigned long)data.length);
        //把data写入到创建的空文件中，但是不能使用writeTofile(会覆盖)
        //移动到文件的尾部
        [self.writeHandle seekToEndOfFile];
        //从当前移动的位置，写入数据
        [self.writeHandle writeData:data];
    }
    

}

/*
 *当服务器的数据加载完毕时就会调用
 */
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSURLRequest *ori_Request = connection.originalRequest;
    if ([[ori_Request.URL absoluteString] rangeOfString:BASE_TAG_URL].length>0) {
        NSString * data_Str = [[NSString alloc] initWithData:self.tag_data encoding:NSUTF8StringEncoding];
        //NSLog(@"\ndata_Str = \n%@",data_Str);
        [self parseTagXml:data_Str findValidTagName:self.validTagName withConnection:connection];
        
        
    }else{
        NSLog(@"下载图片完毕");
        
        
        NSString *filename = [self parse_get_filename:self.jpeg_url];
        NSString *cachePath = [self checkPicCacheWithCacheFileName:filename];
        NSLog(@"*cachePath = %@",cachePath);
        self.uiimage = [[UIImage alloc]initWithContentsOfFile:cachePath];
        
        [self hiddenLoadingView];
        
        self.uiimageview.image = self.uiimage;
        
        [self loadImageviewScrollWithImage:self.uiimage];
        
        
        
        
        //关闭连接，不再输入数据在文件中
        [self.writeHandle closeFile];
        //销毁
        self.writeHandle=nil;
        //在下载完毕后，对进度进行清空
        self.currentLength=0;
        self.sumLength=0;
        [connection cancel];
    }
    
    
}
/*
 *请求错误（失败）的时候调用（请求超时\断网\没有网\，一般指客户端错误）
 */
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    UILabel *uilable_time_out = [[UILabel alloc]initWithFrame:CGRectMake(([mTool getScreenWidthPix]-187)/2, ([mTool getScreenheightPix]-72)/2+72, 187, 20)];
    [uilable_time_out setText:@"下载服务器可能便当了"];
    [uilable_time_out setBackgroundColor:[UIColor clearColor]];
    [uilable_time_out setTextColor:[UIColor redColor]];
    [uilable_time_out setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:uilable_time_out];
    [connection cancel];
    //[uilable_time_out release];
}
/*
 解析url得到以id为基础的文件名
 sender : (nsstring)url
 */
-(NSString *)parse_get_filename:(id)sender{
    NSString *filename;
    if ([[sender componentsSeparatedByString:@"%20"] count] > 1) {
        filename = [[sender componentsSeparatedByString:@"%20"] objectAtIndex:1];
        
        filename = [filename stringByAppendingString:[NSString stringWithFormat:@".%@",[[[[self.jpeg_url componentsSeparatedByString:@"%20"] objectAtIndex:[[self.jpeg_url componentsSeparatedByString:@"%20"] count]-1] componentsSeparatedByString:@"."] objectAtIndex:1]]];
    }else {
        filename = [[sender componentsSeparatedByString:@" "] objectAtIndex:1];
        
        filename = [filename stringByAppendingString:[NSString stringWithFormat:@".%@",[[[[self.jpeg_url componentsSeparatedByString:@" "] objectAtIndex:[[self.jpeg_url componentsSeparatedByString:@" "] count]-1] componentsSeparatedByString:@"."] objectAtIndex:1]]];
    }
    
    NSLog(@"*parse_get_filename = %@",filename);
    return filename;
    
}
-(void)parseTagXml:(id)sender
  findValidTagName:(NSString *)validTagName
    withConnection:(NSURLConnection *)connection{
    NSString *strDataXml = (NSString *)sender;
    NSArray *xml_Tags = [strDataXml componentsSeparatedByString:@"/>"];
    //NSLog(@"*xml_posts = %lu",(unsigned long)[xml_Tags count]);
    
    for (int i =0; i<[xml_Tags count]-1; i++) {
        NSString *xml_Tag = [xml_Tags objectAtIndex:i];
        NSString *name = [[[[xml_Tag componentsSeparatedByString:@"name=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
        NSLog(@"查找有效tag name :%@ 中...",validTagName);
        if ([name isEqualToString:validTagName]) {
            NSLog(@"找到有效tag name :%@",validTagName);
            tagInfo = [[TagInfo alloc]init];
            tagInfo.tag_ID = [[[[xml_Tag componentsSeparatedByString:@"id=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
            tagInfo.name = [[[[xml_Tag componentsSeparatedByString:@"name=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
            tagInfo.count = [[[[xml_Tag componentsSeparatedByString:@"count=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
            [self.aMutDictTagsInfo setObject:tagInfo.count forKey:validTagName];
            
            self.tagIndex = self.tagIndex+1;
            NSLog(@"self.tagIndex = %d",self.tagIndex);
            if (self.tagIndex<[mMu_Array_Tags count]) {
                [self starGetTagWithUrl:BASE_TAG_URL withTagName:[mMu_Array_Tags objectAtIndex:self.tagIndex]];
                return;
            }else{
                NSLog(@"下载Tags信息   完毕");
                for (NSString *key in [self.aMutDictTagsInfo allKeys]) {
                    NSLog(@"aMutDictTagsInfo \nKEY=%@ ,count = %@",key,[self.aMutDictTagsInfo objectForKey:key]);
                }
                [opFile updateObjectIntoFile:self.cacheTagFileFullNamePath withObjData:self.aMutDictTagsInfo];
            }
        }
    }
    [connection cancel];
}
/*
 解析url得到以tags
 sender : (nsstring)url
 */
-(NSMutableArray *)parse_get_tags:(id)sender{
    NSMutableArray *mu_array_tags = [[NSMutableArray alloc]initWithCapacity:1];
    NSArray *array_tags = [sender componentsSeparatedByString:@" "];
    int old_i = 0;
    int new_i = 0;
    for (int i = 0; i < [array_tags count]; i++) {
        new_i = (int)[array_tags[i] length];
        if (new_i>old_i) {
            old_i = new_i;
        }
        length = [NSString stringWithFormat:@"%d",old_i];
        [mu_array_tags addObject:array_tags[i]];
        
    }
    //NSLog(@"*zuichangzuichang = %@",length);
    return mu_array_tags;
    
}
//单个文件的大小
- (long long) fileSizeAtPath:(NSString *)myfilePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:myfilePath]){
        return [[manager attributesOfItemAtPath:myfilePath error:nil] fileSize];
    }
    return 0;
}


//uitableview/////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *uilable_tags = [[UILabel alloc]init];
    switch (section) {
        case 0:
            [uilable_tags setText:@"Tags:  "];
            [uilable_tags setTextColor:[UIColor blueColor]];
            [uilable_tags setTextAlignment:NSTextAlignmentRight];
            return uilable_tags;
            break;
        default:
            break;
    }
    return uilable_tags;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if ([mMu_Array_Tags count] != 0) {
        return [mMu_Array_Tags count];
    }else{
        return 1;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 25;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;//关闭cell点击选中的颜色变化
    }
    if ([mMu_Array_Tags count] > 0) {
        return [self myDefineCell:cell
                        withArray:[mMu_Array_Tags objectAtIndex:[indexPath indexAtPosition:1]]
                          withrow:indexPath.row];
        
    }else{
        return cell;
    }
    
    //return cell;
    
}

-(UITableViewCell *)myDefineCell:(UITableViewCell *)myDefineCell
                       withArray:(NSMutableArray *)array//自定义的数组供tableviewcell显示=3in1.
                         withrow:(NSInteger )row{
    for (id subview in myDefineCell.contentView.subviews){
		[subview removeFromSuperview];
	}
    
    NSString *ns_tag = (NSString *)array;
    [myDefineCell.textLabel setText:ns_tag];
    [myDefineCell.textLabel setTextColor:[UIColor whiteColor]];
    [myDefineCell.textLabel setFont:[UIFont fontWithName:@"" size:10]];
    [myDefineCell.textLabel setBackgroundColor:[UIColor clearColor]];
    [myDefineCell.textLabel setTextAlignment:NSTextAlignmentRight];
    UILabel *temp_label = myDefineCell.textLabel;
    ;
    NSLog(@"*****%f",temp_label.frame.size.width);
    return myDefineCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"indexPath = %@",indexPath);
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0){
    NSLog(@"*didFinishPickingImage");
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"*didFinishPickingMediaWithInfo:%@",info);
    NSURL *assetUrl = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    [lib assetForURL:assetUrl resultBlock:^(ALAsset *asset)
    {
        //在这里使用asset来获取图片
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPickPhotoRsp:) name:@"didPickPhotoNoti" object:nil];
        ALAssetRepresentation *assetRep = [asset defaultRepresentation];
        CGImageRef imgRef = [assetRep fullResolutionImage];
        UIImage *img = [UIImage imageWithCGImage:imgRef
                                           scale:assetRep.scale
                                     orientation:(UIImageOrientation)assetRep.orientation];
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didPickPhotoNoti" object:img];
            
        }];
        
    }
        failureBlock:^(NSError *error)
    {}
     ];
}
-(void)didPickPhotoRsp:(NSNotification *)noti{
    UIImage *imgPhoto = (UIImage *)noti.object;
    self.uiimageview.image = imgPhoto;
    
}




/*--------------*/

//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
//    NSLog(@"*Cancel");
//}
- (IBAction)addFavorites:(id)sender {
}
- (IBAction)showMoreInfo:(id)sender {
}
- (IBAction)zoomFitImage:(id)sender {
    
    if ([self.imageviewScroll zoomScale]>=5.0) {
        self.scale = 1.0;
        [self.imageviewScroll setZoomScale:self.scale animated:YES];
        [self.zoomBtn setImage:[UIImage imageNamed:@"zoom_in.png"] forState:UIControlStateNormal];
    }else{
        self.scale = [self.imageviewScroll zoomScale];
        self.scale = self.scale+1;
        [self.imageviewScroll setZoomScale:self.scale animated:YES];
        if (self.scale>=4.0&&self.scale<=5.0) {
            [self.zoomBtn setImage:[UIImage imageNamed:@"fit.png"] forState:UIControlStateNormal];
            [self.imageviewScroll setZoomScale:5.0 animated:YES];
        }
    }
    
}
@end
