// Created by Satoshi Nakagawa <psychs AT limechat DOT net> <http://github.com/psychs/limechat>
// Modifications by Codeux Software <support AT codeux DOT com> <https://github.com/codeux/Textual>
// You can redistribute it and/or modify it under the new BSD license.
// Converted to ARC Support on Thursday, June 09, 2012

@implementation InviteSheet

@synthesize delegate;
@synthesize nicks;
@synthesize uid;
@synthesize titleLabel;
@synthesize channelPopup;

- (id)init
{
	if ((self = [super init])) {
		[NSBundle loadNibNamed:@"InviteSheet" owner:self];
	}

	return self;
}

- (void)startWithChannels:(NSArray *)channels
{
	NSString *target = nil;
	
	if (self.nicks.count == 1) {
		target = [self.nicks safeObjectAtIndex:0];
	} else if (self.nicks.count == 2) {
		NSString *first = [self.nicks safeObjectAtIndex:0];
		NSString *second = [self.nicks safeObjectAtIndex:1];
		
		target = TXTFLS(@"INVITE_SHEET_TWO_PEOPLE", first, second);
	} else {
		target = TXTFLS(@"INVITE_SHEET_MULTIPLE_PEOPLE", self.nicks.count);
	}
	
	self.titleLabel.stringValue = TXTFLS(@"INVITE_SHEET_TARGET_DESC", target);
	
	for (NSString *s in channels) {
		[self.channelPopup addItemWithTitle:s];
	}
	
	[self startSheet];
}

- (void)invite:(id)sender
{
	NSString *channelName = [self.channelPopup selectedItem].title;
	
	if ([self.delegate respondsToSelector:@selector(inviteSheet:onSelectChannel:)]) {
		[self.delegate inviteSheet:self onSelectChannel:channelName];
	}
	
	[self endSheet];
}

#pragma mark -
#pragma mark NSWindow Delegate

- (void)windowWillClose:(NSNotification *)note
{
	if ([self.delegate respondsToSelector:@selector(inviteSheetWillClose:)]) {
		[self.delegate inviteSheetWillClose:self];
	}
}

@end