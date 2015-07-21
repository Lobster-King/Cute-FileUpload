//
//  CuteHttpClient.m
//  Cute-FileUpload
//
//  Created by qinzhiwei on 15/7/20.
//  Copyright (c) 2015年 qinzhiwei. All rights reserved.
//

#import "CuteHttpClient.h"
#import "CuteHttpMessage.h"

#define READ_BUFFER     2048
#define WRITE_BUFFER    1024

@interface CuteHttpClient ()<NSStreamDelegate>

@property (nonatomic, retain)NSInputStream  *inputStream;
@property (nonatomic, retain)NSOutputStream *outputStream;
@property (nonatomic, assign)BOOL           keepRunning;

@end

@implementation CuteHttpClient

- (id)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream peer:(NSString *)peer delegate:(id<ZWCuteClientDelegate>)delegate{
    
    self = [super init];
    if (self) {
        
        self.inputStream    = inputStream;
        self.outputStream   = outputStream;
        self.peerName       = peer;
        self.delegate       = delegate;
        
    }
    return self;
}

- (void)fireStreamService{
    
    if (self.inputStream && self.outputStream) {
        
        self.inputStream.delegate   = self;
        [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [self.inputStream open];
        
        self.outputStream.delegate  = self;
        [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [self.outputStream open];
        
        self.keepRunning = YES;
        
        while(self.keepRunning && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.0]]){
            
        }
        
    }
    
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    switch(eventCode) {
        case NSStreamEventOpenCompleted:
        {
            
            break;
        }
        case NSStreamEventHasSpaceAvailable:
        {
            //response data
            if (stream == self.outputStream) {
                
                //                //                NSString *responseString = @"HTTP/1.1 200 OK\nServer: ZWServer\nAccess-Control-Allow-Origin:*\nConnection: close\nContent-Length: 8\nContent-Type: text/html; charset=utf-8\n\nresponse";
                //
                //                NSString *filePath = [[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"web"] stringByDeletingLastPathComponent];
                //                filePath = [filePath stringByAppendingString:@"/index.html"];
                //
                //                NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
                //
                //                NSInteger fileLength = (UInt64)[[fileAttributes objectForKey:NSFileSize] unsignedLongLongValue];
                //
                //                NSData *data = [NSData dataWithContentsOfFile:filePath];
                //
                //
                ////                HTTPMessage *http = [[HTTPMessage alloc]initResponseWithStatusCode:200 description:@"HTTP" version:@"1.1"];
                ////                [http setHeaderField:@"Content-Length" value:[NSString stringWithFormat:@"%ld",fileLength]];
                ////                [http setHeaderField:@"Content-Type" value:@"text/html; charset=utf-8"];
                ////                [http setHeaderField:@"Connection" value:@"close"];
                //
                //                CuteHttpMessage *httpMessage = [[CuteHttpMessage alloc]init];
                //
                //                [httpMessage appendHeaderField:@"Content-Length" headerValue:[NSString stringWithFormat:@"%ld",fileLength]];
                //
                //                // wirite http header
                //                [self writeData:[httpMessage httpHeaderMessageData]];
                //
                //                // write http body
                //                [self writeData:data];
                //                //                if (6 == length) {
                //                [self.outputStream close];
                //                [self.delegate zwClientHandleComplete:self];
                //                }
                
            }
            
            break;
        }
        case NSStreamEventHasBytesAvailable:
        {
            
            if (stream == self.inputStream) {
                
                NSData * data = [self receiveData];
                
                if (data.length > 0) {
                    
                    //handle recived data
                    
                    CuteHttpMessage *requestMessage = [[CuteHttpMessage alloc]init];
                    [requestMessage appendBytes:data];
                    NSURL *url = [requestMessage requestUrl];
                    
                    NSString *filePath = [[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"web"] stringByDeletingLastPathComponent];
                    
                    NSLog(@"url++++++++++++++++%@",[url relativeString]);
                    if ([[url relativeString] isEqualToString:@"/"]) {
                        
                        filePath = [filePath stringByAppendingString:@"/index.html"];
                        
                    }else{
                        
                        filePath = [filePath stringByAppendingString:[url relativeString]];
                    }
                    
                    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
                    
                    NSInteger fileLength = (UInt64)[[fileAttributes objectForKey:NSFileSize] unsignedLongLongValue];
                    
                    
                    CuteHttpMessage *httpMessage = [[CuteHttpMessage alloc]init];
                    
                    [httpMessage appendHeaderField:@"Content-Length" headerValue:[NSString stringWithFormat:@"%ld",fileLength]];
                    
                    // wirite http header
                    [self writeData:[httpMessage httpHeaderMessageData]];
                    
                    NSData *data = [NSData dataWithContentsOfFile:filePath];
                    
                    [self writeData:data];
                    
//                    if ([data length] == length) {
//                        
//                        [self.outputStream close];
//                        
//                    }
                    
                }
            }
            break;
        }
        case NSStreamEventEndEncountered:
        {
            
            [self stopStreamService];
            
            break;
        }
        case NSStreamEventErrorOccurred:
        {
            
            [self stopStreamService];
            break;
            
        }
        default:
            break;
    }
}

- (NSDictionary *)getParametersDictionaryWithParams:(NSString *)params {
    NSString * urlEncodedJsonString = [[params componentsSeparatedByString:@"="] lastObject];
    NSString *jsonString = [urlEncodedJsonString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSData * jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError * thisError = nil;
    NSDictionary * paramsDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&thisError];
    
    return paramsDic;
}

- (NSData *)receiveData{
    
    NSMutableData * retBlob = nil;
    
    if(!retBlob) {
        retBlob = [NSMutableData data];
    }
    
    uint8_t buffer[2048];
    
    long length    = 0;
    
    while ([self.inputStream hasBytesAvailable]) {
        
        length = [self.inputStream read:buffer maxLength:2048];
        
        if(length > 0) {
            
            [retBlob appendBytes:(const void *)buffer length:length];
            
        } else {
            
            NSLog(@"we have read the end of data!");
            
            break;
        }
    }
    
    return retBlob;
    
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

- (void)stopStreamService{
    
    [_inputStream close];
    [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    [_outputStream close];
    [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    _inputStream        = nil;
    _outputStream       = nil;
    self.keepRunning    = NO;
    
}

- (void)dealloc{
    
    [self stopStreamService];
    NSLog(@"%s",__func__);
}

@end
