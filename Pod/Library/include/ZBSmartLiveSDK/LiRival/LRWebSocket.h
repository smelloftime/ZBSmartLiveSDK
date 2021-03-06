//
//   Copyright 2012 Square Inc.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

#import <Foundation/Foundation.h>
#import <Security/SecCertificate.h>

typedef NS_ENUM(NSInteger, LRReadyState) {
    LR_CONNECTING   = 0,
    LR_OPEN         = 1,
    LR_CLOSING      = 2,
    LR_CLOSED       = 3,
};

typedef enum LRStatusCode : NSInteger {
    // 0–999: Reserved and not used.
    LRStatusCodeNormal = 1000,
    LRStatusCodeGoingAway = 1001,
    LRStatusCodeProtocolError = 1002,
    LRStatusCodeUnhandledType = 1003,
    // 1004 reserved.
    LRStatusNoStatusReceived = 1005,
    LRStatusCodeAbnormal = 1006,
    LRStatusCodeInvalidUTF8 = 1007,
    LRStatusCodePolicyViolated = 1008,
    LRStatusCodeMessageTooBig = 1009,
    LRStatusCodeMissingExtension = 1010,
    LRStatusCodeInternalError = 1011,
    LRStatusCodeServiceRestart = 1012,
    LRStatusCodeTryAgainLater = 1013,
    // 1014: Reserved for future use by the WebSocket standard.
    LRStatusCodeTLSHandshake = 1015,
    // 1016–1999: Reserved for future use by the WebSocket standard.
    // 2000–2999: Reserved for use by WebSocket extensions.
    // 3000–3999: Available for use by libraries and frameworks. May not be used by applications. Available for registration at the IANA via first-come, first-serve.
    // 4000–4999: Available for use by applications.
} LRStatusCode;

@class LRWebSocket;

extern NSString *const LRWebSocketErrorDomain;
extern NSString *const LRHTTPResponseErrorKey;

#pragma mark - LRWebSocketDelegate

@protocol LRWebSocketDelegate;

#pragma mark - LRWebSocket

@interface LRWebSocket : NSObject <NSStreamDelegate>

@property (nonatomic, weak) id <LRWebSocketDelegate> delegate;

@property (nonatomic, readonly) LRReadyState readyState;
@property (nonatomic, readonly, retain) NSURL *url;


@property (nonatomic, readonly) CFHTTPMessageRef receivedHTTPHeaders;

// Optional array of cookies (NSHTTPCookie objects) to apply to the connections
@property (nonatomic, readwrite) NSArray * requestCookies;

// This returns the negotiated protocol.
// It will be nil until after the handshake completes.
@property (nonatomic, readonly, copy) NSString *protocol;

// Protocols should be an array of strings that turn into Sec-WebSocket-Protocol.
- (id)initWithURLRequest:(NSURLRequest *)request protocols:(NSArray *)protocols allowsUntrustedSSLCertificates:(BOOL)allowsUntrustedSSLCertificates;
- (id)initWithURLRequest:(NSURLRequest *)request protocols:(NSArray *)protocols;
- (id)initWithURLRequest:(NSURLRequest *)request;

// Some helper constructors.
- (id)initWithURL:(NSURL *)url protocols:(NSArray *)protocols allowsUntrustedSSLCertificates:(BOOL)allowsUntrustedSSLCertificates;
- (id)initWithURL:(NSURL *)url protocols:(NSArray *)protocols;
- (id)initWithURL:(NSURL *)url;

// Delegate queue will be dispatch_main_queue by default.
// You cannot set both OperationQueue and dispatch_queue.
- (void)setDelegateOperationQueue:(NSOperationQueue*) queue;
- (void)setDelegateDispatchQueue:(dispatch_queue_t) queue;

// By default, it will schedule itself on +[NSRunLoop SR_networkRunLoop] using defaultModes.
- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (void)unscheduleFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;

// SRWebSockets are intended for one-time-use only.  Open should be called once and only once.
- (void)open;

- (void)close;
- (void)closeWithCode:(NSInteger)code reason:(NSString *)reason;

// Send a UTF8 String or Data.
- (void)send:(id)data;

// Send Data (can be nil) in a ping message.
- (void)sendPing:(NSData *)data;

@end

#pragma mark - LRWebSocketDelegate

@protocol LRWebSocketDelegate <NSObject>

// respondData will either be an NSString if the server is using text
// or NSData if the server is using binary.
- (void)webSocket:(LRWebSocket *)webSocket didReceiveRespondData:(id)respondData;

@optional

- (void)webSocketDidOpen:(LRWebSocket *)webSocket;
- (void)webSocket:(LRWebSocket *)webSocket didFailWithError:(NSError *)error;
- (void)webSocket:(LRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
- (void)webSocket:(LRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;

// Return YES to convert messages sent as Text to an NSString. Return NO to skip NSData -> NSString conversion for Text messages. Defaults to YES.
- (BOOL)webSocketShouldConvertTextFrameToString:(LRWebSocket *)webSocket;

@end

#pragma mark - NSURLRequest (SRCertificateAdditions)

@interface NSURLRequest (SRCertificateAdditions)

@property (nonatomic, retain, readonly) NSArray *SR_SSLPinnedCertificates;

@end

#pragma mark - NSMutableURLRequest (SRCertificateAdditions)

@interface NSMutableURLRequest (SRCertificateAdditions)

@property (nonatomic, retain) NSArray *SR_SSLPinnedCertificates;

@end

#pragma mark - NSRunLoop (SRWebSocket)

@interface NSRunLoop (SRWebSocket)

+ (NSRunLoop *)SR_networkRunLoop;

@end
