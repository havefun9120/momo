//
//  Tool.m
//  vt_ble_scan
//
//  Created by xiayin on 13-3-1.
//  Copyright (c) 2013年 viewtool. All rights reserved.
//

#import "Tool.h"

@implementation Tool
static NSDictionary *myDictionary;
static NSString *staticTxtFilename;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }

    return self;
}
-(BOOL)myIsPad{
    if (isPad) {
        return YES;
    }else{
        return NO;
    }
}
- (float)getScreenWidthPix{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat width = size.width;
    return width;
}
- (float)getScreenheightPix{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat height = size.height;
    return height;
}
/**
 解析chars&sverce
 */
- (NSString *)parsedString:(NSString *)s{
    
    NSLog(@"SeparatedByString[0]:%@",[s componentsSeparatedByString:@"(<"][0]);
    if ([[s componentsSeparatedByString:@"(<"] count]>1) {
        NSString *judgeString = [s substringWithRange:NSMakeRange(9, 1)];
        if (![judgeString isEqualToString:@"<"]) {
            return [NSString stringWithFormat:@"%@",s];
        }else{
            NSString *nsstringParsedCharacteristicsKey = [s substringWithRange:NSMakeRange(10, 4)];
            nsstringParsedCharacteristicsKey = [NSString stringWithFormat:@"0x%@",nsstringParsedCharacteristicsKey];
            NSArray* arrDictAllKey = [[Tool getdict] allKeys];
            for(NSString* strkey in arrDictAllKey)
            {
                //NSLog(@"xiayin_key:%@",strkey);
                if ([nsstringParsedCharacteristicsKey isEqualToString:strkey] ) {
                    
                    //return [[Tool getdict] objectForKey:strkey];
                    NSString *strValue = [[Tool getdict] objectForKey:strkey];
                    NSString *strFull = [NSString stringWithFormat:@"%@(%@)",strValue,strkey];
                    
                    NSLog(@"xiayin_value_and_key:%@",strFull);
                    return strFull;
                }
                
            }
        }
    }else{
        return s;
    }
    
    return [NSString stringWithFormat:@"%@",s];
}
+ (NSDictionary *)getdict{
    myDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"GAP"    ,     				@"0x1800",
                                  @"GATT",						@"0x1801",
                                  @"Imm. Alert SVC",			@"0x1802",
                                  @"Link Loss SVC",				@"0x1803",
                                  @"TX Power SVC",				@"0x1804",
                                  @"Current Time SVC",			@"0x1805",
                                  @"Reference Time SVC",		@"0x1806",
                                  @"Next DST Change SVC",		@"0x1807",
                                  @"Glucose Sensor SVC",		@"0x1808",
                                  @"Health Thermom SVC",		@"0x1809",
                                  @"Device Info SVC",			@"0x180a",
                                  @"Network Avail. SVC",		@"0x180b",
                                  @"Watchdog SVC",				@"0x180c",
                                  @"Heart Rate SVC",			@"0x180d",
                                  @"Phone Alert Status SVC",	@"0x180e",
                                  @"Battery SVC",				@"0x180f",
                                  @"Blood Pressure SVC",		@"0x1810",
                                  @"HID SVC",					@"0x1812",
                                  @"Device Name",				@"0x2a00",
                                  @"Appearance",				@"0x2a01",
                                  @"Privacy Flag",				@"0x2a02",
                                  @"Reconnection Address",		@"0x2a03",
                                  @"Periph. Pref. Con. Par",	@"0x2a04",
                                  @"Service Changed",			@"0x2a05",
                                  @"Alert Level",				@"0x2a06",
                                  @"TX Power Level",			@"0x2a07",
                                  @"Date Time",					@"0x2a08",
                                  @"Day-Week",					@"0x2a09",
                                  @"Day-Date Time",				@"0x2a0a",
                                  @"Exact Time 100",			@"0x2a0b",
                                  @"Exact Time 256",			@"0x2a0c",
                                  @"DST Offset",				@"0x2a0d",
                                  @"Time Zone",					@"0x2a0e",
                                  @"Local Time info",			@"0x2a0f",
                                  @"Secondary time Zone",		@"0x2a10",
                                  @"Time with DST",				@"0x2a11",
                                  @"Time Accuracy",				@"0x2a12",
                                  @"Time Source",				@"0x2a13",
                                  @"Reference Time Info",		@"0x2a14",
                                  @"Time Broadcast",			@"0x2a15",
                                  @"Time Update Cntl. Point",	@"0x2a16",
                                  @"Time Update status",		@"0x2a17",
                                  @"Boolean",					@"0x2a18",
                                  @"Battery Level",				@"0x2a19",
                                  @"Battery Power State",		@"0x2a1a",
                                  @"Battery Level State",		@"0x2a1b",
                                  @"Temperature Meas",			@"0x2a1c",
                                  @"Temperature Type",			@"0x2a1d",
                                  @"Intermediary Temp",			@"0x2a1e",
                                  @"Intermediary Temp",			@"0x2a1f",
                                  @"Temp. Fahrenheit",			@"0x2a20",
                                  @"Measurement Interval",		@"0x2a21",
                                  @"System ID",					@"0x2a23",
                                  @"Model NB",					@"0x2a24",
                                  @"Serial NB",					@"0x2a25",
                                  @"FW Revision",				@"0x2a26",
                                  @"HW Revision",				@"0x2a27",
                                  @"SW Revision",				@"0x2a28",
                                  @"Manufacturer Name",			@"0x2a29",
                                  @"IEEE Certification Data",	@"0x2a2a",
                                  @"CT Time",					@"0x2a2b",
                                  @"Elevation",					@"0x2a2c",
                                  @"Latitude",					@"0x2a2d",
                                  @"Longitude",					@"0x2a2e",
                                  @"Position 2D",				@"0x2a2f",
                                  @"Position 3D",				@"0x2a30",
                                  @"Vendor ID",					@"0x2a31",
                                  @"Product ID",				@"0x2a32",
                                  @"HID Version",				@"0x2a33",
                                  @"Vendor ID source",			@"0x2a34",
                                  @"Blood Pressure Meas",		@"0x2a35",
                                  @"Imm. Cuff pressure",		@"0x2a36",
                                  @"Heart Rate Meas",			@"0x2a37",
                                  @"Body Sensor Location",		@"0x2a38",
                                  @"Heart Rate Cntl. Point",	@"0x2a39",
                                  @"Removable",					@"0x2a3a",
                                  @"Service Required",			@"0x2a3b",
                                  @"science Temp Celsius",		@"0x2a3c",
                                  @"String",					@"0x2a3d",
                                  @"Netwk. avail",				@"0x2a3e",
                                  @"Alert Status",				@"0x2a3f",                            nil];//注意用nil结束
    return myDictionary;
}
+ (NSString *)mCreateTxt:(NSString *)txtfilename{
    //创建文件管理器
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    
    
    //获取document路径,括号中属性为当前应用程序独享
    
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    
    NSString *documentDirectory = [directoryPaths objectAtIndex:0];
    
    
    
    //定义记录文件全名以及路径的字符串filePath
    ;
    NSString *filePath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",txtfilename]];
    
    
    
    //查找文件，如果不存在，就创建一个文件
    
    if (![fileManager fileExistsAtPath:filePath]) {
        
        [fileManager createFileAtPath:filePath 
                             contents:nil 
                           attributes:nil];
        NSLog(@"TXT_filePath_name:%@---%@",txtfilename,filePath);
        staticTxtFilename = filePath;
        return filePath;
    }
    return nil;
}
+ (NSString *)mGetTxtPath{
    return staticTxtFilename;
}
+ (BOOL)writeFile:(NSString *)filename 
     withContents:(NSString *)contents

{
    
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //获取路径
    
    //1、参数NSDocumentDirectory要获取的那种路径
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    //2、得到相应的Documents的路径
    NSString* DocumentDirectory = [paths objectAtIndex:0];
    //3、更改到待操作的目录下
    [fileManager changeCurrentDirectoryPath:[DocumentDirectory stringByExpandingTildeInPath]];
    //4、创建文件fileName文件名称，contents文件的内容，如果开始没有内容可以设置为nil，attributes文件的属性，初始为nil
    [fileManager removeItemAtPath:filename error:nil];
    NSString *path = [DocumentDirectory stringByAppendingPathComponent:filename];
    //5、创建数据缓冲区
    NSMutableData *writer = [[NSMutableData alloc] init];
    //6、将字符串添加到缓冲中
    [writer appendData:[contents dataUsingEncoding:NSUTF8StringEncoding]];
    //7、将其他数据添加到缓冲中
    //将缓冲的数据写入到文件中
    //[writer writeToFile:path atomically:YES];
    if ([writer writeToFile:path atomically:YES]) {
        NSLog(@"writeToFilePath:%@---contents:%@",path,contents);
        return YES;
    }
    //[writer release];
    return NO;
}


+ (NSString *)readFile:(NSString *)filename
{
    
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //获取路径    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);    
    NSString *documentsDirectory = [paths objectAtIndex:0];    
    [fileManager changeCurrentDirectoryPath:[documentsDirectory stringByExpandingTildeInPath]];    
    //获取文件路劲    
    NSString* path = [documentsDirectory stringByAppendingPathComponent:filename];    
    NSData* reader = [NSData dataWithContentsOfFile:path];    
    return [[NSString alloc] initWithData:reader encoding:NSUTF8StringEncoding];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//得到“天”的日起有哪些天，月。（横坐标上显示的日期）
- (NSMutableArray *)getWaveDay:(NSArray *)array{
    
    NSMutableArray *mArray = [[NSMutableArray alloc]initWithCapacity:10];
    for (int i=0; i<[array count]-1; i++) {
        NSString *s = [array objectAtIndex:i];
        NSLog(@"getWaveDay-s:%@",s);
        [mArray addObject:s];
    }
    NSMutableArray* filterResults = [[NSMutableArray alloc] initWithCapacity:10];
    BOOL copy;
    if (!([mArray count] == 0)) {
        for (NSString *a1 in mArray) {
            NSString *day = [[a1 componentsSeparatedByString:@"<FGzhiduan>"] objectAtIndex:5];
            day = [[day componentsSeparatedByString:@"T"] objectAtIndex:0];
            day = [day substringWithRange:NSMakeRange(5, 5)];
            copy = YES;
            for (NSString *a2 in filterResults) {
                if ([day isEqualToString:a2]) {
                    copy = NO;
                    break;
                }
            }
            if (copy) {
                //NSLog(@"tool_day:%@",day);
                [filterResults addObject:day];
            }
        }
    }
    //NSLog(@"tool_day_count:%d",[filterResults count]);
    return filterResults;
}
//得到以天为单位时的所有当天数据
- (NSString *)getWaveDataByDay:(NSArray *)array{
    NSMutableArray *mArray = [[NSMutableArray alloc]initWithCapacity:10];
    for (int i=0; i<[array count]-1; i++) {
        NSString *s = [array objectAtIndex:i];
        [mArray addObject:s];
    }
    NSString *data = @"|";
    NSString *d;
    NSMutableArray* filterResults = [[NSMutableArray alloc] initWithCapacity:10];
    BOOL copy;
    if (!([mArray count] == 0)) {
        for (NSString *a1 in mArray) {
            NSString *day = [[a1 componentsSeparatedByString:@"<FGzhiduan>"] objectAtIndex:5];
            day = [[day componentsSeparatedByString:@"T"] objectAtIndex:0];
            day = [day substringWithRange:NSMakeRange(5, 5)];
            copy = YES;
            for (NSString *a2 in filterResults) {
                if ([day isEqualToString:a2]) {
                    copy = NO;
                    d = [[a1 componentsSeparatedByString:@"<FGzhiduan>"] objectAtIndex:1];
                    data = [data stringByAppendingFormat:@"%@%@",d,@"-"];
                    break;
                }
            }
            if (copy) {
                [filterResults addObject:day];
                d = [[a1 componentsSeparatedByString:@"<FGzhiduan>"] objectAtIndex:1];
                data = [data stringByAppendingFormat:@"%@%@%@",@"**",d,@"-"];
            }
        }
    }
    return data;
}
//处理数据得到以天为单位时的当天平均值
- (NSMutableArray *)parsingData:(NSString *)string{
    //NSLog(@"tool_parsingData:%@",string);
    NSMutableArray* filterResults = [[NSMutableArray alloc] initWithCapacity:10];
    NSArray *days = [string componentsSeparatedByString:@"**"];
    //NSLog(@"tool_days:%d",[days count]);
    for (int i=0; i<=[days count]-1; i++) {
        float f = 0.0000;
        NSString *ns_i = [days objectAtIndex:i];
        NSArray *data_d = [ns_i componentsSeparatedByString:@"-"];
        for (int i =0; i<[data_d count]-1; i++) {
            NSString *data_i = [data_d objectAtIndex:i];
            f = f+[data_i floatValue];
        }
        if (f == 0) {
            NSString *ns_f_avg = [NSString stringWithFormat:@"%f",f];
            //NSLog(@"tool_ns_f_avg:%@",ns_f_avg);
            [filterResults addObject:ns_f_avg];
            f = 0;
        }else{
            f = f/([data_d count]-1);
            NSString *ns_f_avg = [NSString stringWithFormat:@"%f",f];
            //NSLog(@"tool_ns_f_avg:%@",ns_f_avg);
            [filterResults addObject:ns_f_avg];
            f = 0;
        }
    }
    return filterResults;
}
//得到以天为单位时的所有当天每小时的数据(小时)
- (NSString *)getWaveDataByHour:(NSArray *)array{
    
    NSMutableArray *mArray = [[NSMutableArray alloc]initWithCapacity:10];
    for (int i=0; i<[array count]-1; i++) {
        NSString *s = [array objectAtIndex:i];
        [mArray addObject:s];
    }
    NSString *data = @"|";
    NSString *d;
    NSMutableArray* filterResults = [[NSMutableArray alloc] initWithCapacity:10];
    BOOL copy;
    if (!([mArray count] == 0)) {
        for (NSString *a1 in mArray) {
            NSString *day = [[a1 componentsSeparatedByString:@"<FGzhiduan>"] objectAtIndex:5];
            day = [[day componentsSeparatedByString:@"T"] objectAtIndex:0];
            day = [day substringWithRange:NSMakeRange(5, 5)];
            
            NSString *hour = [[a1 componentsSeparatedByString:@"<FGzhiduan>"] objectAtIndex:5];
            hour = [[hour componentsSeparatedByString:@"T"] objectAtIndex:1];
            hour = [hour substringWithRange:NSMakeRange(0, 2)];
            
            copy = YES;
            for (NSString *a2 in filterResults) {
                if ([day isEqualToString:a2]) {
                    copy = NO;
                    d = [[a1 componentsSeparatedByString:@"<FGzhiduan>"] objectAtIndex:1];
                    data = [data stringByAppendingFormat:@"%@[H]%@%@",hour,d,@"-"];
                    //data = [data stringByAppendingFormat:@"%@%@%@",d,@"****",day];
                    break;
                }
            }
            if (copy) {
                [filterResults addObject:day];
                d = [[a1 componentsSeparatedByString:@"<FGzhiduan>"] objectAtIndex:1];
                data = [data stringByAppendingFormat:@"%@%@[D]%@[H]%@%@",@"[**]",day,hour,d,@"-"];
            }
        }
    }
    return data;
}
- (NSMutableArray *)parsingDataByHour:(NSString *)string{
    NSMutableArray *days = [[NSMutableArray alloc]initWithCapacity:3];
    NSMutableArray *days1 = [[NSMutableArray alloc]initWithCapacity:3];
    NSArray *countDay = [string componentsSeparatedByString:@"[**]"];
    for (int i = 0; i<[countDay count]-1; i++) {
        [countDay objectAtIndex:i+1];
        [days addObject:[countDay objectAtIndex:i+1]];
    }

    for (NSString *s in days) {
        [days1 addObject:[[s componentsSeparatedByString:@"[D]"] objectAtIndex:0]];
    }
    return  nil;
}
/*
 方法:parsingReturnedGetDataCounts:webReturned
 参数:webReturned:web服务器端拿到的未解析的数据.
 描述:根据web端定义好的格式解析数据.(影响行数量)
 */
+(NSString *)parsingReturnedGetDataCounts:(NSString *)webReturned{
    NSString *DataCounts = [[webReturned componentsSeparatedByString:@"<FGtiaoshu>"] objectAtIndex:0];
    return DataCounts;
}
/*
 方法:parsingReturnedGetDataContents:webReturned
 参数:webReturned:web服务器端拿到的未解析的数据.
 描述:根据web端定义好的格式解析数据.(每行的内容)
 */
+(NSArray *)parsingReturnedGetDataContents:(NSString *)webReturned{
    NSArray *DataContents = [[[webReturned componentsSeparatedByString:@"<FGtiaoshu>"] objectAtIndex:1] componentsSeparatedByString:@"<FGmeitiao>"];
    return DataContents;
}
/*
 方法:parsingReturnedGetMessageIsOrNotRead:webReturned
 参数:webReturned:web服务器端拿到的未解析的数据.
 描述:得到message的读否状态
 */
+(NSString *)parsingReturnedGetMessageIsOrNotRead:(NSString *)webReturned{
    NSString *IsOrNotRead = [[webReturned componentsSeparatedByString:@"<FGtiaoshu>"] objectAtIndex:2];
    return IsOrNotRead;
}
@end
