//
//  AWBufferTool.m
//  AKPlayerDemo
//
//  Created by Cary on 2020/11/22.
//

#import "AWBufferTool.h"

@implementation AWBufferTool

- (AVAudioPCMBuffer *)getAudioBuffer:(NSString *)path {
    // 双声道配置
    AVAudioChannelLayout *chLayout = [[AVAudioChannelLayout alloc] initWithLayoutTag:kAudioChannelLayoutTag_Stereo];
    AVAudioFormat *chFormat = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatFloat64
                                                              sampleRate:44100.0
                                                              interleaved:YES
                                                            channelLayout:chLayout];
      
    // 创建一个基于上述配置的帧缓存结构
    AVAudioPCMBuffer *thePCMBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:chFormat frameCapacity:1024];
    thePCMBuffer.frameLength = thePCMBuffer.frameCapacity;
      
    // 初始化数据区
    for (AVAudioChannelCount ch = 0; ch < chFormat.channelCount; ++ch) {
        memset(thePCMBuffer.floatChannelData[ch], 0, thePCMBuffer.frameLength * chFormat.streamDescription->mBytesPerFrame);
    }
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    [data getBytes:thePCMBuffer.floatChannelData[0] length:data.length];

//    // 从 void*
//    void *bufData;
//    UInt32 dataLength;
//    memcpy(thePCMBuffer.floatChannelData[0], bufData, dataLength);
    
    return thePCMBuffer;
}

+ (AVAudioFile *)getFile {
    NSURL *url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"in" ofType:@"pcm"]];
    NSError *error = nil;
    AVAudioFile *file = [[AVAudioFile alloc] initForReading:url commonFormat:AVAudioPCMFormatInt16 interleaved:YES error:&error];
    return file;
}

@end
