// Created by Satoshi Nakagawa <psychs AT limechat DOT net> <http://github.com/psychs/limechat>
// You can redistribute it and/or modify it under the new BSD license.
// Converted to ARC Support on Thursday, June 09, 2012

@interface TopicSheet : SheetBase
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, assign) NSInteger cid;
@property (nonatomic, strong) TextField *text;
@property (nonatomic, strong) NSTextField *header;

- (void)start:(NSString *)topic;
@end

@interface NSObject (TopicSheetDelegate)
- (void)topicSheet:(TopicSheet *)sender onOK:(NSString *)topic;
- (void)topicSheetWillClose:(TopicSheet *)sender;
@end