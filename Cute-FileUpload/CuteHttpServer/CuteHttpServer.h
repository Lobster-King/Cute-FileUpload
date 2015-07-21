//
//  CuteHttpServer.h
//  Cute-FileUpload
//
//  Created by qinzhiwei on 15/7/20.
//  Copyright (c) 2015年 qinzhiwei. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    
    kZWCuteServerCouldNotBindToIPv4Address           = 0,
    kZWCuteServerCouldNotBindToIPv6Address           = 1,
    kZWCuteServerNoSocketsAvailable                  = 2,
    
}ZWCuteServerErrorCode;

@class CuteHttpClient;

@protocol ZWCuteServerDelegate <NSObject>

- (void)zwServerStartSuccessfullyIpString:(NSString *)ipString port:(NSString *)port;
- (void)zwServerStartFailedWithError:(ZWCuteServerErrorCode)error;
- (void)zwServerRecivedNewClient:(CuteHttpClient *)client;

@end

@interface CuteHttpServer : NSObject

@property (nonatomic, assign)id <ZWCuteServerDelegate>delegate;

- (void)serverStart;
- (void)serverStop;

@end
