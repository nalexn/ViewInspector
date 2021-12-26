#import "ASHelper.h"
@import AuthenticationServices;

@implementation VIASAuthorization {
    id<ASAuthorizationProvider> _provider;
    id<ASAuthorizationCredential> _credential;
}

+ (VIASAuthorization *)appleID; {
    return [VIASAuthorization alloc];
}

- (id<ASAuthorizationProvider>)provider {
    return _provider;
}
- (id<ASAuthorizationCredential>)credential {
    return _credential;
}
- (void)setProvider:(id<ASAuthorizationProvider> _Nonnull)provider {
    _provider = provider;
}
- (void)setCredential:(id<ASAuthorizationCredential> _Nonnull)credential {
    _credential = credential;
}

+ (void)pass: (ASAuthorizationAppleIDRequest *)request block:(void (^_Nonnull)(ASAuthorizationAppleIDRequest *))block {
    block(request);
}

@end

API_AVAILABLE(ios(13.0), macos(10.15), tvos(13.0), watchos(6.0))
@interface VIASAuthorizationAppleIDCredential: ASAuthorizationAppleIDCredential
- (instancetype)initWithUser:(NSString *)user;
@end

@implementation VIASAuthorizationAppleIDCredential {
    NSString *_user;
    NSString *_state;
    NSArray<ASAuthorizationScope> *_authorizedScopes;
    NSData *_authorizationCode;
    NSData *_identityToken;
    NSString *_email;
    NSPersonNameComponents *_fullName;
    ASUserDetectionStatus _realUserStatus;
}

- (NSString *)user { return _user; }
- (NSString *)state { return _state; }
- (NSArray<ASAuthorizationScope> *)authorizedScopes { return _authorizedScopes; }
- (NSData *)authorizationCode { return _authorizationCode; }
- (NSData *)identityToken { return _identityToken; }
- (NSString *)email { return _email; }
- (NSPersonNameComponents *)fullName { return _fullName; }
- (ASUserDetectionStatus)realUserStatus { return _realUserStatus; }

- (instancetype)initWithUser:(NSString *)user; {
    _user = user;
    return self;
}

@end

@implementation ASAuthorizationAppleIDCredential (Init)
+ (ASAuthorizationAppleIDCredential *)appleIDCredentialWithUser:(NSString *)user {
    return [[VIASAuthorizationAppleIDCredential alloc] initWithUser: user];
}
@end
