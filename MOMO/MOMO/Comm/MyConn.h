//
//  MyConn.h
//  MOMO
//
//  Created by xiayin-mac on 17/2/17.
//  Copyright © 2017年 xiayin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDidFailConnection      @"k_DidFailConnection"
#define kDidReceiving           @"k_DidReceiving"
#define kDidFinishLoading       @"k_DidFinishLoading"

@interface MyConn : NSObject<NSURLConnectionDelegate,NSURLConnectionDataDelegate>{
    NSURLConnection *myConn;
    
    NSMutableData *myData;
    
    NSMutableData *myTagsData;
    
    BOOL mLoadFinish;
}


-(id)init;

+ (MyConn *)sharedInstance;

-(void)pubInitWithRequest:(NSURLRequest *)request startImmediately:(BOOL)startImmediately;
@end
