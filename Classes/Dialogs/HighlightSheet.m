// Created by Codeux Software <support AT codeux DOT com> <https://github.com/codeux/Textual>
// You can redistribute it and/or modify it under the new BSD license.
// Converted to ARC Support on Thursday, June 09, 2012

#define ROW_HEIGHT_MULTIPLIER 17

@interface HighlightSheet (Private)
- (void)reloadTable;
@end

@implementation HighlightSheet

@synthesize list;
@synthesize table;
@synthesize header;
@synthesize delegate;

- (id)init
{
    if ((self = [super init])) {
		[NSBundle loadNibNamed:@"HighlightSheet" owner:self];
    }
    
    return self;
}

- (void)show
{
	MenuController *menu = self.delegate;
	
	IRCClient *currentNetwork = [menu.world selectedClient];
	NSString  *currentHeader  = nil;
	
	NSString  *network = currentNetwork.config.network;
	
	if (NSObjectIsEmpty(network)) {
		network = currentNetwork.config.name;
	}
	
	currentHeader = [self.header stringValue];
	currentHeader = [NSString stringWithFormat:currentHeader, network];
	
	[self.header setStringValue:currentHeader];
    [self.table setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
	
    [self startSheet];
}

- (void)ok:(id)sender
{
	[self endSheet];
	
	if ([self.delegate respondsToSelector:@selector(highlightSheetWillClose:)]) {
		[self.delegate highlightSheetWillClose:self];
	}
}

- (void)clear
{
    [self.list removeAllObjects];
	
    [self reloadTable];
}

- (void)reloadTable
{
    [self.table reloadData];
}

#pragma mark -
#pragma mark Actions

- (void)onClearList:(id)sender
{
	[self clear];
}

#pragma mark -
#pragma mark NSTableView Delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)sender
{
    return self.list.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	NSRect columnRect;
    
    columnRect = [tableView rectOfColumn:1];
    columnRect.size.width -= 6;
	
	NSArray *data = [self.list safeObjectAtIndex:row];
    
    NSInteger pixelHeight = [[data safeObjectAtIndex:2] pixelHeightInWidth:columnRect.size.width];
    NSInteger lineCount   = (pixelHeight / 14); 
    
    return (ROW_HEIGHT_MULTIPLIER * lineCount);
}

- (id)tableView:(NSTableView *)sender objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)row
{
    NSArray  *item = [self.list safeObjectAtIndex:row];
    NSString *col  = [column identifier];
    
    if ([col isEqualToString:@"chan"]) {
		return [item safeObjectAtIndex:0];
	} else if ([col isEqualToString:@"time"]) {
		NSInteger time = [item integerAtIndex:1];
		
		return TXTFLS(@"TIME_AGO", TXSpecialReadableTime([NSDate secondsSinceUnixTimestamp:time], YES, nil));
    } else {
        return [item safeObjectAtIndex:2];
    }
}

@end
