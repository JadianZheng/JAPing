//
//  JAHostSelector.h
//  iOSApp
//
//  Created by JadianZheng on 2018/8/18.
//

#import <Foundation/Foundation.h>
#import "JAPing.h"

NS_ASSUME_NONNULL_BEGIN

@interface JAHostSelector : NSObject

typedef void (^ResolvedHandle)(NSString* fastest, NSArray<JAPingStatistic*>* sortedResults);

@property (nonatomic, readonly) NSArray<NSString*>* hosts;

-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithHosts:(NSArray<NSString*>*)hosts NS_DESIGNATED_INITIALIZER;

// Fail if another ping is running
-(BOOL)startPing:(NSInteger)count resolvedHandle:(ResolvedHandle)resolvedHandle;

@end

NS_ASSUME_NONNULL_END
