#import "Virtue.h"


#pragma mark Class Extension

@interface Virtue()
{
    @private NSRegularExpression *_regex;
}

- (void)filterProfanityFromMessage: (NSAttributedString **)message;

@end


#pragma mark -
#pragma mark Class Definition

@implementation Virtue


#pragma mark -
#pragma mark Properties

- (NSString *)pluginAuthor
{
	return @"Simeon de Dios";
}

- (NSString *)pluginVersion
{
	return @"1.0";
}

- (NSString *)pluginDescription
{
	return @"A basic profanity filter.";
}

- (NSString *)pluginURL
{
	return @"http://www.adiumxtras.com";
}


#pragma mark -
#pragma mark Constructor

- (id)init
{
    // fail if memory cannot be allocated
    if ((self = [super init]) == nil)
    {
        return nil;
    }
    
    // resolve profanity list from bundle
    NSBundle *pluginBundle = [NSBundle 
        bundleForClass: [Virtue class]];
    NSURL *profanityUrl = [pluginBundle URLForResource: @"profanity" 
        withExtension: @"txt"];
    NSString *profanityList = [NSString stringWithContentsOfURL: profanityUrl 
        encoding: NSASCIIStringEncoding 
        error: NULL];
    AILog(@"[virtue] profanity list:\n\t%@", profanityList);
        
    // initialize regex using profanity list
    NSString *profanityPattern = [NSString stringWithFormat: @"\\b(%@)\\b",
        profanityList];
    _regex = [[NSRegularExpression alloc]
        initWithPattern: profanityPattern
        options: NSRegularExpressionCaseInsensitive 
            | NSRegularExpressionDotMatchesLineSeparators 
        error: nil];
    
    // return instance
    return self;
}


#pragma mark -
#pragma mark Destructor

- (void)dealloc
{
    // release instance variables
    [_regex release];

    // call base destructor
    [super dealloc];
}


#pragma mark -
#pragma mark Overridden Methods

- (void)installPlugin
{
  // Do something for when plugin is installed
  NSLog(@"** Installed Virtue Plugin");
  
  [[adium contentController] 
    registerContentFilter: self 
    ofType: AIFilterContent 
    direction: AIFilterIncoming];
}

- (void)uninstallPlugin
{
  // Do something for when plugin is uninstalled
  NSLog(@"** Uninstalled Virtue Plugin");
}


#pragma mark -
#pragma mark Private Methods

- (void)filterProfanityFromMessage: (NSAttributedString **)message
{
    // check for profanity using regex
    NSString *text = (*message).string;
    NSRange textRange = NSMakeRange(0, [text length]);
    NSArray *matches = [_regex matchesInString: text 
        options: 0 
        range: textRange];
    
    // replace matches (if any)
    NSUInteger matchCount = [matches count];
    if (matchCount > 0)
    {
        // create replacement message
        NSMutableAttributedString *updatedMessage = 
            [[[NSMutableAttributedString alloc] 
                initWithAttributedString: *message]
                    autorelease];
        *message = updatedMessage;

        // replace profanity in matches
        for (NSTextCheckingResult *match in matches) 
        {
            // skip if length is invalid
            NSRange profanityRange = match.range;
            NSUInteger profanityLength = profanityRange.length;
            if (profanityLength == 0)
            {
                continue;
            }
        
            // create replacement string
            NSMutableString *mask = [[NSMutableString alloc]
                initWithCapacity: profanityLength];
            for (NSUInteger i = 0; i < profanityLength; ++i)
            {
                [mask appendString: @"*"];
            }
            
            // replace profanity with mask
            [updatedMessage replaceCharactersInRange: profanityRange 
                withString: mask];
        }
    } 
}


#pragma mark -
#pragma mark AIContentFilter Methods

- (CGFloat)filterPriority
{
	return DEFAULT_FILTER_PRIORITY;
}

- (NSAttributedString *)filterAttributedString: (NSAttributedString *)message 
    context: (id)context
{
    // filter profanity (if any)
    [self filterProfanityFromMessage: &message];

    // return filtered result
	return message;
}


@end
	
