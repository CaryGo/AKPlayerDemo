//
//  AWAudioUnitPlayer.h
//  AKPlayerDemo
//
//  Created by Cary on 2020/11/22.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class AWAudioUnitPlayer;
typedef void (^AWAudioUnitPlayerInputBlock) (AudioBufferList *bufferList);

@protocol AWAudioPlayerDelegate <NSObject>

- (void)playToEnd:(AWAudioUnitPlayer *)player;

@end

@interface AWAudioUnitPlayer : NSObject

- (instancetype)initWithFile:(NSString *)filePath rate:(double)rate channel:(NSUInteger)channel bit:(NSUInteger)bit;
- (void)start;
- (void)stop;

@property (nonatomic, copy, readonly) NSString *filePath;

@property (nonatomic, copy) AWAudioUnitPlayerInputBlock inputBlock;
@property (nonatomic, strong) id<AWAudioPlayerDelegate> delegate;

@end
