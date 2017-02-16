//
//  opFile.h
//
//  Created by quintic on 8/5/14.
//  Copyright (c) 2014 Quintic. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KEY_DATA_ID_HEADER           @"key-DataIdInFile-"
#define RECORD_INDEX_MAX             (0xff)

/// default settings start
#define KEY_DEV_IDENTIFIER    @"key-Peripheral identifier"

#define KEY_Product_Name            @"key-product name"
#define KEY_User_Name               @"key-user name"
#define KEY_Interval                @"key-interval"
#define KEY_Verify                  @"key-verify"
#define KEY_DisplayUnit             @"key-display unit"
#define KEY_History_DisplayType     @"key-history display type"
#define KEY_MapType                 @"key-map type"
#define KEY_OpenAlert               @"key-open alert"
#define KEY_AlertRange               @"key-alert range"
#define KEY_AlertAudioName               @"key-alert audio name"

#define KEY_SETTING_INFO      @"key-setting Info"
#define KEY_DEV_NAME          @"key-Peripheral Name"
#define KEY_RSSI_ALARM_TH     @"key-RssiAlarmTH"
#define KEY_RSSI_ALARM_SENS   @"key-RssiAlarmSens"
#define KEY_LOCAL_ALARM       @"key-LocalAlarm"
#define KEY_AUTO_RECONNECT    @"key-AutoReConnet"
/// default settings end

#define KEY_DEV_UUID          @"key-Peripheral UUID"

#define KEY_DEV_UUID0         @"key-Peripheral UUID0"
#define KEY_DEV_UUID1         @"key-Peripheral UUID1"
#define KEY_DEV_UUID2         @"key-Peripheral UUID2"

@interface opFile : NSObject

/*
 * file operation
 */
+(BOOL)createWithDirectory:(NSString *)directoryName;

+(NSString *)createFile:/* (NSString *)fileDir
withName:*/(NSString *)fileName
               withType:(NSString *)fileType;

+(NSString *)createFile:(NSString *)fileName WithDefaultContents:(NSString *)defaultContents;

+(NSString *)getFilePath:(NSString *)fileName;

+(BOOL)deleteFile:(NSString *)fileName withType:(NSString *)fileType;

+(void)writeFile:(NSString *)fileName WithContents:(NSString *)Contents;
+ (void)writeFileWithPath:(NSString *)filePath WithContents:(NSString *)Contents;
+ (NSDictionary *)readFile : (NSString *)fileName;

+ (NSString *)readTxtFile : (NSString *)fileName;
+(void)updateObjectIntoFile:(NSString *)filePath
                withObjData:(NSMutableDictionary *)objData;
+(void)addObjectIntoCookieFile:(NSString *)fileName
                   withObjData:(NSDictionary *)objData;
+(void)addObjectIntoFile : (NSString *)fileName
               /* withObjId : (NSString *)objIdentifier */
             withObjData : (NSDictionary *)objData;
+(BOOL)removeObjectIntoFile : (NSString *)fileName
                  withIdStr : (NSString *)objIdentifier;
+(BOOL)changeOneObjectInFile : (NSString *)fileName
                      withObj : (NSString *)objId
                     withData : (NSDictionary *)objValue;
+(NSDictionary *)getOneSettingADict:(NSString *)fileName
                          withIdStr:(NSString *)idStr;
+(NSString *)getIdentifierSetting:(NSString *)fileName
                        withIdStr:(NSString *)idStr;

+(NSString *)getLocalAlarmSetting:(NSString *)fileName
                   withIdStr:(NSString *)idStr;

+(NSString *)getAutoReconnectSetting:(NSString *)fileName
                           withIdStr:(NSString *)idStr;

+(NSString *)getAlarmSensSetting:(NSString *)fileName
                       withIdStr:(NSString *)idStr;
+(NSString *)getRssiThSetting:(NSString *)fileName
                    withIdStr:(NSString *)idStr;
+(NSString *)getDevNameSetting:(NSString *)fileName
                     withIdStr:(NSString *)idStr;

+ (opFile *)sharedInst ;
@end
