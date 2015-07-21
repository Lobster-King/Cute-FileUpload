//
//  CuteHttpServer.m
//  Cute-FileUpload
//
//  Created by qinzhiwei on 15/7/20.
//  Copyright (c) 2015年 qinzhiwei. All rights reserved.
//

#import "CuteHttpServer.h"

#include <ifaddrs.h>
#include <arpa/inet.h>
#import "CuteHttpClient.h"

#define kPort   5299

@interface CuteHttpServer ()<ZWCuteClientDelegate>
{
    
}

@property (nonatomic, retain)NSMutableArray     *connections;
@property (nonatomic, assign)CFSocketRef        ipV4Socket;
@property (nonatomic, copy  )NSString           *ipString;
@property (nonatomic, retain)NSOperationQueue   *serverQueue;

@end

@implementation CuteHttpServer

- (NSMutableArray *)connections{
    if (!_connections) {
        _connections = [NSMutableArray array];
    }
    return _connections;
}

- (NSOperationQueue *)serverQueue{
    if (!_serverQueue) {
        _serverQueue = [[NSOperationQueue alloc]init];
    }
    return _serverQueue;
}

#pragma mark    Server Start

- (void)serverStart{
    
    struct sockaddr_in serverAddress;
    socklen_t nameLen = 0;
    nameLen = sizeof(serverAddress);
    
    if (!_ipV4Socket) {
        
        //socket context,OS may use it to change context.
        
        CFSocketContext socketCtxt = {0, (__bridge void *)(self), NULL, NULL, NULL};
        
        // create ipV4Socket.
        
        self.ipV4Socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack)&ZWLightWeightServerAcceptCallBack, &socketCtxt);
        
        if (!_ipV4Socket) {
            
            // if failed send error msg to server's delegate.
            
            if ([self.delegate respondsToSelector:@selector(zwServerStartFailedWithError:)]) {
                
                [self.delegate zwServerStartFailedWithError:kZWCuteServerNoSocketsAvailable];
            }
            
            // stop and release resources.
            
            [self serverStop];
            
            return;
        }
        
        int yes = 1;
        
        setsockopt(CFSocketGetNative(_ipV4Socket), SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));
        
        // setup ipV4 params.
        
        memset(&serverAddress, 0, sizeof(serverAddress));
        serverAddress.sin_len = nameLen;
        serverAddress.sin_family = AF_INET;
        serverAddress.sin_port = htons(kPort);//listen 5299 port
        serverAddress.sin_addr.s_addr = htonl(INADDR_ANY);
        NSData * address4 = [NSData dataWithBytes:&serverAddress length:nameLen];
        
        if (kCFSocketSuccess != CFSocketSetAddress(_ipV4Socket, (CFDataRef)address4)) {
            
            if ([self.delegate respondsToSelector:@selector(zwServerStartFailedWithError:)]) {
                [self.delegate zwServerStartFailedWithError:kZWCuteServerCouldNotBindToIPv4Address];
            }
            
            if (_ipV4Socket){
                
                CFRelease(_ipV4Socket);
                
            }
            _ipV4Socket = NULL;
            
            [self serverStop];
            
            return;
        }
        
        if ([self.delegate respondsToSelector:@selector(zwServerStartSuccessfullyIpString:port:)]) {
            
            [self.delegate zwServerStartSuccessfullyIpString:self.ipString port:@"5299"];
            
        }
        
        // here we have create a ipV4 socket successfully.
        // set up the run loop sources for the sockets.
        CFRunLoopRef cfrl = CFRunLoopGetCurrent();
        CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _ipV4Socket, 0);
        CFRunLoopAddSource(cfrl, source, kCFRunLoopCommonModes);
        CFRelease(source);
        
    }
    
}

- (NSString *)ipString{
    
    if (!_ipString) {
        
        NSString            *address = @"error";
        struct ifaddrs      *interfaces = NULL;
        struct ifaddrs      *temp_addr = NULL;
        int                 success = 0;
        
        // retrieve the current interfaces - returns 0 on success
        success = getifaddrs(&interfaces);
        if (success == 0) {
            // Loop through linked list of interfaces
            temp_addr = interfaces;
            while (temp_addr != NULL) {
                if( temp_addr->ifa_addr->sa_family == AF_INET) {
                    // Check if interface is en0 which is the wifi connection on the iPhone
                    if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                        // Get NSString from C String
                        address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    }
                }
                
                temp_addr = temp_addr->ifa_next;
            }
        }
        
        // Free memory
        freeifaddrs(interfaces);
        _ipString = address;
        
    }
    return _ipString;
}

#pragma mark    CallBack

static void ZWLightWeightServerAcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info){
    
    CuteHttpServer *lightWeight = (__bridge CuteHttpServer *)info;
    
    if ([lightWeight.delegate respondsToSelector:@selector(zwServerRecivedNewClient:)]) {
        [lightWeight.delegate zwServerRecivedNewClient:nil];
    }
    
    if (type == kCFSocketAcceptCallBack) {
        // for an AcceptCallBack , the data param is a pointer to a CFSocketNativeHandle
        CFSocketNativeHandle nativeHandler  = *(CFSocketNativeHandle *)data;
        struct sockaddr_in                  peerAddress ;
        socklen_t peerlen                   = sizeof(peerAddress);
        NSString * peer                     = nil;
        
        if (getpeername(nativeHandler, (struct sockaddr *)&peerAddress, (socklen_t *)&peerlen) == 0) {
            
            peer = [NSString stringWithUTF8String:inet_ntoa(peerAddress.sin_addr)];
            
        }else{
            
            peer = @"normal peer";
            
        }
        //C level api for data stream
        CFReadStreamRef     readStream  = NULL;
        CFWriteStreamRef    writeStream = NULL;
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeHandler, &readStream, &writeStream);
        
        if (readStream && writeStream) {
            
            CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            // change to high level api to handle data
            [lightWeight handleClient:peer inputStream:(__bridge NSInputStream *)readStream outputStream:(__bridge NSOutputStream *)(writeStream)];
            
        }else{
            
            // if failed we should close it
            close(nativeHandler);
            
        }
        
        //release C level Stream
        
        if (readStream) {
            CFRelease(readStream);
        }
        
        if (writeStream) {
            CFRelease(writeStream);
        }
    }
    
}

#pragma mark    Handle Client

- (void)handleClient:(NSString *)peerName inputStream:(NSInputStream *)readStream outputStream:(NSOutputStream *)writeStream{
    
    __weak __typeof(&*self)weakSelf = self;
    
    if (peerName != nil && readStream != nil && writeStream != nil) {
        
        // here we should handle a new client in a queue
        
        [self.serverQueue addOperationWithBlock:^{
            
            CuteHttpClient *client = [[CuteHttpClient alloc]initWithInputStream:readStream outputStream:writeStream peer:peerName delegate:self];
            
            // we add the client to a array
            [weakSelf.connections addObject:client];
            
            [client fireStreamService];
            
        }];
        
    }
    
}

#pragma mark    ClientDelegate
- (void)zwClientHandleComplete:(CuteHttpClient *)client{
    
    [self.connections enumerateObjectsUsingBlock:^(CuteHttpClient *obj, NSUInteger idx, BOOL *stop) {
        
        if ([obj.peerName isEqualToString:client.peerName]) {
            *stop = YES;
            [self.connections removeObject:obj];
        }
        
    }];
    
}

#pragma mark    ServerStop

- (void)serverStop{
    
    // invalidate the socket
    if (self.ipV4Socket) {
        CFSocketInvalidate(self.ipV4Socket);
        CFRelease(self.ipV4Socket);
        self.ipV4Socket = NULL;
    }
    
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}


@end
