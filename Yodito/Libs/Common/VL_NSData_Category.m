
#import "VL_NSData_Category.h"

@implementation NSData(VL_NSData_Category)

//
// Base-64 (RFC-1521) support.  The following is based on mpack-1.5 (ftp://ftp.andrew.cmu.edu/pub/mpack/)
//

#define XX 127
static char Base64Decode[256] = {
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,62, XX,XX,XX,63,
    52,53,54,55, 56,57,58,59, 60,61,XX,XX, XX,XX,XX,XX,
    XX, 0, 1, 2,  3, 4, 5, 6,  7, 8, 9,10, 11,12,13,14,
    15,16,17,18, 19,20,21,22, 23,24,25,XX, XX,XX,XX,XX,
    XX,26,27,28, 29,30,31,32, 33,34,35,36, 37,38,39,40,
    41,42,43,44, 45,46,47,48, 49,50,51,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
    XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
};
const  unsigned char Base64Pad = '=';
const  unsigned char Base64Encode[] =  
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

+ (id)dataWithBase64Data:(NSData *)base64Data {
    return [[[self alloc] initWithBase64Data:base64Data] autorelease];
}

+ (id)dataWithBase64String:(NSString *)base64String {
    return [[[self alloc] initWithBase64String:base64String] autorelease];
}

-(id) initWithBase64String:(NSString *)base64String {
	if ([base64String canBeConvertedToEncoding:NSASCIIStringEncoding] == NO) {
		return nil;
	}
	
	return [self initWithBase64Data:[base64String dataUsingEncoding:NSASCIIStringEncoding]];
}

-(id) initWithBase64Data:(NSData *)base64Data {
	unsigned char *inputBuffer = (unsigned char *)[base64Data bytes],  
	*outputBuffer;
	unsigned int inputLength = (unsigned int)[base64Data length];
	unsigned int outputRemainder = 3, index, inputQuads;
	unsigned char q1, q2, q3, q4;
	NSMutableData *outputData;
	
	if (inputLength >= 4 && 0 == inputLength %4) {
		inputQuads = inputLength / 4;
		
		if (Base64Pad == inputBuffer[inputLength -1]) {
			inputQuads--;
			outputRemainder--;
		}
		
		if (Base64Pad == inputBuffer[inputLength -2])
			outputRemainder--;
		
		outputData = [NSMutableData dataWithLength:(inputQuads * 3) +  
					  outputRemainder];
		outputBuffer = [outputData mutableBytes];
		
		for (index = 0; index < inputQuads; index++) {
			q1 = Base64Decode[*inputBuffer++];
			q2 = Base64Decode[*inputBuffer++];
			q3 = Base64Decode[*inputBuffer++];
			q4 = Base64Decode[*inputBuffer++];
			*outputBuffer++ = q1 << 2 | (q2 & 0x30) >> 4;
			*outputBuffer++ = (q2 & 0xF) << 4 | (q3 & 0x3C) >> 2;
			*outputBuffer++ = (q3 & 0x3) << 6 | (q4 & 0x3F);
		}
		
		if (2 == outputRemainder) {
			q1 = Base64Decode[*inputBuffer++];
			q2 = Base64Decode[*inputBuffer++];
			q3 = Base64Decode[*inputBuffer++];
			*outputBuffer++ = q1 << 2 | (q2 & 0x30) >> 4;
			*outputBuffer++ = (q2 & 0xF) << 4 | (q3 & 0x3C) >> 2;
			
		} else if (1 == outputRemainder) {
			q1 = Base64Decode[*inputBuffer++];
			q2 = Base64Decode[*inputBuffer++];
			*outputBuffer++ = q1 << 2 | (q2 & 0x30) >> 4;
		}
		
		return [self initWithData:outputData];
	}
	
	return [self initWithData:[NSData data]];
}

- (NSString *)base64String {
	return [[[NSString alloc] initWithData:[self base64Data] encoding:NSASCIIStringEncoding] autorelease];
}

- (NSData *)base64Data {
	unsigned int inputTriplets  = (unsigned int)[self length] / 3;
	unsigned int inputRemainder = [self length] % 3;
	unsigned int outputLength = inputTriplets * 4;
	unsigned int index;
	unsigned char *outputBuffer, *inputBuffer;
	unsigned char t1, t2, t3;
	NSMutableData *outputData;
	
	if (0 != inputRemainder) outputLength += 4;
	
	outputData = [NSMutableData dataWithLength:outputLength];
	outputBuffer = [outputData mutableBytes];
	inputBuffer = (unsigned char *)[self bytes];
	
	for (index = 0; index < inputTriplets; index++) {
		t1 = *inputBuffer++;
		t2 = *inputBuffer++;
		t3 = *inputBuffer++;
		*outputBuffer++ = Base64Encode[t1 >> 2];
		*outputBuffer++ = Base64Encode[(t1 & 0x3) << 4 | t2 >> 4];
		*outputBuffer++ = Base64Encode[(t2 & 0xF) << 2 | t3 >> 6];
		*outputBuffer++ = Base64Encode[t3 & 0x3F];
	}
	
	if (2 == inputRemainder) {
		t1 = *inputBuffer++;
		t2 = *inputBuffer++;
		*outputBuffer++ = Base64Encode[t1 >> 2];
		*outputBuffer++ = Base64Encode[(t1 & 0x3) << 4 | t2 >> 4];
		*outputBuffer++ = Base64Encode[(t2 & 0xF) << 2];
		*outputBuffer++ = Base64Pad;
		
	} else if (1 == inputRemainder) {
		t1 = *inputBuffer++;
		*outputBuffer++ = Base64Encode[t1 >> 2];
		*outputBuffer++ = Base64Encode[(t1 & 0x3) << 4];
		*outputBuffer++ = Base64Pad;
		*outputBuffer++ = Base64Pad;
	}
	
	return outputData;
}

- (NSString*)toHexString
{
	static const unichar chars[] = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
	const u_int8_t *buffer = [self bytes];
	unsigned length = (unsigned)[self length];
	NSMutableString *res = [NSMutableString stringWithCapacity:length*2+1];
	for(unsigned i = 0; i < length; i++)
	{
		u_int8_t bt = *(buffer + i);
		unichar ch1 = chars[ ((bt & 0xF0) >> 4) ];
		unichar ch0 = chars[ (bt & 0xF) ];
		[res appendFormat:@"%C%C", ch1, ch0];
	}
	return res;
}

@end
