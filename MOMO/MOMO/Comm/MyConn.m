//
//  MyConn.m
//  MOMO
//
//  Created by xiayin-mac on 17/2/17.
//  Copyright © 2017年 xiayin. All rights reserved.
//

#import "MyConn.h"

@implementation MyConn


-(id)init{
    self=[super init];
    
    if (self) {
        myDict = [[NSMutableDictionary alloc]init];
    }
    
    return self;
}

+ (MyConn *)sharedInstance
{
    static MyConn *_sharedInstance = nil;
    if (_sharedInstance == nil) {
        _sharedInstance = [[MyConn alloc] init];
    }
    return _sharedInstance;
}

-(void)pubInitWithRequest:(NSURLRequest *)request startImmediately:(BOOL)startImmediately{
    
    if([[request.URL absoluteString] rangeOfString:BASE_TAG_URL].length>0) {
        
    }
    if([[request.URL absoluteString] rangeOfString:BASE_POST_URL].length>0){
        myPostXmlData = [[NSMutableData alloc]init];
    }
    
    
    
    if (myConn != nil) {
        [myConn cancel];
        myConn = nil;
    }
    
    myConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];

    mLoadFinish = NO;
    while(!mLoadFinish) {
        NSLog(@"*!finished");
//        [[NSRunLoop currentRunLoop] run];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

// protocol       NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"myconn didFailWithError");
    mLoadFinish = YES;
    myConn = connection;
    [myConn cancel];
    myConn = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidFailConnection  object:error userInfo:nil];
}
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection{
    NSLog(@"myconn connectionShouldUseCredentialStorage");
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidReceiving object:nil userInfo:nil];
    return NO;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace{
    NSLog(@"myconn canAuthenticateAgainstProtectionSpace");
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidReceiving object:nil userInfo:nil];
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSLog(@"myconn didReceiveAuthenticationChallenge");
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidReceiving object:nil userInfo:nil];
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        [[challenge sender]  useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        [[challenge sender]  continueWithoutCredentialForAuthenticationChallenge: challenge];
    }
}
// protocol       NSURLConnectionDataDelegate
- (nullable NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(nullable NSURLResponse *)response{
    NSLog(@"myconn willSendRequest redirectResponse");
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidReceiving object:nil userInfo:nil];
    return request;
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"myconn didReceiveResponse");
    NSURLRequest *ori_Request = connection.originalRequest;
    if([[ori_Request.URL absoluteString] rangeOfString:BASE_TAG_URL].length>0) {
        
    }
    if([[ori_Request.URL absoluteString] rangeOfString:BASE_POST_URL].length>0){
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidReceiving object:nil userInfo:nil];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSLog(@"myconn didReceiveData");
    
    
    
    NSURLRequest *ori_Request = connection.originalRequest;
    if([[ori_Request.URL absoluteString] rangeOfString:BASE_TAG_URL].length>0) {
        [myTagsData appendData:data];
    }
    if([[ori_Request.URL absoluteString] rangeOfString:BASE_POST_URL].length>0){
        [myPostXmlData appendData:data];
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidReceiving object:nil userInfo:nil];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"myconn connectionDidFinishLoading");
    
    NSURLRequest *ori_Request = connection.originalRequest;
    if([[ori_Request.URL absoluteString] rangeOfString:BASE_TAG_URL].length>0) {
        
    }
    if([[ori_Request.URL absoluteString] rangeOfString:BASE_POST_URL].length>0){
        [myDict setObject:myPostXmlData forKey:BASE_POST_URL];
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidFinishLoading object:myPostXmlData userInfo:myDict];
        mLoadFinish = YES;
    }
    
    
    [myConn cancel];
    myConn = nil;
}

@end
