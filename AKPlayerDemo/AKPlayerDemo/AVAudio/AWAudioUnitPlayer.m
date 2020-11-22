//
//  AWAudioUnitPlayer.m
//  AKPlayerDemo
//
//  Created by Cary on 2020/11/22.
//

#import "AWAudioUnitPlayer.h"

@interface AWAudioUnitPlayer ()
{
    AudioUnit audioUnit;
}
@property (nonatomic, assign) double rate;
@property (nonatomic, assign) NSUInteger channel;
@property (nonatomic, assign) NSUInteger bit;
@end

@implementation AWAudioUnitPlayer

AudioComponentDescription componentDescription(OSType componentType, OSType componentSubType, UInt32 componentFlags, UInt32 componentFlagsMask) {
    AudioComponentDescription outputDesc;
    outputDesc.componentType = componentType;
    outputDesc.componentSubType = componentSubType;
    outputDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    outputDesc.componentFlags = componentFlags;
    outputDesc.componentFlagsMask = componentFlagsMask;
    return outputDesc;
}

/**
 mSampleRate ： 采样率
 mFormatID ：格式
 mFramesPerPacket ： 每packet多少frames
 mChannelsPerFrame ： 每frame多少channel
 mBitsPerChannel ： 采样精度
 */
AudioStreamBasicDescription streamBasicDescription(AudioFormatID mFormatID, AudioFormatFlags mFormatFlags, double mSampleRate, UInt32 mFramesPerPacket, UInt32 mChannelsPerFrame, UInt32 mBitsPerChannel) {
    AudioStreamBasicDescription _outputFormat;
    memset(&_outputFormat, 0, sizeof(_outputFormat));
    _outputFormat.mSampleRate       = mSampleRate;
    _outputFormat.mFormatID         = mFormatID;
    _outputFormat.mFormatFlags      = mFormatFlags;
    _outputFormat.mFramesPerPacket  = mFramesPerPacket;
    _outputFormat.mChannelsPerFrame = mChannelsPerFrame;
    _outputFormat.mBitsPerChannel   = mBitsPerChannel;
    _outputFormat.mBytesPerFrame    = mBitsPerChannel * mChannelsPerFrame / 8;
    _outputFormat.mBytesPerPacket   = mBitsPerChannel * mChannelsPerFrame / 8 * mFramesPerPacket;
    return _outputFormat;
}

#pragma mark - init

- (instancetype)initWithFile:(NSString *)filePath rate:(double)rate channel:(NSUInteger)channel bit:(NSUInteger)bit {
    if (self = [super init]) {
        self->_filePath = filePath;
        self.rate = rate;
        self.channel = channel;
        self.bit = bit;
    }
    return self;
}

- (void)dealloc {
    [self stop];
    AudioComponentInstanceDispose(audioUnit);
}

- (void)initAudioUnitWithRate:(double)rate bit:(NSUInteger)bit channel:(NSUInteger)channel {
    //设置session
    NSError *error = nil;
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
    [session setActive:YES error:nil];
    
    //初始化audioUnit
    AudioComponentDescription outputDesc = componentDescription(kAudioUnitType_Output, kAudioUnitSubType_VoiceProcessingIO, 0, 0);
    AudioComponent outputComponent = AudioComponentFindNext(NULL, &outputDesc);
    AudioComponentInstanceNew(outputComponent, &audioUnit);
    
    //设置输出格式
    int mFramesPerPacket = 1;
    AudioStreamBasicDescription streamDesc = streamBasicDescription(kAudioFormatLinearPCM, kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsNonInterleaved, self.rate, mFramesPerPacket, self.channel, self.bit);

    
    OSStatus status = AudioUnitSetProperty(audioUnit,
                                           kAudioUnitProperty_StreamFormat,
                                           kAudioUnitScope_Input,
                                           0,
                                           &streamDesc,
                                           sizeof(streamDesc));
    
    // 设置回调
    AURenderCallbackStruct outputCallBackStruct;
    outputCallBackStruct.inputProc = outputCallBackFun;
    outputCallBackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Input,
                                  0,
                                  &outputCallBackStruct,
                                  sizeof(outputCallBackStruct));
}

- (void)start {
    if (audioUnit == nil) {
        [self initAudioUnitWithRate:self.rate bit:self.bit channel:self.channel];
    }
    AudioOutputUnitStart(audioUnit);
}

- (void)stop {
    if (audioUnit == nil) return;
    
    OSStatus status;
    status = AudioOutputUnitStop(audioUnit);
    status = AudioComponentInstanceDispose(audioUnit);
}

static OSStatus outputCallBackFun(void *                            inRefCon,
                                  AudioUnitRenderActionFlags        *ioActionFlags,
                                  const AudioTimeStamp              *inTimeStamp,
                                  UInt32                            inBusNumber,
                                  UInt32                            inNumberFrames,
                                  AudioBufferList * __nullable      ioData)
{
    memset(ioData->mBuffers[0].mData, 0, ioData->mBuffers[0].mDataByteSize);
    
    AWAudioUnitPlayer *player = (__bridge AWAudioUnitPlayer *)(inRefCon);
    if (player.inputBlock) {
        player.inputBlock(ioData);
    }
    return noErr;
}

@end

