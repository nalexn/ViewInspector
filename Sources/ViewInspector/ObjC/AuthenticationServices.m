#import "AuthenticationServices.h"

#if __has_include(<AuthenticationServices/ASAuthorization.h>)
@import AuthenticationServices;

@implementation VIASAuthorization {
    id<ASAuthorizationProvider> _provider;
    id<ASAuthorizationCredential> _credential;
}

+ (VIASAuthorization *)authorization {
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

@end

#pragma mark - ASAuthorizationAppleIDCredential

API_AVAILABLE(ios(13.0), macos(10.15), tvos(13.0), watchos(6.0))
@interface VIASAuthorizationAppleIDCredential: ASAuthorizationAppleIDCredential
- (instancetype)initWithUser:(NSString *)user
                       email:(NSString * _Nullable)email
                    fullName:(NSPersonNameComponents * _Nullable)fullName
                       state:(NSString * _Nullable)state
            authorizedScopes:(NSArray<ASAuthorizationScope> *)authorizedScopes
           authorizationCode:(NSData * _Nullable)authorizationCode
               identityToken:(NSData * _Nullable)identityToken
              realUserStatus:(ASUserDetectionStatus)realUserStatus;
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

- (instancetype)initWithUser:(NSString *)user
                       email:(NSString *)email
                    fullName:(NSPersonNameComponents *)fullName
                       state:(NSString *)state
            authorizedScopes:(NSArray<ASAuthorizationScope> *)authorizedScopes
           authorizationCode:(NSData *)authorizationCode
               identityToken:(NSData *)identityToken
              realUserStatus:(ASUserDetectionStatus)realUserStatus {
    _user = user;
    _email = email;
    _fullName = fullName;
    _state = state;
    _authorizedScopes = authorizedScopes;
    _authorizationCode = authorizationCode;
    _identityToken = identityToken;
    _realUserStatus = realUserStatus;
    return self;
}

@end

API_AVAILABLE(ios(13.0), macos(10.15), tvos(13.0), watchos(6.0))
@implementation ASAuthorizationAppleIDCredential (Init)
+ (instancetype)credentialWithUser:(NSString *)user
                             email:(NSString * _Nullable)email
                          fullName:(NSPersonNameComponents * _Nullable)fullName
                             state:(NSString * _Nullable)state
                  authorizedScopes:(NSArray<ASAuthorizationScope> *)authorizedScopes
                 authorizationCode:(NSData * _Nullable)authorizationCode
                     identityToken:(NSData * _Nullable)identityToken
                    realUserStatus:(ASUserDetectionStatus)realUserStatus {
    return [[VIASAuthorizationAppleIDCredential alloc]
            initWithUser:user email:email
            fullName:fullName state:state
            authorizedScopes:authorizedScopes
            authorizationCode:authorizationCode
            identityToken:identityToken
            realUserStatus:realUserStatus];
}
@end

#endif
