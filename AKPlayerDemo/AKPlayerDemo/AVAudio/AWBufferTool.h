//
//  AWBufferTool.h
//  AKPlayerDemo
//
//  Created by Cary on 2020/11/22.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AWBufferTool : NSObject

- (AVAudioPCMBuffer *)getAudioBuffer:(NSString *)path;

@end
