//
//  JAPing.m
//  MacTool
//
//  Created by JadianZheng on 2018/8/14.
//

#import "JAPing.h"
#include <arpa/inet.h>

@implementation JAPingConfiguare

- (instancetype)init {
    self = [super init];
    if (self) {
        _pingCount = 1;
        _timeout = 60;
        _waitInterval = 1;
    }
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-parameter"
- (id)copyWithZone:(NSZone *)zone {
    JAPingConfiguare *copy = [[JAPingConfiguare alloc] init];
    copy.pingCount = self.pingCount;
    copy.timeout = self.timeout;
    copy.waitInterval = self.waitInterval;
    
    return copy;
}
#pragma clang diagnostic pop

@end


@implementation JAPingStatistic
- (instancetype)initWithHostName:(NSString *)hostName ip:(NSString *)ip transmittedPacketCount:(NSUInteger)transmittedPacketCount receivedPacketCount:(NSUInteger)receivedPacketCount minRoundTripTime:(NSTimeInterval)minRoundTripTime avgRoundTripTime:(NSTimeInterval)avgRoundTripTime maxRoundTripTime:(NSTimeInterval)maxRoundTripTime stddevRoundTripTime:(double)stddevRoundTripTime {
    self = [super init];
    if (self) {
        _hostName = hostName;
        _ip = ip;
        _transmittedPacketCount = transmittedPacketCount;
        _receivedPacketCount = receivedPacketCount;
        _minRoundTripTime = minRoundTripTime;
        _avgRoundTripTime = avgRoundTripTime;
        _maxRoundTripTime = maxRoundTripTime;
        _stddevRoundTripTime = stddevRoundTripTime;
    }
    return self;
}

@end


@implementation JAPingPacket

-(instancetype)initWithSequenceNumber:(NSInteger)sequenceNumber sendData:(NSData *)sendData {
    self = [super init];
    if (self) {
        _sequenceNumber = sequenceNumber;
        _sendData = sendData;
        _state = PacketStateWillSend;
        _sendTime = 0;
        _roundTripTime = 0;
    }
    return self;
}

@end


#import "SimplePing.h"

@interface JAPing () <SimplePingDelegate>

typedef void (^DelayPingHandle)(JAPing* ping);

@property (nonatomic, nonnull) SimplePing *pinger;
@property (nonatomic, nonnull) JAPingConfiguare *currentPingConfigure;
@property (nonatomic, copy, nullable) ErrorHandle unexpertErrorHandle;
@property (nonatomic, copy, nullable) DelayPingHandle delayPingHandle;

@property (nonatomic) BOOL pingRunning;
@property (nonatomic) NSInteger startedPingCount;
@property (nonatomic) NSInteger startPingSequenceNumber;
@property (nonatomic, nullable) NSTimer *pingTimer;

@property (nonatomic, readwrite, nonnull) NSMutableArray<JAPingPacket*> *packets;
@property (nonatomic, nonnull) NSMutableArray *statistics;

@end

@implementation JAPing

-(instancetype)initWithHostName:(NSString*)hostname unexpertError:(ErrorHandle)errorHandle {
    self = [super init];
    if (self) {
        _hostName = hostname;
        _ip = @"";
        _unexpertErrorHandle = errorHandle;
        
        _startedPingCount = 0;
        _startPingSequenceNumber = 0;
        _pingRunning = false;
        _configuare = [[JAPingConfiguare alloc] init];
        
        _packets = [NSMutableArray array];
        _statistics = [NSMutableArray array];

        _pinger = [[SimplePing alloc] initWithHostName:_hostName];
        _pinger.addressStyle = SimplePingAddressStyleICMPv4;
        _pinger.delegate = self;
    }
    return self;
}

- (void)startPing {
    _delayPingHandle = ^(JAPing* ping) {
        if (ping.pingRunning) {
            [ping stopPing];
        }
        
        ping.pingRunning = true;
        
        ping.currentPingConfigure = [ping.configuare copy];
        ping.pingTimer = [NSTimer scheduledTimerWithTimeInterval:ping.currentPingConfigure.waitInterval target:ping selector:@selector(sendPing) userInfo:nil repeats:true];
    };
    
    if ([_ip isEqualToString:@""]) {
        [_pinger start];
    }
    else {
        _delayPingHandle(self);
    }
}

- (void)sendPing {
    if (_currentPingConfigure.pingCount != 0 && _startedPingCount == _currentPingConfigure.pingCount) {
        [self stopPing];
        return;
    }
    
    [_pinger sendPingWithData:nil];
    _startedPingCount++;
}

- (void)stopPing {
    [_pingTimer invalidate];
    _pingTimer = nil;

    [self generateStatistics];
    _startPingSequenceNumber += _startedPingCount;
    _startedPingCount = 0;
    _delayPingHandle = nil;
    [_packets removeAllObjects];
    
    _pingRunning = false;

    if (_pingFinishHandle)
        _pingFinishHandle(self, _packets, _statistics.lastObject);
}

- (void)dealloc {
    if (_pingRunning)
        [self stopPing];
    
    [_pinger stop];
}


- (void)generateStatistics {
    NSTimeInterval current = [NSDate timeIntervalSinceReferenceDate];
    for (JAPingPacket *packet in _packets) {
        BOOL isTimeout = current - packet.sendTime >= _currentPingConfigure.timeout;
        
        if (packet.state == PacketStateDidSend && isTimeout) {
            packet.state = PacketStateTimeout;
        }
    }

    NSPredicate *receivedPacketPredicate = [NSPredicate predicateWithFormat:@"state = %d", PacketStateDidRecv];
    NSArray *receivedPackets = [_packets filteredArrayUsingPredicate:receivedPacketPredicate];

    NSTimeInterval avgRoundTripTime = [[receivedPackets valueForKeyPath:@"@avg.roundTripTime"] doubleValue];
    NSArray *roundTripTimes = [receivedPackets valueForKeyPath:@"roundTripTime"];
    
    // Calculate standard deviation
    double stddevRoundTripTime = 0;
    if (roundTripTimes.count > 0) {
        for (NSNumber *roundTripTime in roundTripTimes) {
            stddevRoundTripTime += pow(roundTripTime.doubleValue - avgRoundTripTime, 2);
        }
        stddevRoundTripTime /= roundTripTimes.count;
        stddevRoundTripTime = sqrt(stddevRoundTripTime);
    }

    JAPingStatistic *statistic = [[JAPingStatistic alloc] initWithHostName:_hostName
                                                                        ip:_ip
                                                    transmittedPacketCount:_packets.count
                                                       receivedPacketCount:receivedPackets.count
                                                          minRoundTripTime:[[receivedPackets valueForKeyPath:@"@min.roundTripTime"] doubleValue]
                                                          avgRoundTripTime:avgRoundTripTime
                                                          maxRoundTripTime:[[receivedPackets valueForKeyPath:@"@max.roundTripTime"] doubleValue]
                                                       stddevRoundTripTime:stddevRoundTripTime];
    [_statistics addObject:statistic];
}

#pragma mark - SetupPacketTime

- (nullable JAPingPacket*)packet:(uint16_t)sequenceNumber {
    NSPredicate *specificPacket = [NSPredicate predicateWithFormat:@"sequenceNumber == %@", @(sequenceNumber)];
    return [_packets filteredArrayUsingPredicate:specificPacket].firstObject;
}

- (nullable JAPingPacket*)setupPacketDidSent:(uint16_t)sequenceNumber data:(NSData*)data {
    JAPingPacket *packet = [[JAPingPacket alloc] initWithSequenceNumber:sequenceNumber sendData:data];
    packet.state = PacketStateDidSend;
    packet.sendTime = [NSDate timeIntervalSinceReferenceDate];
    [_packets addObject:packet];
    
    return packet;
}

- (nullable JAPingPacket*)setupPacketFailSent:(uint16_t)sequenceNumber {
    JAPingPacket *packet = [self packet:sequenceNumber];
    packet.state = PacketStateFailSend;
    return packet;
}

- (nullable JAPingPacket*)setupPacketDidRecv:(uint16_t)sequenceNumber {
    NSTimeInterval recvTime = [NSDate timeIntervalSinceReferenceDate];

    JAPingPacket *packet = [self packet:sequenceNumber];
    packet.state = PacketStateDidRecv;
    packet.roundTripTime = recvTime - packet.sendTime;
    return packet;
}


#pragma mark - SimplePingDelegate

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-parameter"
- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error {
    // kCFErrorDomainCFNetwork, host fail
    // NSPOSIXErrorDomain, socket create fail
    // NSPOSIXErrorDomain, recvData decode fail
    
    if(_unexpertErrorHandle)
        _unexpertErrorHandle(self, error);

    [self stopPing];
}

- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
    const struct sockaddr_in * addrPtr = (const struct sockaddr_in *) address.bytes;
    NSString *resolovedIP = [NSString stringWithCString:inet_ntoa(addrPtr->sin_addr) encoding:NSASCIIStringEncoding];

    if (resolovedIP && ![resolovedIP isEqualToString:@""] && [_ip isEqualToString:@""])
        _ip = resolovedIP;
    
    if (_delayPingHandle)
        _delayPingHandle(self);

    if (_resolvedHostHandle)
        _resolvedHostHandle(self, _ip);
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    JAPingPacket *pingPacket = [self setupPacketDidSent:sequenceNumber data:packet];
    
    if (pingPacket && _packetDidSendHandle)
        _packetDidSendHandle(self, sequenceNumber, pingPacket);
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error {
    JAPingPacket *pingPacket = [self setupPacketFailSent:sequenceNumber];
    
    if (pingPacket && _packetFailHandle)
        _packetFailHandle(self, sequenceNumber, pingPacket, error);
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    JAPingPacket *pingPacket = [self setupPacketDidRecv:sequenceNumber];

    if (pingPacket && _packetResponseHandle)
        _packetResponseHandle(self, sequenceNumber, pingPacket);
}
#pragma clang diagnostic pop

@end
