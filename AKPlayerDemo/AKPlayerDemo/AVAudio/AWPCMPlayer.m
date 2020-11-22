//
//  AWPCMPlayer.m
//  AKPlayerDemo
//
//  Created by Cary on 2020/11/22.
//

#import "AWPCMPlayer.h"

@interface AWPCMDataReader : NSObject
{
    UInt32 _readerLength;
}
@property (nonatomic, strong) NSData *readerData;
@end

@implementation AWPCMDataReader
- (instancetype)initDataWithFile:(NSString *)filePath {
    if (self = [super init]) {
        self.readerData = [NSData dataWithContentsOfFile:filePath];
    }
    return self;
}
- (int)readDataFromLen:(int)len forData:(Byte *)data {
    UInt32 currentReadLength = 0;
    if (_readerLength >= self.readerData.length) {
        _readerLength = 0;
        return currentReadLength;
    }
    NSRange range;
    if (_readerLength+ len <= self.readerData.length) {
        currentReadLength = len;
        range = NSMakeRange(_readerLength, currentReadLength);
        _readerLength = _readerLength + len;
    } else {
        currentReadLength = (UInt32)(self.readerData.length - _readerLength);
        range = NSMakeRange(_readerLength, currentReadLength);
        _readerLength = (UInt32) self.readerData.length;
    }
    
    NSData *subData = [self.readerData subdataWithRange:range];
    Byte *tempByte = (Byte *)[subData bytes];
    memcpy(data,tempByte,currentReadLength);
    
    return currentReadLength;
}
@end

@interface AWPCMPlayer ()

@property (nonatomic, strong) AWPCMDataReader *reader;


@end

@implementation AWPCMPlayer

- (instancetype)initWithFile:(NSString *)filePath rate:(double)rate channel:(NSUInteger)channel bit:(NSUInteger)bit {
    if (self = [super initWithFile:filePath rate:rate channel:channel bit:bit]) {
        self.reader = [[AWPCMDataReader alloc] initDataWithFile:filePath];
    }
    return self;
}

- (void)start {
    if (self.inputBlock == nil) {
        __weak typeof(self) weakSelf = self;
        self.inputBlock = ^(AudioBufferList *bufferList) {
            AudioBuffer buffer = bufferList->mBuffers[0];
            int len = buffer.mDataByteSize;
            int readLen = [weakSelf.reader readDataFromLen:len forData:buffer.mData];
            buffer.mDataByteSize = readLen;
            if (readLen == 0) {
                [weakSelf stop];
                if (self.delegate && [self.delegate respondsToSelector:@selector(playToEnd:)]) {
                    [self.delegate playToEnd:self];
                }
            }
        };
    }
    [super start];
}

@end
