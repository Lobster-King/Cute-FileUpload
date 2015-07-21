//
//  CuteHttpResponse.m
//  Cute-FileUpload
//
//  Created by qinzhiwei on 15/7/20.
//  Copyright (c) 2015年 qinzhiwei. All rights reserved.
//

#import "CuteHttpResponse.h"
#import "CuteHttpMessage.h"

#define WRITE_BUFFER    1024

@interface CuteHttpResponse ()
{
    CFHTTPMessageRef httpRequestMessage;
    CFHTTPMessageRef httpResponseMessage;
}

@property (nonatomic, retain)NSOutputStream *outputStream;

@end

@implementation CuteHttpResponse

- (id)init{
    self = [super init];
    if (self) {
        
        httpRequestMessage = CFHTTPMessageCreateEmpty(NULL, YES);
        httpResponseMessage= CFHTTPMessageCreateResponse(kCFAllocatorDefault, 200, NULL, kCFHTTPVersion1_1);
    }
    return self;
}

- (void)handleResponseWithWriteStream:(NSOutputStream *)outputStream receiveData:(NSData *)data{
    
    self.outputStream = outputStream;
    
    CFHTTPMessageAppendBytes(httpRequestMessage, [data bytes], [data length]);
    NSURL *url = (__bridge NSURL *)(CFHTTPMessageCopyRequestURL(httpRequestMessage));
    NSString *relativeString = [url relativeString];
    
    NSString *filePath = [[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"web"] stringByDeletingLastPathComponent];
    
    if ([relativeString isEqualToString:@"/"]) {
        
        filePath = [filePath stringByAppendingString:@"/index.html"];
        
    }else{
        
        filePath = [filePath stringByAppendingString:[url relativeString]];
    }
    
    NSData *responseData = [NSData dataWithContentsOfFile:filePath];
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    
    NSInteger fileLength = (UInt64)[[fileAttributes objectForKey:NSFileSize] unsignedLongLongValue];
    CFHTTPMessageSetHeaderFieldValue(
                                     httpResponseMessage, (CFStringRef)@"Connection", (CFStringRef)@"close");
    CFHTTPMessageSetHeaderFieldValue(
                                     httpResponseMessage,
                                     (CFStringRef)@"Content-Length",
                                     (__bridge CFStringRef)[NSString stringWithFormat:@"%ld", fileLength]);
    CFDataRef headerData = CFHTTPMessageCopySerializedMessage(httpResponseMessage);
    
    [self writeData:(__bridge NSData *)(headerData)];
    [self writeData:responseData];
    
}

- (NSUInteger)writeData:(NSData *)outData{
    
    NSUInteger offset           = 0;
    NSUInteger bytesWritten     = 0;
    NSUInteger remainingLength  = [outData length];
    NSUInteger bufferSize = MIN(WRITE_BUFFER, remainingLength);
    
    void *bytes = malloc(bufferSize * sizeof(void*));
    while (remainingLength > 0) {
        NSRange range = NSMakeRange(offset, bufferSize);
        [outData getBytes:bytes range: range];
        
        bytesWritten = [self.outputStream write:bytes maxLength:bufferSize];
        if(bytesWritten == -1){
            break;
        }
        remainingLength -= bytesWritten;
        offset += bytesWritten;
        bufferSize = MIN(WRITE_BUFFER, remainingLength);
    }
    
    free(bytes);
    
    return bytesWritten;
}

- (void)dealloc{
    
    CFRelease(httpRequestMessage);
    CFRelease(httpResponseMessage);
    NSLog(@"%s",__func__);
    
}

@end
