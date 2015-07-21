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

//- (id)initWithStatus:(NSInteger)status{
//    
//    self = [super init];
//    if (self) {
//        
//        httpMessage = CFHTTPMessageCreateResponse(NULL, (CFIndex)status, NULL, (__bridge CFStringRef)@"HTTP/1.1");
//        
//        // set accept language
//        CFHTTPMessageSetHeaderFieldValue(httpMessage, (__bridge CFStringRef)@"Accept-Language", (__bridge CFStringRef)@"zh-CN,zh;q=0.8,en;q=0.6,zh-TW;q=0.4");
//        
//        
//    }
//    return self;
//    
//}
//
//- (BOOL)appendBodyData:(NSData *)data{
//    return CFHTTPMessageAppendBytes(httpMessage, [data bytes], [data length]);
//}
//
//- (void)setHeaderField:(NSString *)headerField value:(NSString *)headerFieldValue{
//    
//    CFHTTPMessageSetHeaderFieldValue(httpMessage, (__bridge CFStringRef)(headerField), (__bridge CFStringRef)(headerFieldValue));
//    
//}
//
//- (NSData *)transferHttpData{
//    
//    return (__bridge_transfer NSData *)CFHTTPMessageCopySerializedMessage(httpMessage);
//}
//
//- (NSData *)transferHttpBody{
//    return (__bridge_transfer NSData *)CFHTTPMessageCopyBody(httpMessage);
//}
//
//
//- (void)dealloc{
//    CFRelease(httpMessage);
//}

@end
