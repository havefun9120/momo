//
//  Tool.h
//  vt_ble_scan
//
//  Created by xiayin on 13-3-1.
//  Copyright (c) 2013年 viewtool. All rights reserved.
//

#import <UIKit/UIKit.h>
#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
@interface Tool : UIView{

}
- (float)getScreenWidthPix;
- (float)getScreenheightPix;
- (BOOL)myIsPad;
- (NSString *)parsedString:(NSString *)s;
+ (NSDictionary *)getdict;
+ (NSString *)mCreateTxt:(NSString *)txtfilename;
+ (NSString *)mGetTxtPath;
+ (BOOL)writeFile:(NSString *)filename 
     withContents:(NSString *)contents;
+ (NSString *)readFile:(NSString *)filename;

- (NSMutableArray *)getWaveDay:(NSArray *)array;
- (NSString *)getWaveDataByDay:(NSArray *)array;
- (NSMutableArray *)parsingData:(NSString *)string;

- (NSString *)getWaveDataByHour:(NSArray *)array;
- (NSMutableArray *)parsingDataByHour:(NSString *)string;

/*
 方法:parsingReturnedGetDataCounts:webReturned
 参数:webReturned:web服务器端拿到的未解析的数据.
 描述:根据web端定义好的格式解析数据.(影响行数量).
 */
+(NSString *)parsingReturnedGetDataCounts:(NSString *)webReturned;
/*
 方法:parsingReturnedGetDataContents:webReturned
 参数:webReturned:web服务器端拿到的未解析的数据.
 描述:根据web端定义好的格式解析数据.(每行的内容).
 */
+(NSArray *)parsingReturnedGetDataContents:(NSString *)webReturned;
/*
 方法:parsingReturnedGetMessageIsOrNotRead:webReturned
 参数:webReturned:web服务器端拿到的未解析的数据.
 描述:得到message的读否状态
 */
+(NSString *)parsingReturnedGetMessageIsOrNotRead:(NSString *)webReturned;
@end
