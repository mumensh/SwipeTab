//
//  ConstantMethods.m
//  Rawabi Projects
//
//  Created by ASAL on 5/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConstantMethods.h"

@implementation NSData (AES256)

- (NSData *)AES256EncryptWithKey:(NSString *)key {
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [self length];
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
	}
    
	free(buffer); //free the buffer;
	return nil;
}

- (NSData *)AES256DecryptWithKey:(NSString *)key {
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [self length];
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesDecrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
	
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
	}
	
	free(buffer); //free the buffer;
	return nil;
}

@end

@implementation ConstantMethods

+ (UIColor *) colorWithHexString: (NSString *) hex
{  
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];  
    
    // String should be 6 or 8 characters  
    if ([cString length] < 6) return [UIColor grayColor];  
    
    // strip 0X if it appears  
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];  
    
    if ([cString length] != 6) return  [UIColor grayColor];  
    
    // Separate into r, g, b substrings  
    NSRange range;  
    range.location = 0;  
    range.length = 2;  
    NSString *rString = [cString substringWithRange:range];  
    
    range.location = 2;  
    NSString *gString = [cString substringWithRange:range];  
    
    range.location = 4;  
    NSString *bString = [cString substringWithRange:range];  
    
    // Scan values  
    unsigned int r, g, b;  
    [[NSScanner scannerWithString:rString] scanHexInt:&r];  
    [[NSScanner scannerWithString:gString] scanHexInt:&g];  
    [[NSScanner scannerWithString:bString] scanHexInt:&b];  
    
    return [UIColor colorWithRed:((float) r / 255.0f)  
                           green:((float) g / 255.0f)  
                            blue:((float) b / 255.0f)  
                           alpha:1.0f];  
}

+ (void) writeToPlist: (NSString*)fileName withData:(NSMutableArray *)data
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *finalPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    [data writeToFile:finalPath atomically: YES];
    /* This would change the firmware version in the plist to 1.1.1 by initing the NSDictionary with the plist, then changing the value of the string in the key "ProductVersion" to what you specified */
}

+ (NSMutableArray *) readFromPlist: (NSString *)fileName {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *finalPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:finalPath];
    
    if (fileExists) {
        NSMutableArray *arr = [[NSMutableArray alloc] initWithContentsOfFile:finalPath];
        return arr;
    } else {
        return nil;
    }
}

+ (NSString*)retrieveFromUserDefaults:(NSString*)key
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSString *val = nil;
    
	if (standardUserDefaults) 
		val = [standardUserDefaults objectForKey:key];
    
	// TODO: / apparent Apple bug: if user hasn't opened Settings for this app yet (as if?!), then
	// the defaults haven't been copied in yet.  So do so here.  Adds another null check
	// for every retrieve, but should only trip the first time
	if (val == nil) { 
		//NSLog(@"user defaults may not have been loaded from Settings.bundle ... doing that now ...");
		//Get the bundle path
		NSString *bPath = [[NSBundle mainBundle] bundlePath];
		NSString *settingsPath = [bPath stringByAppendingPathComponent:@"Settings.bundle"];
		NSString *plistFile = [settingsPath stringByAppendingPathComponent:@"Root.plist"];
        
		//Get the Preferences Array from the dictionary
		NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistFile];
		NSArray *preferencesArray = [settingsDictionary objectForKey:@"PreferenceSpecifiers"];
        
		//Loop through the array
		NSDictionary *item;
		for(item in preferencesArray)
		{
			//Get the key of the item.
			NSString *keyValue = [item objectForKey:@"Key"];
            
			//Get the default value specified in the plist file.
			id defaultValue = [item objectForKey:@"DefaultValue"];
            
			if (keyValue && defaultValue) {				
				[standardUserDefaults setObject:defaultValue forKey:keyValue];
				if ([keyValue compare:key] == NSOrderedSame)
					val = defaultValue;
			}
		}
		[standardUserDefaults synchronize];
	}
	return val;
}

+ (void)saveToUserDefaults:(NSString*)key value:(NSString*)valueString
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
	if (standardUserDefaults) {
		[standardUserDefaults setObject:valueString forKey:key];
		[standardUserDefaults synchronize];
	} else {
		//NSLog(@"Unable to save %@ = %@ to user defaults", key, valueString);
	}
}

+ (NSString*) unescapeUnicodeString:(NSString*)string
{
    // unescape quotes and backwards slash
    NSString* unescapedString = [string stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    unescapedString = [unescapedString stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
    
    // tokenize based on unicode escape char
    NSMutableString* tokenizedString = [NSMutableString string];
    NSScanner* scanner = [NSScanner scannerWithString:unescapedString];
    while ([scanner isAtEnd] == NO)
    {
        // read up to the first unicode marker
        // if a string has been scanned, it's a token
        // and should be appended to the tokenized string
        NSString* token = @"";
        [scanner scanUpToString:@"\\u" intoString:&token];
        if (token != nil && token.length > 0)
        {
            [tokenizedString appendString:token];
            continue;
        }
        
        // skip two characters to get past the marker
        // check if the range of unicode characters is
        // beyond the end of the string (could be malformed)
        // and if it is, move the scanner to the end
        // and skip this token
        NSUInteger location = [scanner scanLocation];
        NSInteger extra = scanner.string.length - location - 4 - 2;
        if (extra < 0)
        {
            NSRange range = {location, -extra};
            [tokenizedString appendString:[scanner.string substringWithRange:range]];
            [scanner setScanLocation:location - extra];
            continue;
        }
        
        // move the location pas the unicode marker
        // then read in the next 4 characters
        location += 2;
        NSRange range = {location, 4};
        token = [scanner.string substringWithRange:range];
        unichar codeValue = (unichar) strtol([token UTF8String], NULL, 16);
        [tokenizedString appendString:[NSString stringWithFormat:@"%C", codeValue]];
        
        // move the scanner past the 4 characters
        // then keep scanning
        location += 4;
        [scanner setScanLocation:location];
    }
    
    // done
    return tokenizedString;
}

+ (NSString*) escapeUnicodeString:(NSString*)string
{
    // lastly escaped quotes and back slash
    // note that the backslash has to be escaped before the quote
    // otherwise it will end up with an extra backslash
    NSString* escapedString = [string stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    escapedString = [escapedString stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    
    // convert to encoded unicode
    // do this by getting the data for the string
    // in UTF16 little endian (for network byte order)
    NSData* data = [escapedString dataUsingEncoding:NSUTF16LittleEndianStringEncoding allowLossyConversion:YES];
    size_t bytesRead = 0;
    const char* bytes = data.bytes;
    NSMutableString* encodedString = [NSMutableString string];
    
    // loop through the byte array
    // read two bytes at a time, if the bytes
    // are above a certain value they are unicode
    // otherwise the bytes are ASCII characters
    // the %C format will write the character value of bytes
    while (bytesRead < data.length)
    {
        uint16_t code = *((uint16_t*) &bytes[bytesRead]);
        if (code > 0x007E)
        {
            [encodedString appendFormat:@"\\u%04X", code];
        }
        else
        {
            [encodedString appendFormat:@"%C", code];
        }
        bytesRead += sizeof(uint16_t);
    }
    
    // done
    return encodedString;
}

+ (UIView *)getLineIn:(float)yAxes WithWidth:(float)width {
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, yAxes, width - 40, 2)];
    lineView.backgroundColor = [ConstantMethods colorWithHexString:@"e1e1e1"];
    //assume self is UIViewController or its sublcass
    return lineView;
}

+ (NSMutableAttributedString *)customStatusText:(NSString *)stringToColorize andIndexPathRow:(NSString *)indexOfColoredText {
    
    NSArray *indexes = [indexOfColoredText componentsSeparatedByString:@"|"];
    
    NSArray *allWords = [stringToColorize componentsSeparatedByString:@" "];
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:stringToColorize];
    
    BOOL doesContainWord = false;
    
    for (int x = 0; x < [allWords count]; x++) {
        
        doesContainWord = false;
        
        for (int y = 0; y < [indexes count]; y++) {

            if (x == [[indexes objectAtIndex:y] intValue]) {
                
                NSRange ranges = [stringToColorize rangeOfString:[allWords objectAtIndex:x]];
                
                [attString addAttribute:NSForegroundColorAttributeName value:[self colorWithHexString:@"bf343a"] range:NSMakeRange(ranges.location, [[allWords objectAtIndex:x] length])];
                
                doesContainWord = true;
                
                break;
            }
        }
        
        if (doesContainWord == false) {
            NSRange ranges = [stringToColorize rangeOfString:[allWords objectAtIndex:x]];
            
            [attString addAttribute:NSForegroundColorAttributeName value:[self colorWithHexString:@"a19e9e"] range:NSMakeRange(ranges.location,  [[allWords objectAtIndex:x] length])];
        }
    }
    
    return attString;
}

+ (CAGradientLayer *)gradiantLayer:(CGRect)bounds {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    CGRect niBund = bounds;
    niBund.origin.y = bounds.size.height / 2;
    niBund.size.height = bounds.size.height / 2;
    gradient.frame = niBund;
    UIColor *startColour = [UIColor colorWithHue:360 saturation:0.00 brightness:0.31 alpha:0.0];
    UIColor *endColour = [UIColor colorWithHue:360 saturation:0.00 brightness:0.31 alpha:1.0];
    gradient.colors = [NSArray arrayWithObjects:(id)[startColour CGColor], (id)[endColour CGColor], nil];
    return gradient;
}

+ (UIColor *)randomColor {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

@end
