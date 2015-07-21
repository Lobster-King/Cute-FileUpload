//
//  CuteHttpMessage.h
//  Cute-FileUpload
//
//  Created by qinzhiwei on 15/7/20.
//  Copyright (c) 2015年 qinzhiwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CuteHttpMessage : NSObject

- (void)appendHeaderField:(NSString *)headerField headerValue:(NSString *)value;

- (NSData *)httpHeaderMessageData;

- (void)appendBytes:(NSData *)data;

- (NSURL *)requestUrl;

@end

@interface CuteHttpRequestMessage : CuteHttpMessage


@end

@interface CuteHttpResponseMessage : CuteHttpMessage



@end




