// Created by Satoshi Nakagawa <psychs AT limechat DOT net> <http://github.com/psychs/limechat>
// Modifications by Codeux Software <support AT codeux DOT com> <https://github.com/codeux/Textual>
// You can redistribute it and/or modify it under the new BSD license.
// Converted to ARC Support on Thursday, June 09, 2012

#define TABLE_ROW_TYPE			@"row"
#define TABLE_ROW_TYPES			[NSArray arrayWithObject:TABLE_ROW_TYPE]

#define TIMEOUT_INT_MIN     0
#define TIMEOUT_INT_MAX     360

@interface ServerSheet (Private)
- (void)load;
- (void)save;
- (void)updateConnectionPage;
- (void)updateChannelsPage;
- (void)reloadChannelTable;
- (void)updateIgnoresPage;
- (void)reloadIgnoreTable;
- (void)focusView:(NSView *)view atRow:(NSInteger)row;
@end

@implementation ServerSheet

@synthesize delegate;
@synthesize okButton;
@synthesize sheet;
@synthesize generalView;
@synthesize identityView;
@synthesize messagesView;
@synthesize encodingView;
@synthesize autojoinView;
@synthesize ignoresView;
@synthesize commandsView;
@synthesize floodControlView;
@synthesize floodControlToolView;
@synthesize proxyServerView;
@synthesize addChannelButton;
@synthesize addIgnoreButton;
@synthesize altNicksText;
@synthesize prefersIPv6Check;
@synthesize autoConnectCheck;
@synthesize bouncerModeCheck;
@synthesize autoReconnectCheck;
@synthesize channelSheet;
@synthesize channelTable;
@synthesize client;
@synthesize config;
@synthesize contentView;
@synthesize deleteChannelButton;
@synthesize deleteIgnoreButton;
@synthesize editChannelButton;
@synthesize editIgnoreButton;
@synthesize encodingCombo;
@synthesize fallbackEncodingCombo;
@synthesize hostCombo;
@synthesize ignoreSheet;
@synthesize ignoreTable;
@synthesize invisibleCheck;
@synthesize addIgnoreMenu;
@synthesize leavingCommentText;
@synthesize loginCommandsText;
@synthesize nameText;
@synthesize nickPasswordText;
@synthesize nickText;
@synthesize passwordText;
@synthesize portText;
@synthesize proxyCombo;
@synthesize proxyHostText;
@synthesize proxyPasswordText;
@synthesize proxyPortText;
@synthesize proxyUserText;
@synthesize realNameText;
@synthesize sleepQuitMessageText;
@synthesize sslCheck;
@synthesize tabView;
@synthesize uid;
@synthesize usernameText;
@synthesize floodControlDelayTimer;
@synthesize floodControlMessageCount;
@synthesize outgoingFloodControl;
@synthesize tabViewList;
@synthesize serverList;

- (id)init
{
	if ((self = [super init])) {
		self.tabViewList = [NSMutableArray new];
		
		[self.tabViewList addObject:[NSArray arrayWithObjects:@"GENERAL",				@"1", NSNumberWithBOOL(NO), nil]];
		[self.tabViewList addObject:[NSArray arrayWithObjects:@"IDENTITY",				@"2", NSNumberWithBOOL(NO), nil]];
		[self.tabViewList addObject:[NSArray arrayWithObjects:@"MESSAGES",				@"3", NSNumberWithBOOL(NO), nil]];
		[self.tabViewList addObject:[NSArray arrayWithObjects:@"ENCODING",				@"4", NSNumberWithBOOL(NO), nil]];
		[self.tabViewList addObject:[NSArray arrayWithObjects:@"AUTOJOIN",				@"5", NSNumberWithBOOL(NO), nil]];
		[self.tabViewList addObject:[NSArray arrayWithObjects:@"IGNORES",				@"6", NSNumberWithBOOL(NO), nil]];
		[self.tabViewList addObject:[NSArray arrayWithObjects:@"COMMANDS",				@"7", NSNumberWithBOOL(NO), nil]];
		[self.tabViewList addObject:[NSArray arrayWithObjects:ListSeparatorCellIndex,	@"-", NSNumberWithBOOL(NO), nil]];
		[self.tabViewList addObject:[NSArray arrayWithObjects:@"PROXY",					@"8", NSNumberWithBOOL(NO), nil]];
		[self.tabViewList addObject:[NSArray arrayWithObjects:@"FLOODC",					@"9", NSNumberWithBOOL(NO), nil]];
		
		[NSBundle loadNibNamed:@"ServerSheet" owner:self];
		
		self.serverList = [NSDictionary dictionaryWithContentsOfFile:[[Preferences whereResourcePath] stringByAppendingPathComponent:@"IRCNetworks.plist"]];
		
		NSArray *sortedKeys = [[self.serverList allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
		
		for (NSString *key in sortedKeys) {
			[self.hostCombo addItemWithObjectValue:key];
		}
		
		[self.leavingCommentText	setFont:[NSFont systemFontOfSize:13.0]];
		[self.sleepQuitMessageText	setFont:[NSFont systemFontOfSize:13.0]];
		[self.loginCommandsText		setFont:[NSFont systemFontOfSize:13.0]];
	}
    
	return self;
}


#pragma mark -
#pragma mark Server List Factory

- (NSString *)nameMatchesServerInList:(NSString *)name
{
	for (NSString *key in self.serverList) {
		if ([name isEqualNoCase:key]) {
			return key;
		}
	}
	
	return nil;
}

- (NSString *)hostFoundInServerList:(NSString *)hosto
{
	for (NSString *key in self.serverList) {
		NSString *host = [self.serverList objectForKey:key];
		
		if ([hosto isEqualNoCase:host]) {
			return key;
		}
	}
	
	return nil;
}

#pragma mark -
#pragma mark Initalization Handler

- (void)startWithIgnoreTab:(NSString *)imask
{
	[self.channelTable setTarget:self];
	[self.channelTable setDoubleAction:@selector(tableViewDoubleClicked:)];
	[self.channelTable registerForDraggedTypes:TABLE_ROW_TYPES];
	
	[self.ignoreTable setTarget:self];
	[self.ignoreTable setDoubleAction:@selector(tableViewDoubleClicked:)];
	[self.ignoreTable registerForDraggedTypes:TABLE_ROW_TYPES];
	
	[self load];
	
	[self updateConnectionPage];
	[self updateChannelsPage];
	[self updateIgnoresPage];
	[self encodingChanged:nil];
	[self proxyChanged:nil];
	[self reloadChannelTable];
	[self reloadIgnoreTable];
	
	if (NSObjectIsNotEmpty(imask)) {
		[self showWithDefaultView:self.ignoresView andSegment:5];
		
		if ([imask isEqualToString:@"-"] == NO) {
			self.ignoreSheet = nil;
			
			self.ignoreSheet = [AddressBookSheet new];
			self.ignoreSheet.delegate = self;
			self.ignoreSheet.window = self.sheet;
			self.ignoreSheet.newItem = YES;
			
			self.ignoreSheet.ignore = [AddressBook new];
            
            if ([imask isEqualToString:@"--"]) {
				self.ignoreSheet.ignore.hostmask = @"<nickname>";
            } else {
				self.ignoreSheet.ignore.hostmask = imask;
			}
            
            [self.ignoreSheet.ignore processHostMaskRegex];
			[self.ignoreSheet start];
		}
	} else {
		[self show];
	}
}

- (void)show
{
	[self showWithDefaultView:self.generalView andSegment:0];
}

- (void)showWithDefaultView:(NSView *)view andSegment:(NSInteger)segment
{
	[self startSheet];
	[self focusView:view atRow:segment];
}

- (void)focusView:(NSView *)view atRow:(NSInteger)row
{
	if (NSObjectIsNotEmpty([self.contentView subviews])) {
		[[[self.contentView subviews] safeObjectAtIndex:0] removeFromSuperview];
	}
	
	[self.contentView addSubview:view];
	[self.tabView selectItemAtIndex:row];
	
	[self.window recalculateKeyViewLoop];
}

- (void)close
{
	self.delegate = nil;
	
	[self endSheet];
}

- (void)load
{
	/* General */
	self.nameText.stringValue		= self.config.name;
	self.hostCombo.stringValue		= (([self hostFoundInServerList:self.config.host]) ?: self.config.host);
	self.passwordText.stringValue	= self.config.password;
	self.portText.integerValue		= self.config.port;
	self.sslCheck.state				= self.config.useSSL;
	self.bouncerModeCheck.state		= self.config.bouncerMode;
	self.autoConnectCheck.state		= self.config.autoConnect;
	self.autoReconnectCheck.state	= self.config.autoReconnect;
    self.prefersIPv6Check.state     = self.config.prefersIPv6;
	
	/* Identity */
	if (NSObjectIsEmpty(self.config.nick)) {
		self.nickText.stringValue = [Preferences defaultNickname];
	} else {
		self.nickText.stringValue = self.config.nick;
	}
	
	if (NSObjectIsEmpty(self.config.username)) {
		self.usernameText.stringValue = [Preferences defaultUsername];
	} else {
		self.usernameText.stringValue = self.config.username;
	}
	
	if (NSObjectIsEmpty(self.config.realName)) {
		self.realNameText.stringValue = [Preferences defaultRealname];
	} else {
		self.realNameText.stringValue = self.config.realName;
	}
	
	if (self.config.altNicks.count > 0) {
		self.altNicksText.stringValue = [self.config.altNicks componentsJoinedByString:NSWhitespaceCharacter];
	} else {
		self.altNicksText.stringValue = NSNullObject;
	}
	
	self.nickPasswordText.stringValue = self.config.nickPassword;
	
	/* Messages */
	self.sleepQuitMessageText.string = self.config.sleepQuitMessage;
	self.leavingCommentText.string	= self.config.leavingComment;
	
	/* Encoding */
	[self.encodingCombo			selectItemWithTag:self.config.encoding];
	[self.fallbackEncodingCombo	selectItemWithTag:self.config.fallbackEncoding];
	
	/* Proxy Server */
	[self.proxyCombo selectItemWithTag:self.config.proxyType];
	
	self.proxyHostText.stringValue		= self.config.proxyHost;
	self.proxyPortText.integerValue		= self.config.proxyPort;
	self.proxyUserText.stringValue		= self.config.proxyUser;
	self.proxyPasswordText.stringValue	= self.config.proxyPassword;
	
	/* Connect Commands */
	self.invisibleCheck.state		= self.config.invisibleMode;
	self.loginCommandsText.string	= [self.config.loginCommands componentsJoinedByString:NSNewlineCharacter];
    
    /* Flood Control */
    self.floodControlDelayTimer.integerValue     = self.config.floodControlDelayTimerInterval;
    self.floodControlMessageCount.integerValue   = self.config.floodControlMaximumMessages;
    self.outgoingFloodControl.state              = self.config.outgoingFloodControl;
    
    [self floodControlChanged:nil];
}

- (void)save
{
	/* General */
	self.config.autoConnect		= self.autoConnectCheck.state;
	self.config.autoReconnect	= self.autoReconnectCheck.state;
	self.config.bouncerMode		= self.bouncerModeCheck.state;
	self.config.prefersIPv6     = self.prefersIPv6Check.state;
	
	NSString *realHost		= nil;
	NSString *hostname		= [self.hostCombo.stringValue cleanedServerHostmask];
	
	if (NSObjectIsEmpty(hostname)) {
		self.config.host = @"localhost";
	} else {
		realHost = [self nameMatchesServerInList:hostname];
		
		if (NSObjectIsEmpty(realHost)) {
			self.config.host = hostname;
		} else {
			self.config.host = [self.serverList objectForKey:realHost];
		}
	}
	
	if (NSObjectIsEmpty(self.nameText.stringValue)) {
		if (NSObjectIsEmpty(realHost)) {
			self.config.name = TXTLS(@"UNTITLED_CONNECTION_NAME");
		} else {
			self.config.name = realHost;
		}
	} else {
		self.config.name = self.nameText.stringValue;
	}
	
	if (self.portText.integerValue < 1) {
		self.config.port = 6667;
	} else {
		self.config.port = self.portText.integerValue;
	}
	
	self.config.useSSL = self.sslCheck.state;
	
	/* Identity */
	self.config.nick				= self.nickText.stringValue;
	self.config.password			= self.passwordText.stringValue;
	self.config.username			= self.usernameText.stringValue;
	self.config.realName			= self.realNameText.stringValue;
	self.config.nickPassword		= self.nickPasswordText.stringValue;
	
	NSArray *nicks = [self.altNicksText.stringValue componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	[self.config.altNicks removeAllObjects];
	
	for (NSString *s in nicks) {
		if (NSObjectIsNotEmpty(s)) {
			[self.config.altNicks safeAddObject:s];
		}
	}
	
	/* Messages */
	self.config.sleepQuitMessage = self.sleepQuitMessageText.string;
	self.config.leavingComment = self.leavingCommentText.string;
	
	/* Encoding */
	self.config.encoding = self.encodingCombo.selectedTag;
	self.config.fallbackEncoding = self.fallbackEncodingCombo.selectedTag;
	
	/* Proxy Server */
	self.config.proxyType = self.proxyCombo.selectedTag;
	self.config.proxyHost = self.proxyHostText.stringValue;
	self.config.proxyPort = self.proxyPortText.intValue;
	self.config.proxyUser = self.proxyUserText.stringValue;
	self.config.proxyPassword = self.proxyPasswordText.stringValue;
	
	/* Connect Commands */
    NSArray *commands = [self.loginCommandsText.string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	
	[self.config.loginCommands removeAllObjects];
    
	for (NSString *s in commands) {
		if (NSObjectIsNotEmpty(s)) {
			[self.config.loginCommands safeAddObject:s];
		}
	}
	
	self.config.invisibleMode = self.invisibleCheck.state;
    
    /* Flood Control */
    self.config.floodControlMaximumMessages      = self.floodControlMessageCount.integerValue;
    self.config.floodControlDelayTimerInterval   = self.floodControlDelayTimer.integerValue;
    self.config.outgoingFloodControl             = self.outgoingFloodControl.state;
}

- (void)updateConnectionPage
{
	NSString *name = [self.nameText stringValue];
	NSString *host = [self.hostCombo stringValue];
	NSString *nick = [self.nickText stringValue];
	
	NSInteger port = [self.portText integerValue];
	
	BOOL enabled = (NSObjectIsNotEmpty(name) && NSObjectIsNotEmpty(host) &&
					[host isEqualToString:@"-"] == NO && port > 0 && NSObjectIsNotEmpty(nick));
	
	[self.okButton setEnabled:enabled];
}

- (void)updateChannelsPage
{
	NSInteger i = [self.channelTable selectedRow];
	
	BOOL count   = (i >= 0);
	BOOL bouncer = BOOLReverseValue([self.bouncerModeCheck state]);
	BOOL enabled = (count && bouncer);
	
	[self.addChannelButton		setEnabled:bouncer];
	[self.editChannelButton		setEnabled:enabled];
	[self.deleteChannelButton	setEnabled:enabled];
}

- (void)reloadChannelTable
{
	[self.channelTable reloadData];
	[self.channelTable setEnabled:BOOLReverseValue([self.bouncerModeCheck state])];
}

- (void)updateIgnoresPage
{
	NSInteger i = [self.ignoreTable selectedRow];
	
	BOOL enabled = (i >= 0);
	
	[self.editIgnoreButton	setEnabled:enabled];
	[self.deleteIgnoreButton setEnabled:enabled];
}

- (void)reloadIgnoreTable
{
	[self.ignoreTable reloadData];
}

- (void)floodControlChanged:(id)sender
{
    BOOL match = (self.outgoingFloodControl.state == NSOnState);
	
    [self.floodControlToolView setHidden:BOOLReverseValue(match)];
}

#pragma mark -
#pragma mark Actions

- (void)ok:(id)sender
{
	[self save];
	
	NSMutableArray *ignores = self.config.ignores;
	
	for (NSInteger i = (ignores.count - 1); i >= 0; --i) {
		AddressBook *g = [ignores safeObjectAtIndex:i];
		
		if (NSObjectIsEmpty(g.hostmask)) {
			[ignores safeRemoveObjectAtIndex:i];
		}
	}
	
	if ([self.delegate respondsToSelector:@selector(ServerSheetOnOK:)]) {
		[self.delegate ServerSheetOnOK:self];
	}
	
	[self endSheet];
}

- (void)cancel:(id)sender
{
	[self endSheet];
}

- (void)hostComboChanged:(id)sender
{
	[self updateConnectionPage];
}

- (void)encodingChanged:(id)sender
{
	[self.fallbackEncodingCombo setEnabled:([self.encodingCombo selectedTag] == NSUTF8StringEncoding)];
}

- (void)proxyChanged:(id)sender
{
	NSInteger tag = [self.proxyCombo selectedTag];
	
	BOOL enabled = (tag == PROXY_SOCKS4 || tag == PROXY_SOCKS5);
	
	[self.proxyHostText		setEnabled:enabled];
	[self.proxyPortText		setEnabled:enabled];
	[self.proxyUserText		setEnabled:enabled];
	[self.proxyPasswordText	setEnabled:enabled];
}

- (void)bouncerModeChanged:(id)sender
{
	[self.channelTable setEnabled:BOOLReverseValue([self.bouncerModeCheck state])];
}

#pragma mark -
#pragma mark Channel Actions

- (void)addChannel:(id)sender
{
	NSInteger sel = [self.channelTable selectedRow];
	
	IRCChannelConfig *conf;
	
	if (sel < 0) {
		conf = [[IRCChannelConfig alloc] init];
	} else {
		IRCChannelConfig *c = [self.config.channels safeObjectAtIndex:sel];
		
		conf = [c mutableCopy];
		conf.name = NSNullObject;
	}
	
	self.channelSheet = nil;
	
	self.channelSheet = [ChannelSheet new];
	self.channelSheet.delegate = self;
	self.channelSheet.window = self.sheet;
	self.channelSheet.config = conf;
	self.channelSheet.uid = 1;
	self.channelSheet.cid = -1;
	[self.channelSheet show];
}

- (void)editChannel:(id)sender
{
	NSInteger sel = [self.channelTable selectedRow];
	if (sel < 0) return;
	
	IRCChannelConfig *c = [[self.config.channels safeObjectAtIndex:sel] mutableCopy];
	
	self.channelSheet = nil;
	
	self.channelSheet = [ChannelSheet new];
	self.channelSheet.delegate = self;
	self.channelSheet.window = self.sheet;
	self.channelSheet.config = c;
	self.channelSheet.uid = 1;
	self.channelSheet.cid = 1;
	[self.channelSheet show];
}

- (void)ChannelSheetOnOK:(ChannelSheet *)sender
{
	IRCChannelConfig *conf = sender.config;
	
	NSString *name = conf.name;
	
	NSInteger i = 0;
	NSInteger n = -1;
	
	for (IRCChannelConfig *c in self.config.channels) {
		if ([c.name isEqualToString:name]) {
			n = i;
			
			break;
		}
		
		++i;
	}
	
	if (n < 0) {
		[self.config.channels safeAddObject:conf];
	} else {
		[self.config.channels replaceObjectAtIndex:n withObject:conf];
	}
	
	[self reloadChannelTable];
}

- (void)ChannelSheetWillClose:(ChannelSheet *)sender
{
	self.channelSheet = nil;
}

- (void)deleteChannel:(id)sender
{
	NSInteger sel = [self.channelTable selectedRow];
	if (sel < 0) return;
	
	[self.config.channels safeRemoveObjectAtIndex:sel];
	
	NSInteger count = self.config.channels.count;
	
	if (count) {
		if (count <= sel) {
			[self.channelTable selectItemAtIndex:(count - 1)];
		} else {
			[self.channelTable selectItemAtIndex:sel];
		}
	}
	
	[self reloadChannelTable];
}

#pragma mark -
#pragma mark Ignore Actions

- (void)showAddIgnoreMenu:(id)sender
{
	NSRect tableRect = [self.ignoreTable frame];
	
	tableRect.origin.y += (tableRect.size.height);
	tableRect.origin.y += 34;
    
	[self.addIgnoreMenu popUpMenuPositioningItem:nil atLocation:tableRect.origin
										  inView:self.ignoreTable];
}
- (void)addIgnore:(id)sender
{
	self.ignoreSheet = nil;
	
	self.ignoreSheet = [AddressBookSheet new];
	self.ignoreSheet.delegate = self;
	self.ignoreSheet.window = self.sheet;
	self.ignoreSheet.ignore = [AddressBook new];
	self.ignoreSheet.newItem = YES;
	
	if ([sender tag] == 4) {
		self.ignoreSheet.ignore.entryType = ADDRESS_BOOK_TRACKING_ENTRY;
	} else {
		self.ignoreSheet.ignore.entryType = ADDRESS_BOOK_IGNORE_ENTRY;
	}
	
	[self.ignoreSheet start];
}

- (void)editIgnore:(id)sender
{
	NSInteger sel = [self.ignoreTable selectedRow];
	if (sel < 0) return;
	
	self.ignoreSheet = nil;
	
	self.ignoreSheet = [AddressBookSheet new];
	self.ignoreSheet.delegate = self;
	self.ignoreSheet.window = self.sheet;
	self.ignoreSheet.ignore = [self.config.ignores safeObjectAtIndex:sel];
	[self.ignoreSheet start];
}

- (void)deleteIgnore:(id)sender
{
	NSInteger sel = [self.ignoreTable selectedRow];
	if (sel < 0) return;
	
	[self.config.ignores safeRemoveObjectAtIndex:sel];
	
	NSInteger count = self.config.ignores.count;
	
	if (count) {
		if (count <= sel) {
			[self.ignoreTable selectItemAtIndex:(count - 1)];
		} else {
			[self.ignoreTable selectItemAtIndex:sel];
		}
	}
	
	[self reloadIgnoreTable];
	
	[self.client populateISONTrackedUsersList:self.config.ignores];
}

- (void)ignoreItemSheetOnOK:(AddressBookSheet *)sender
{
	NSString *hostmask = [sender.ignore.hostmask trim];
	
	if (sender.newItem) {
		if (NSObjectIsNotEmpty(hostmask)) {
			[self.config.ignores safeAddObject:sender.ignore];
		}
	} else {
		if (NSObjectIsEmpty(hostmask)) {
			[self.config.ignores removeObject:sender.ignore];
		}
	}
	
	[self reloadIgnoreTable];
	
	[self.client populateISONTrackedUsersList:self.config.ignores];
}

- (void)ignoreItemSheetWillClose:(AddressBookSheet *)sender
{
	self.ignoreSheet = nil;
}

#pragma mark -
#pragma mark NSTableViwe Delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)sender
{
	if (sender == self.channelTable) {
		return self.config.channels.count;
	} else if (sender == self.tabView) {
		return self.tabViewList.count;
	} else {
		return self.config.ignores.count;
	}
}

- (id)tableView:(NSTableView *)sender objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)row
{
	NSString *columnId = [column identifier];
	
	if (sender == self.channelTable) {
		IRCChannelConfig *c = [self.config.channels safeObjectAtIndex:row];
		
		if ([columnId isEqualToString:@"name"]) {
			return c.name;
		} else if ([columnId isEqualToString:@"pass"]) {
			return c.password;
		} else if ([columnId isEqualToString:@"join"]) {
			return NSNumberWithBOOL(c.autoJoin);
		}
	} else if (sender == self.tabView) {
		NSArray *tabInfo = [self.tabViewList safeObjectAtIndex:row];
        
        NSString *keyhead = [tabInfo safeObjectAtIndex:0];
        
        if ([keyhead isEqualToString:ListSeparatorCellIndex] == NO) {
            NSString *langkey = [NSString stringWithFormat:@"SERVER_SHEET_NAVIGATION_LIST_%@", keyhead];
            
            return TXTLS(langkey);
        } else {
            return ListSeparatorCellIndex;
        }
	} else {
		AddressBook *g = [self.config.ignores safeObjectAtIndex:row];
		
		if ([columnId isEqualToString:@"type"]) {
			if (g.entryType == ADDRESS_BOOK_IGNORE_ENTRY) {
				return TXTLS(@"ADDRESS_BOOK_ENTRY_IGNORE_TYPE");
			} else {
				return TXTLS(@"ADDRESS_BOOK_EMTRY_TRACKING_TYPE");
			}
		} else {
			return g.hostmask;
		}
	}
	
	return nil;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
	if (tableView == self.tabView) {
		NSArray *tabInfo = [self.tabViewList safeObjectAtIndex:row];
		
		NSString *keyhead = [tabInfo safeObjectAtIndex:0];
		
		if ([keyhead isEqualToString:ListSeparatorCellIndex]) {
			return NO;
		}
	}
	
	return YES;
}

- (void)tableView:(NSTableView *)sender setObjectValue:(id)obj
   forTableColumn:(NSTableColumn *)column row:(NSInteger)row
{
	if (sender == self.channelTable) {
		IRCChannelConfig *c = [self.config.channels safeObjectAtIndex:row];
		
		NSString *columnId = [column identifier];
		
		if ([columnId isEqualToString:@"join"]) {
			c.autoJoin = BOOLReverseValue([obj integerValue] == 0);
		}
	}
}

- (void)tableViewSelectionDidChange:(NSNotification *)note
{
	id sender = [note object];
	
	if (sender == self.channelTable) {
		[self updateChannelsPage];
	} else if (sender == self.tabView) {
		NSInteger row = [self.tabView selectedRow];
		
        switch (row) {
            case 0:  [self focusView:self.generalView	     atRow:0]; break;
            case 1:  [self focusView:self.identityView       atRow:1]; break;
            case 2:  [self focusView:self.messagesView       atRow:2]; break;
            case 3:  [self focusView:self.encodingView       atRow:3]; break;
            case 4:  [self focusView:self.autojoinView       atRow:4]; break;
            case 5:  [self focusView:self.ignoresView		 atRow:5]; break;
            case 6:  [self focusView:self.commandsView       atRow:6]; break;
            case 8:  [self focusView:self.proxyServerView    atRow:8]; break;
            case 9:  [self focusView:self.floodControlView   atRow:9]; break;
            default: break;
        }
    } else {
        [self updateIgnoresPage];
    }
}

- (void)tableViewDoubleClicked:(id)sender
{
	if (sender == self.channelTable) {
		[self editChannel:nil];
	} else if (sender == self.tabView) {
		// ...
	} else {
		[self editIgnore:nil];
	}
}

- (BOOL)tableView:(NSTableView *)sender writeRowsWithIndexes:(NSIndexSet *)rows toPasteboard:(NSPasteboard *)pboard
{
	if (sender == self.channelTable) {
		NSArray *ary = [NSArray arrayWithObject:NSNumberWithInteger([rows firstIndex])];
        
		[pboard declareTypes:TABLE_ROW_TYPES owner:self];
		
		[pboard setPropertyList:ary forType:TABLE_ROW_TYPE];
	}
	
	return YES;
}

- (NSDragOperation)tableView:(NSTableView *)sender validateDrop:(id < NSDraggingInfo >)info
				 proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op
{
	if (sender == self.channelTable) {
		NSPasteboard *pboard = [info draggingPasteboard];
        
		if (op == NSTableViewDropAbove && [pboard availableTypeFromArray:TABLE_ROW_TYPES]) {
			return NSDragOperationGeneric;
		} else {
			return NSDragOperationNone;
		}
	} else {
		return NSDragOperationNone;
	}
}

- (BOOL)tableView:(NSTableView *)sender acceptDrop:(id < NSDraggingInfo >)info
			  row:(NSInteger)row dropOperation:(NSTableViewDropOperation)op
{
	if (sender == self.channelTable) {
		NSPasteboard *pboard = [info draggingPasteboard];
		
		if (op == NSTableViewDropAbove && [pboard availableTypeFromArray:TABLE_ROW_TYPES]) {
			NSMutableArray *ary = self.config.channels;
			
			NSArray  *selectedRows	= [pboard propertyListForType:TABLE_ROW_TYPE];
			NSInteger selectedRow	= [selectedRows integerAtIndex:0];
			
			IRCChannelConfig *target = [ary safeObjectAtIndex:selectedRow];
			
			NSMutableArray *low  = [[ary subarrayWithRange:NSMakeRange(0, row)] mutableCopy];
			NSMutableArray *high = [[ary subarrayWithRange:NSMakeRange(row, (ary.count - row))] mutableCopy];
			
			[low  removeObjectIdenticalTo:target];
			[high removeObjectIdenticalTo:target];
			
			[ary removeAllObjects];
			
			[ary addObjectsFromArray:low];
			[ary safeAddObject:target];
			[ary addObjectsFromArray:high];
			
			[self reloadChannelTable];
			
			selectedRow = [ary indexOfObjectIdenticalTo:target];
			
			if (0 <= selectedRow) {
				[self.channelTable selectItemAtIndex:selectedRow];
			}
			
			return YES;
		}
	} 
	
	return NO;
}

#pragma mark -
#pragma mark NSWindow Delegate

- (void)windowWillClose:(NSNotification *)note
{
	[self.channelTable unregisterDraggedTypes];
	
	if ([self.delegate respondsToSelector:@selector(ServerSheetWillClose:)]) {
		[self.delegate ServerSheetWillClose:self];
	}
}

@end
