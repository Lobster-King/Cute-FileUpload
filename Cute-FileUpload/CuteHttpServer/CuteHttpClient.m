//
//  CuteHttpClient.m
//  Cute-FileUpload
//
//  Created by qinzhiwei on 15/7/20.
//  Copyright (c) 2015年 qinzhiwei. All rights reserved.
//

#import "CuteHttpClient.h"
#import "CuteHttpMessage.h"
#import "CuteHttpResponse.h"

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
            break;
        }
        case NSStreamEventHasBytesAvailable:
        {
            
            if (stream == self.inputStream) {
                
                NSData * data = [self receiveData];
                
                if (data.length > 0) {
                    
                    //handle recived data
                    
                    CuteHttpResponse *response = [[CuteHttpResponse alloc]init];
                    [response handleResponseWithWriteStream:self.outputStream receiveData:data];
                    
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
