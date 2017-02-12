
#import "VLLocalNotificationManager.h"
#import "../Common/Classes.h"
#import "../Logic/Classes.h"
#import "../Storage/Classes.h"

#define kSavedDataKey @"VLLocalNotificationManager"
#define kSavedDataVersion (kDefaultAnimationDuration + 4)


@implementation VLLocalNotificationInfo

@synthesize fireDate = _fireDate;
@synthesize message = _message;
@synthesize soundName = _soundName;
@synthesize userInfo = _userInfo;

- (id)init {
	self = [super init];
	if(self) {
		_fireDate = [[NSDate alloc] init];
		_message = [@"" retain];
		_soundName = [@"" retain];
		_userInfo = [[NSDictionary alloc] init];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super init];
	if(self != nil ) {
		self.fireDate = [decoder decodeObjectForKey:@"fireDate"];
		self.message = [decoder decodeObjectForKey:@"message"];
		self.soundName = [decoder decodeObjectForKey:@"soundName"];
		if([decoder containsValueForKey:@"userInfo"])
			self.userInfo = [decoder decodeObjectForKey:@"userInfo"];
		else
			self.userInfo = [NSDictionary dictionary];
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	VLLocalNotificationInfo *res = [[VLLocalNotificationInfo allocWithZone:zone] init];
	res.fireDate = self.fireDate;
	res.message = self.message;
	res.soundName = self.soundName;
	res.userInfo = self.userInfo;
	return res;
}

- (BOOL)isEqual:(VLLocalNotificationInfo *)other {
	return ([self compare:other] == NSOrderedSame);
}

- (NSUInteger)hash {
	return (NSUInteger)[_message length] + (NSUInteger)[_fireDate timeIntervalSince1970];
}

- (NSComparisonResult)compare:(VLLocalNotificationInfo*)other {
	NSComparisonResult res = [_fireDate compare:other.fireDate];
	if(res != NSOrderedSame)
		return res;
	res = [_message compare:other.message];
	if(res != NSOrderedSame)
		return res;
	res = [_soundName compare:other.soundName];
	if(res != NSOrderedSame)
		return res;
	if(![self.userInfo isEqualToDictionary:other.userInfo]) {
		res = (int)self.userInfo.hash - (int)other.userInfo.hash;
		if(res)
			return res;
		return 1;
	}
	return NSOrderedSame;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.fireDate forKey:@"fireDate"];
	[encoder encodeObject:self.message forKey:@"message"];
	[encoder encodeObject:self.soundName forKey:@"soundName"];
	[encoder encodeObject:self.userInfo forKey:@"userInfo"];
}

- (void)dealloc {
	[_fireDate release];
	[_message release];
	[_soundName release];
	[_userInfo release];
	[super dealloc];
}

@end




static VLLocalNotificationManager *_shared = nil;

@implementation VLLocalNotificationManager

+ (VLLocalNotificationManager *)shared {
	if(!_shared) {
		_shared = [VLObjectFileStorage loadRootObjectWithKey:kSavedDataKey version:kSavedDataVersion];
		if(!_shared)
			_shared = [[[VLLocalNotificationManager alloc] init] autorelease];
		[_shared retain];
	}
	return _shared;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if(self) {
		_shared = self;
		
		if(aDecoder) {
			_cachedInfos = [aDecoder decodeObjectForKey:@"_cachedInfos"];
		}
		
		if(!_cachedInfos)
			_cachedInfos = [NSMutableArray array];
		
		[_cachedInfos retain];
		
		[_cachedInfos sortedArrayUsingSelector:@selector(compare:)];
	}
	return self;
}

- (id)init {
	return [self initWithCoder:nil];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:_cachedInfos forKey:@"_cachedInfos"];
}

- (void)save {
	VLLogEvent(@"Saving");
	[VLObjectFileStorage saveDataWithRootObject:self key:kSavedDataKey version:kSavedDataVersion];
}

- (void)setNotificationForDate:(NSDate*)date
					 alertBody:(NSString*)alertText
					 withSound:(NSString*)soundName
					  userInfo:(NSDictionary*)userInfo {
	UIApplication *app = [UIApplication sharedApplication];
	
	UILocalNotification *localNotification = [[[UILocalNotification alloc] init] autorelease];
	localNotification.fireDate = date;
	localNotification.timeZone = [NSTimeZone defaultTimeZone];
	localNotification.alertBody = alertText;
	if(![NSString isEmpty:soundName])
	   localNotification.soundName = soundName;
	else
	   localNotification.soundName = UILocalNotificationDefaultSoundName;
	localNotification.userInfo = userInfo;
    localNotification.alertAction = nil;
	localNotification.applicationIconBadgeNumber = -1;
	[app scheduleLocalNotification:localNotification];
}

- (void)cancelAllNotifications {
	UIApplication *app = [UIApplication sharedApplication];
	[app cancelAllLocalNotifications];
	if(_cachedInfos.count) {
		[_cachedInfos removeAllObjects];
		[self save];
	}
}

- (NSArray *)getAllNotifications {
	return _cachedInfos;
}

- (void)setNotifications:(NSArray *)array {
	NSMutableArray *newInfos = [NSMutableArray arrayWithArray:array];
	[newInfos sortedArrayUsingSelector:@selector(compare:)];
	if(![_cachedInfos isEqualToArray:newInfos]) {
		[_cachedInfos removeAllObjects];
		[_cachedInfos addObjectsFromArray:newInfos];
		UIApplication *app = [UIApplication sharedApplication];
		[app cancelAllLocalNotifications];
		for(VLLocalNotificationInfo *info in _cachedInfos) {
			[self setNotificationForDate:info.fireDate
						   alertBody:info.message
						   withSound:info.soundName
							userInfo:info.userInfo];
		}
		[self save];
	}
}

- (void)dealloc {
	[_cachedInfos release];
	[super dealloc];
}

@end

