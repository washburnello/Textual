// Created by Satoshi Nakagawa <psychs AT limechat DOT net> <http://github.com/psychs/limechat>
// You can redistribute it and/or modify it under the new BSD license.
// Converted to ARC Support on Thursday, June 08, 2012

@interface Timer : NSObject
@property (nonatomic, unsafe_unretained) id delegate;
@property (nonatomic, assign) BOOL reqeat;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, readonly) BOOL isActive;
@property (nonatomic, strong) NSTimer *timer;

- (void)start:(NSTimeInterval)interval;
- (void)stop;
@end

@interface NSObject (TimerDelegate)
- (void)timerOnTimer:(Timer *)sender;
@end