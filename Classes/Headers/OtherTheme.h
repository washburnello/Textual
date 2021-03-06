// Created by Satoshi Nakagawa <psychs AT limechat DOT net> <http://github.com/psychs/limechat>
// Modifications by Codeux Software <support AT codeux DOT com> <https://github.com/codeux/Textual>
// You can redistribute it and/or modify it under the new BSD license.
// Converted to ARC Support on Thursday, June 07, 2012

#define THEME_DISABLED_INDENTATION_OFFSET     -99

@interface OtherTheme : NSObject
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSFont *channelViewFont;
@property (nonatomic, strong) NSString *nicknameFormat;
@property (nonatomic, strong) NSString *timestampFormat;
@property (nonatomic, assign) BOOL channelViewFontOverrode;
@property (nonatomic, strong) NSColor *underlyingWindowColor;
@property (nonatomic, assign) NSDoubleN indentationOffset;
@property (nonatomic, assign) NSDoubleN renderingEngineVersion;

- (void)reload;
@end