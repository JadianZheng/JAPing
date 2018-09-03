//
//  JAPing.h
//  MacTool
//
//  Created by JadianZheng on 2018/8/14.
//

#import <Foundation/Foundation.h>

@interface JAPingConfiguare : NSObject <NSCopying>

@property (nonatomic) NSInteger pingCount;  // default 1, 0 means forever
//TODO unimplemente
@property (nonatomic) NSTimeInterval timeout;   // default 60
@property (nonatomic) NSTimeInterval waitInterval;  // default 1

@end


@interface JAPingStatistic : NSObject

@property (nonatomic, readonly, nonnull) NSString *hostName;
@property (nonatomic, readonly, nonnull) NSString *ip;

@property (nonatomic, readonly) NSUInteger transmittedPacketCount;
@property (nonatomic, readonly) NSUInteger receivedPacketCount;
@property (nonatomic, readonly) NSTimeInterval minRoundTripTime;
@property (nonatomic, readonly) NSTimeInterval avgRoundTripTime;
@property (nonatomic, readonly) NSTimeInterval maxRoundTripTime;
@property (nonatomic, readonly) double stddevRoundTripTime;

-(nonnull instancetype)init NS_UNAVAILABLE;
-(nonnull instancetype)initWithHostName:(NSString* _Nonnull)hostName
                                     ip:(NSString* _Nonnull)ip
                 transmittedPacketCount:(NSUInteger)transmittedPacketCount
                    receivedPacketCount:(NSUInteger)receivedPacketCount
                       minRoundTripTime:(NSTimeInterval)minRoundTripTime
                       avgRoundTripTime:(NSTimeInterval)avgRoundTripTime
                       maxRoundTripTime:(NSTimeInterval)maxRoundTripTime
                    stddevRoundTripTime:(double)stddevRoundTripTime NS_DESIGNATED_INITIALIZER;
@end


@interface JAPingPacket : NSObject

typedef NS_ENUM(NSInteger, PacketState) {
    PacketStateWillSend,
    PacketStateDidSend,
    PacketStateFailSend,
    PacketStateDidRecv,
    PacketStateTimeout
};

@property (nonatomic, readonly) NSInteger sequenceNumber;
@property (nonatomic, readonly, nonnull) NSData *sendData;
@property (nonatomic, assign) PacketState state;
@property (nonatomic) NSTimeInterval sendTime;
@property (nonatomic) NSTimeInterval roundTripTime;

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithSequenceNumber:(NSInteger)sequenceNumber sendData:(NSData* _Nonnull)sendData NS_DESIGNATED_INITIALIZER;

@end


@interface JAPing : NSObject

typedef void (^ErrorHandle)(JAPing* _Nonnull pinger, NSError* _Nonnull error);
typedef void (^ResolvedHostHandle)(JAPing* _Nonnull pinger, NSString* _Nonnull ip);

typedef void (^PacketDidSendHandle)(JAPing* _Nonnull pinger, NSInteger sequenceNumber, JAPingPacket* _Nonnull packet);
typedef void (^PacketResponseHandle)(JAPing* _Nonnull pinger, NSInteger sequenceNumber, JAPingPacket* _Nonnull packet);
typedef void (^PacketFailHandle)  (JAPing* _Nonnull pinger, NSInteger sequenceNumber, JAPingPacket* _Nonnull packet, NSError* _Nonnull error);
typedef void (^PingFinishHandle)(JAPing* _Nonnull pinger, NSArray<JAPingPacket*>* _Nonnull packets, JAPingStatistic* _Nonnull Statistic);

@property (nonatomic, readonly, nonnull) NSString *hostName;
@property (nonatomic, readonly, nonnull) NSString *ip;
@property (nonatomic, readonly, nonnull) JAPingConfiguare *configuare;
@property (nonatomic, readonly, nonnull) NSArray *statistics;

@property (nonatomic, copy, nonnull) ResolvedHostHandle resolvedHostHandle;
@property (nonatomic, copy, nonnull) PacketDidSendHandle packetDidSendHandle;
@property (nonatomic, copy, nonnull) PacketResponseHandle packetResponseHandle;
@property (nonatomic, copy, nonnull) PacketFailHandle packetFailHandle;
@property (nonatomic, copy, nonnull) PingFinishHandle pingFinishHandle;

-(nonnull instancetype)init NS_UNAVAILABLE;
-(nonnull instancetype)initWithHostName:(NSString* _Nonnull)hostName unexpertError:(ErrorHandle _Nullable)errorHandle NS_DESIGNATED_INITIALIZER;

-(void)setResolvedHostHandle:(ResolvedHostHandle _Nonnull)resolvedHostHandle;
-(void)setPacketDidSendHandle:(PacketDidSendHandle _Nonnull)packetDidSendHandle;
-(void)setPacketResponseHandle:(PacketResponseHandle _Nonnull)packetResponseHandle;
-(void)setPacketFailHandle:(PacketFailHandle _Nonnull)packetFailHandle;

// if ip is empty, means unknown host
-(void)setPingFinishHandle:(PingFinishHandle _Nonnull)pingFinishHandle;

-(void)startPing;   // Should call this after host has resolved(setResolvedHostHandle:)
-(void)stopPing;

@end
