//
//  CuteHttpClient.h
//  Cute-FileUpload
//
//  Created by qinzhiwei on 15/7/20.
//  Copyright (c) 2015年 qinzhiwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CuteHttpClient;

@protocol ZWCuteClientDelegate <NSObject>

- (void)zwClientHandleComplete:(CuteHttpClient *)client;

@end

@interface CuteHttpClient : NSObject

@property (nonatomic, assign)id <ZWCuteClientDelegate> delegate;

@property (nonatomic, retain)NSString       *peerName;

- (id)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream peer:(NSString *)peer delegate:(id<ZWCuteClientDelegate>)delegate;

- (void)fireStreamService;

@end
