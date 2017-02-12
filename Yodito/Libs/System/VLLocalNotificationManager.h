
#import <Foundation/Foundation.h>

@interface VLLocalNotificationInfo : NSObject <NSCopying, NSCoding> {
@private
	NSDate *_fireDate;
	NSString *_message;
	NSString *_soundName;
	NSDictionary *_userInfo;
}

@property(nonatomic, copy) NSDate *fireDate;
@property(nonatomic, copy) NSString *message;
@property(nonatomic, copy) NSString *soundName;
@property(nonatomic, copy) NSDictionary *userInfo;

- (id)initWithCoder:(NSCoder *)decoder;
- (id)copyWithZone:(NSZone *)zone;
- (BOOL)isEqual:(VLLocalNotificationInfo *)other;
- (NSUInteger)hash;
- (NSComparisonResult)compare:(VLLocalNotificationInfo *)other;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end


@interface VLLocalNotificationManager : NSObject {
@private
	NSMutableArray *_cachedInfos;
}

+ (VLLocalNotificationManager *)shared;

- (void)cancelAllNotifications;
- (NSArray *)getAllNotifications;
- (void)setNotifications:(NSArray *)array;

@end
