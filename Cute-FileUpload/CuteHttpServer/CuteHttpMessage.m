//
//  CuteHttpMessage.m
//  Cute-FileUpload
//
//  Created by qinzhiwei on 15/7/20.
//  Copyright (c) 2015年 qinzhiwei. All rights reserved.
//

#import "CuteHttpMessage.h"

@interface CuteHttpMessage ()
{
    NSMutableString * httpMessage;
    CFHTTPMessageRef  requestMessage;
}
@end

@implementation CuteHttpMessage

- (id)init{
    self = [super init];
    if (self) {
        httpMessage = [[NSMutableString alloc]initWithString:@"HTTP/1.1 200 OK\nServer: ZWServer"];
    }
    return self;
}

- (void)appendHeaderField:(NSString *)headerField headerValue:(NSString *)value{
    
    [httpMessage appendFormat:@"\n%@: %@",headerField,value];
    
}

- (NSData *)httpHeaderMessageData{
    
    [httpMessage appendFormat:@"\n\n"];
    
    return [httpMessage dataUsingEncoding:NSUTF8StringEncoding];
    
}

- (void)appendBytes:(NSData *)data{
    
    CFHTTPMessageAppendBytes(requestMessage, [data bytes], [data length]);
    
}

@end
