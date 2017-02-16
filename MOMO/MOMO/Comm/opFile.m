//
//  opFile.m
//
//  Created by quintic on 8/5/14.
//  Copyright (c) 2014 Quintic. All rights reserved.
//

#import "opFile.h"

///// default settings start
//#define KEY_DEV_IDENTIFIER    @"key-Peripheral identifier"
//
//#define KEY_SETTING_INFO      @"key-setting Info"
//#define KEY_DEV_NAME          @"key-Peripheral Name"
//#define KEY_RSSI_ALARM_TH     @"key-RssiAlarmTH"
//#define KEY_RSSI_ALARM_SENS   @"key-RssiAlarmSens"
//#define KEY_LOCAL_ALARM       @"key-LocalAlarm"
//#define KEY_AUTO_RECONNECT    @"key-AutoReConnet"
///// default settings end

@interface opFile() {
    
}
@end
@implementation opFile
+ (opFile *)sharedInst
{
    static opFile *_sharedInst = nil;
    if (_sharedInst == nil) {
        _sharedInst = [[opFile alloc] init];
    }
    return _sharedInst;
}
#pragma file
/*
"key-Peripheral UUIDi" =     {
        "key-AutoReConnet" = xx;
        "key-LocalAlarm" = yy;
        "key-Peripheral Id" = "user peripheral identifier";
        "key-Peripheral Name" = "aaa";
        "key-RssiAlarmSens" = 21;
        "key-RssiAlarmTH" = 22;
};
*/

/// access file
/*
 * get file in the document path
 *
 */
+(NSString*)getFilePath:(NSString *)fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];
    NSString *path=[documentsDirectory stringByAppendingPathComponent:fileName/* @"anti lost.plist" */];
    NSLog(@"file path : %@", path);
    return path;
}
// delete file
+(BOOL)deleteFile:(NSString *)fileName withType:(NSString *)fileType {
    NSString *documentsPath =[self dirDoc];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *fileFullName=[NSString stringWithFormat:@"%@%@",fileName, fileType];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileFullName];
    
    BOOL res=[fileManager removeItemAtPath:filePath error:nil];
    
    if (res) {
        NSLog(@"delete file:%@ success", fileName);
        return TRUE;
    }
    else
    {
        
        NSLog(@"delete file :%@ failed!", fileName);
        
        NSLog(@"file exist ? : %@",[fileManager isExecutableFileAtPath:filePath]?@"YES":@"NO");
        
        return FALSE;
    }
}

//
+(NSString *)createFile:/* (NSString *)fileDir
withName:*/(NSString *)fileName
               withType:(NSString *)fileType{
    NSString *documentsPath =[self dirDoc];
    
    /// NSString *fileFullDir = [documentsPath stringByAppendingPathComponent:fileDir];
    /// NSLog(@"fileFullDir : %@" ,fileFullDir);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *fileFullName=[NSString stringWithFormat:@"%@%@",fileName, fileType];
    
    
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileFullName];
    if([fileManager fileExistsAtPath:filePath] == YES){
        return filePath;
    }else{
        BOOL res=[fileManager createFileAtPath:filePath contents:nil attributes:nil];
        
        if (res) {
            NSLog(@"createFile ok : %@" ,filePath);
            
        }else{
            NSLog(@"createFile failed");
            
        }
        return filePath;
    }
}

+(BOOL)createWithDirectory:(NSString *)directoryName{
    NSError *error = [[NSError alloc] init];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSString *path = nil;
    path = [self getFilePath:[NSString stringWithFormat:@"/%@/",directoryName]];
    BOOL createDirectory = [fileManage createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (createDirectory==YES) {
        return YES;
    }
    NSLog(@"createDirectory error=%@",error);
    return NO;
}

+(NSString *)createFile:(NSString *)fileName WithDefaultContents:(NSString *)defaultContents{
    NSString *path = [self getFilePath : fileName];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if ([fileManage fileExistsAtPath:path]==YES){
        NSLog(@"文件已存在!");
        return path;
    }else{
        NSData *data =nil;
        if ([defaultContents length]!=0) {
            data = [defaultContents dataUsingEncoding:NSUTF8StringEncoding];
        }else{
            data = [@"Test Data" dataUsingEncoding:NSUTF8StringEncoding];
        }
        [fileManage createFileAtPath:path contents:data attributes:nil];//new file
        return path;
    }
}

/*
 param : filename
         withData : a dict
*/
+ (void)writeFile:(NSString *)fileName WithContents:(NSString *)Contents{
    NSString *path = [self getFilePath : fileName];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if ([fileManage fileExistsAtPath:path]==YES){
        NSLog(@"文件已存在!");
        
    }else{
        NSData *data = [Contents dataUsingEncoding:NSUTF8StringEncoding];
        [fileManage createFileAtPath:path contents:data attributes:nil];
    }
}
+ (void)writeFileWithPath:(NSString *)filePath WithContents:(NSString *)Contents{
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSFileHandle *fileHandle;
    NSData *data =nil;
    if ([fileManage fileExistsAtPath:filePath]==YES){
        NSLog(@"File Exists At Path:%@",filePath);
        data = [Contents dataUsingEncoding:NSUTF8StringEncoding];
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:data];
    }else{
        NSLog(@"File Not Found:%@",filePath);
    }
}
+ (NSDictionary *)readFile : (NSString *)fileName {
    NSDictionary *retDict = [[NSDictionary alloc] init];
    NSString *path = [self getFilePath : fileName];
    NSLog(@"%@", path);
    retDict = [[NSDictionary alloc] initWithContentsOfFile: path];
    NSLog(@"retDict : %@", retDict);
    return retDict;
}
+ (NSString *)readTxtFile : (NSString *)fileName {
    NSString *path = [self getFilePath : fileName];
    NSLog(@"%@", path);
    NSError *error;
    NSString *txt=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    NSLog(@"txt : %@", txt);
    return txt;
}
+(void)updateObjectIntoFile:(NSString *)filePath
             withObjData:(NSMutableDictionary *)newData{
    NSMutableDictionary *oriData = [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
    if ([[oriData allKeys] count] == 0) {
        [newData writeToFile:filePath atomically:YES];
    }else{
        for (NSString *ori_key in [oriData allKeys]) {
            for (NSString *new_key in [newData allKeys]) {
                if ([ori_key isEqualToString:new_key]) {
                    NSString *new_value = [newData objectForKey:new_key];
                    [oriData setObject:new_value forKey:ori_key];
                }else{
                    NSString *new_value = [newData objectForKey:new_key];
                    [oriData setObject:new_value forKey:new_key];
                }
            }
        }
        [oriData writeToFile:filePath atomically:YES];
    }
    
}
+(void)addObjectIntoCookieFile:(NSString *)fileName
             withObjData:(NSDictionary *)objData{
    NSString *path = [self getFilePath:fileName];
    NSMutableDictionary *dictForFile = [[NSMutableDictionary alloc] init];
    [dictForFile setValue:objData
                   forKey:[NSString stringWithFormat:@"Cookie"]];
    [dictForFile writeToFile:path atomically:YES];
    
    return ;
    
}
+(void)addObjectIntoFile:(NSString *)fileName
             withObjData:(NSDictionary *)objData{
    NSString *path = [self getFilePath:fileName];
    NSMutableDictionary *dictInFile = [[NSMutableDictionary alloc] initWithContentsOfFile : path];
    if(dictInFile == nil){
        NSMutableDictionary *dictForFile = [[NSMutableDictionary alloc] init];
        [dictForFile setValue: objData forKey : [NSString stringWithFormat:@"%@0", KEY_DATA_ID_HEADER]];
        [dictForFile writeToFile:path atomically:YES];
        
        return ;
    }
    NSArray *arrKeys = [dictInFile allKeys];
    /// to replace the device with the same id
    for(int i = 0; i < [arrKeys count]; i++)
    {
        NSDictionary *dictCurrent =[dictInFile objectForKey:[arrKeys objectAtIndex:i]];
        NSString *strCurPeriId =[dictCurrent objectForKey:KEY_DEV_IDENTIFIER];
        NSString *strDevId2Save =[objData objectForKey:KEY_DEV_IDENTIFIER];
        if([strCurPeriId isEqual :strDevId2Save]){
            [dictInFile removeObjectForKey:[arrKeys objectAtIndex:i]];
            [dictInFile setObject:objData forKey:[arrKeys objectAtIndex:i]];
            [dictInFile writeToFile:path atomically:YES];
            
            return;
        }
    }
    /// to save a new device info.
    NSString *strKeyToStore =nil;
    for(int i = 0; i <= RECORD_INDEX_MAX; i++)
    {
        strKeyToStore=[NSString stringWithFormat:@"%@%d",KEY_DATA_ID_HEADER,i];
        
        if(![arrKeys containsObject:strKeyToStore])
        {
            break;
        }
    }
    /// add the node on.
    [dictInFile setValue: objData forKey : strKeyToStore];
    NSLog(@"dictInFile: %@", dictInFile);
    [dictInFile writeToFile : path atomically : YES];
    
}
/***************************************************************
 * true  : success to remove
 * false : file is null or no the identifier.
 ***************************************************************/
+(BOOL)removeObjectIntoFile : (NSString *)fileName
                  withIdStr : (NSString *)objIdentifier{
    NSString *path = [self getFilePath : fileName];
    if(path == nil)
        return FALSE;
    NSMutableDictionary *dictInFile = [[NSMutableDictionary alloc] initWithContentsOfFile : path];
    NSArray *arrKeys = [dictInFile allKeys];
    for(int i = 0; i < [arrKeys count]; i++)
    {
        NSDictionary *dictCurrent = [dictInFile objectForKey : [arrKeys objectAtIndex:i]];
        NSString *strCurPeriId = [dictCurrent objectForKey : KEY_DEV_IDENTIFIER];
        if([strCurPeriId isEqual : objIdentifier]){
            [dictInFile removeObjectForKey : [arrKeys objectAtIndex : i]];
            [dictInFile writeToFile : path atomically : YES];
            return TRUE;
        }
    }
    return FALSE;
}
+ (BOOL)changeOneObjectInFile : (NSString *)fileName
                      withObj : (NSString *)objId
                     withData : (NSDictionary *)objValue{
    NSMutableDictionary *dictFile =nil;
    NSString *path = [self getFilePath : fileName];
    if(path == nil)
        return FALSE;
    NSLog(@"%@", path);
    dictFile = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSArray *allkeys = [dictFile allKeys];
    NSDictionary *aDict;
    for(int i = 0; i<[dictFile count]; i++){
        aDict = [dictFile objectForKey:[allkeys objectAtIndex:i]];
        NSString *aIdheader = [allkeys objectAtIndex:i];
        NSString *aIdent = [aDict objectForKey:KEY_DEV_IDENTIFIER ];
        if([aIdent isEqual:objId]){
            //return aDict;
            [dictFile setObject:objValue forKey:aIdheader];
            [dictFile writeToFile:path atomically:YES];
           
            return TRUE;
        }
    }
    NSLog(@"retDict : %@", dictFile);
    return FALSE;
}
+(NSDictionary *)getOneSettingADict:(NSString *)fileName
                          withIdStr:(NSString *)idStr{
    NSString *path = [self getFilePath : fileName];
    if(path == nil)
        return nil;
    NSDictionary *dictFile = [[NSDictionary alloc] initWithContentsOfFile: path];
    NSArray *allkeys = [dictFile allKeys];
    NSDictionary *aDict;
    for(int i = 0; i<[dictFile count]; i++){
        aDict = [dictFile objectForKey:[allkeys objectAtIndex:i]];
        //NSString *aIdheader = [allkeys objectAtIndex:i];
        NSString *aIdent = [aDict objectForKey:KEY_DEV_IDENTIFIER ];
        NSLog(@"aIdentifier : %@", idStr);
        if([aIdent isEqual:idStr]){
            return aDict;
        }
    }
    return aDict;
}
+(NSString *)getOneSettingItem:(NSString *)fileName
                   withIdStr:(NSString *)idStr
                     withKey:(NSString *)aKey{
    NSString *retStr = nil;
    NSString *path = [self getFilePath : fileName];
    if(path == nil)
        return nil;
    NSDictionary *dictFile = [[NSDictionary alloc] initWithContentsOfFile: path];
    NSArray *allkeys = [dictFile allKeys];
    NSDictionary *aDict = nil;
    for(int i = 0; i<[dictFile count]; i++){
        aDict = [dictFile objectForKey:[allkeys objectAtIndex:i]];
        NSString *aIdent = [aDict objectForKey:KEY_DEV_IDENTIFIER ];
        NSLog(@"aIdentifier : %@", idStr);
        if([aIdent isEqual:idStr]){
            retStr = [aDict objectForKey:aKey];
            NSLog(@"retStr : %@", retStr);
            break;
        }
    }
    return retStr;
}
+(NSString *)getIdentifierSetting:(NSString *)fileName
                 withIdStr:(NSString *)idStr{
    return [self getOneSettingItem:fileName withIdStr:idStr withKey:KEY_DEV_IDENTIFIER ];
}
+(NSString *)getLocalAlarmSetting:(NSString *)fileName
                      withIdStr:(NSString *)idStr{
    return [self getOneSettingItem:fileName withIdStr:idStr withKey:KEY_LOCAL_ALARM ];
}
+(NSString *)getAutoReconnectSetting:(NSString *)fileName
                           withIdStr:(NSString *)idStr{
    return [self getOneSettingItem:fileName withIdStr:idStr withKey:KEY_AUTO_RECONNECT ];
}
+(NSString *)getAlarmSensSetting:(NSString *)fileName
                           withIdStr:(NSString *)idStr{
    return [self getOneSettingItem:fileName withIdStr:idStr withKey:KEY_RSSI_ALARM_SENS ];
}
+(NSString *)getRssiThSetting:(NSString *)fileName
                       withIdStr:(NSString *)idStr{
    return [self getOneSettingItem:fileName withIdStr:idStr withKey:KEY_RSSI_ALARM_TH ];
}
+(NSString *)getDevNameSetting:(NSString *)fileName
                    withIdStr:(NSString *)idStr{
    return [self getOneSettingItem:fileName withIdStr:idStr withKey:KEY_DEV_NAME ];
}
// get Documents foldder
+(NSString *)dirDoc{
    //[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"app_home_doc: %@",documentsDirectory);
    return documentsDirectory;
}

@end
