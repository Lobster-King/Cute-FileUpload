//
//  CuteHttpMessage.h
//  Cute-FileUpload
//
//  Created by qinzhiwei on 15/7/20.
//  Copyright (c) 2015年 qinzhiwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CuteHttpMessage : NSObject

//- (id)initWithStatus:(NSInteger)status;
//
//- (BOOL)appendBodyData:(NSData *)data;
//
//- (NSData *)transferHttpData;
//
//- (NSData *)transferHttpBody;
//
//- (void)setHeaderField:(NSString *)headerField value:(NSString *)headerFieldValue;

- (void)appendHeaderField:(NSString *)headerField headerValue:(NSString *)value;
- (NSData *)httpHeaderMessageData;

@end
