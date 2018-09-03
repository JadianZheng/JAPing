//
//  JAHostSelector.m
//  iOSApp
//
//  Created by JadianZheng on 2018/8/18.
//

#import "JAHostSelector.h"

@interface JAHostSelector ()

@property (nonatomic, nonnull) NSMutableArray<JAPing*>* pingers;
@property (nonatomic, copy) ResolvedHandle resolvedHandle;
@property (nonatomic) BOOL aPingRunning;

@property (nonatomic, nonnull) NSMutableArray<JAPingStatistic*>* pingResults;

@end

@implementation JAHostSelector

- (instancetype)initWithHosts:(NSArray<NSString *> *)hosts {
    self = [super init];
    if (self) {
        _hosts = [hosts copy];
        _aPingRunning = false;
        _pingers = [NSMutableArray arrayWithCapacity:hosts.count];
        _pingResults = [NSMutableArray arrayWithCapacity:_hosts.count];

        // Setup all pinger
        JAHostSelector* __weak __block weakSelf = self;
        for (NSString *host in hosts) {
            JAPing *ping = [[JAPing alloc] initWithHostName:host unexpertError:nil];
            [_pingers addObject:ping];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-parameter"
            [ping setPingFinishHandle:^(JAPing * _Nonnull pinger, NSArray<JAPingPacket *> * _Nonnull packets, JAPingStatistic * _Nonnull Statistic) {
                JAHostSelector* __strong strongSelf = weakSelf;
                [strongSelf.pingResults addObject:Statistic];
                [strongSelf finishPing];
            }];
#pragma clang diagnostic pop
        }
    }
    return self;
}

-(BOOL)startPing:(NSInteger)count resolvedHandle:(ResolvedHandle)resolvedHandle {
    if (_aPingRunning) {
        return false;
    }
    
    _aPingRunning = true;
    _resolvedHandle = resolvedHandle;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-parameter"
    [_pingers enumerateObjectsUsingBlock:^(JAPing * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.configuare.pingCount = count;
        [obj startPing];
    }];
#pragma clang diagnostic pop
    return true;
}

-(void)finishPing {
    if (_resolvedHandle && _pingResults.count == _hosts.count) {
        _aPingRunning = false;
        
        NSPredicate *normalPredicate = [NSPredicate predicateWithFormat:@"ip != %@", @""];
        NSArray<JAPingStatistic*>* normalResults = [_pingResults filteredArrayUsingPredicate:normalPredicate];
        
        NSSortDescriptor *recvPacketSortDes = [NSSortDescriptor sortDescriptorWithKey:@"receivedPacketCount" ascending:false];
        NSSortDescriptor *stddevSortDes = [NSSortDescriptor sortDescriptorWithKey:@"stddevRoundTripTime" ascending:true];
        NSArray<JAPingStatistic*>* sortedPingResults = [normalResults sortedArrayUsingDescriptors: @[recvPacketSortDes, stddevSortDes]];
        
        [_pingResults removeAllObjects];
        
        JAPingStatistic *fastestStatistic = sortedPingResults.firstObject;
        if ([fastestStatistic.ip isEqualToString:@""] || fastestStatistic.receivedPacketCount == 0) {
            _resolvedHandle(@"", sortedPingResults);
        }
        else {
            _resolvedHandle(fastestStatistic.hostName, sortedPingResults);
        }
    }
}

@end
