//
//  CuteHttpResponse.h
//  Cute-FileUpload
//
//  Created by qinzhiwei on 15/7/20.
//  Copyright (c) 2015年 qinzhiwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CuteHttpResponse : NSObject

- (void)handleResponseWithWriteStream:(NSOutputStream *)outputStream receiveData:(NSData *)data;

@end
