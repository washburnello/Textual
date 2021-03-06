// Modifications by Codeux Software <support AT codeux DOT com> <https://github.com/codeux/Textual>
// You can redistribute it and/or modify it under the new BSD license.
// Converted to ARC Support on Thursday, June 08, 2012

typedef enum {
	IRCTextFormatterBoldEffect,
	IRCTextFormatterItalicEffect,
	IRCTextFormatterUnderlineEffect,
	IRCTextFormatterForegroundColorEffect,
	IRCTextFormatterBackgroundColorEffect,
} IRCTextFormatterEffectType; 

#define MAXIMUM_FORMATTING_LENGTH   300

@interface NSAttributedString (IRCTextFormatter)
- (NSString *)attributedStringToASCIIFormatting;
- (NSString *)attributedStringToASCIIFormatting:(NSMutableAttributedString **)string 
                                       lineType:(LogLineType)type 
                                        channel:(NSString *)chan 
                                       hostmask:(NSString *)host;
@end

@interface TextField (TextFieldFormattingHelper) 
- (void)sanitizeIRCCompatibleAttributedString:(BOOL)clearAttributes;

- (BOOL)IRCFormatterAttributeSetInRange:(IRCTextFormatterEffectType)effect 
                                  range:(NSRange)limitRange;

- (void)setIRCFormatterAttribute:(IRCTextFormatterEffectType)effect 
                           value:(id)value 
                           range:(NSRange)limitRange;

- (void)removeIRCFormatterAttribute:(IRCTextFormatterEffectType)effect 
                              range:(NSRange)limitRange 
                              color:(NSColor *)defaultColor;
@end