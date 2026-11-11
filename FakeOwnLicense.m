/*
 * FakeOwnLicense.m
 * Fake OwnLicense.framework/OwnLicense dylib
 *
 * Exports all symbols Penny and FreeFire expect from OwnLicense.
 * Session is always granted. No UI, no network, no Telegram.
 *
 * Build (arm64, Xcode):
 *   clang -arch arm64 -isysroot $(xcrun --sdk iphoneos --show-sdk-path) \
 *         -shared -fPIC -framework Foundation -framework UIKit \
 *         -install_name @rpath/OwnLicense.framework/OwnLicense \
 *         -o OwnLicense FakeOwnLicense.m
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// ─── Penny integrity check functions ─────────────────────────────────────────
// Called by Penny.framework to verify OwnLicense integrity.
// 0 = no tampering detected.

int64_t _penny_module_fingerprint(void) { return 0; }

// Called by Penny after its own verification pass.
void _penny_post_result(int64_t result) { (void)result; }

// Static mix used in Penny's verification math – return stable constant.
uint64_t _penny_static_mix(uint64_t seed) { return seed ^ 0xDEADBEEFCAFEBABEULL; }

// ─── Image/region integrity functions (or_*) ─────────────────────────────────
// OwnLicense uses these to snapshot memory regions and compare them.
// Faked to always report "valid/same".

int  _or_candidate_initialized(void)                        { return 1; }
void _or_expected_penny_uuid(void *out)                     { if (out) memset(out, 0, 16); }
int  _or_parse_image(const void *hdr)                       { (void)hdr; return 1; }
int  _or_readable_address(const void *addr)                 { (void)addr; return 1; }
int  _or_regions(void *buf, size_t *sz)                     { if (sz) *sz = 0; return 1; }
int  _or_same_snapshot(const void *a, const void *b, size_t n) { (void)a;(void)b;(void)n; return 1; }
void _or_take_snapshot(void *out, const void *src, size_t n) { if (out && n) memset(out, 0, n); }
uint64_t _or_u64(const void *p)                             { (void)p; return 0; }
int  _or_uuid_matches(const void *a, const void *b)         { (void)a;(void)b; return 1; }

// ─── Session functions (ol_session_*) ────────────────────────────────────────
// Called by FreeFire to check/grant/begin game sessions.
// Always allowed.

static int s_grant = 1;

int  _ol_session_allowed(void)             { return 1; }
void _ol_session_begin(void)               { }
int  _ol_session_due(void)                 { return 0; } // 0 = not due for re-verify
void _ol_session_fail(void)                { }
void _ol_session_grant(void)               { s_grant = 1; }
void _ol_session_init(void)                { s_grant = 1; }
void _ol_session_reset(void)               { s_grant = 1; }

// ─── Grant / bridge functions ─────────────────────────────────────────────────
int  _own_has_grant(void)                  { return 1; }
void _own_set_grant(int v)                 { (void)v; }
void _own_accept_loading(void)             { }
void _own_bridge_completed(void)           { }
void _own_bridge_failed(void)              { }
void _own_native_ready(void)               { }
void _own_native_started(void)             { }
void _own_resume_native(void)              { }
void _own_suspend_native(void)             { }
int  _own_runtime_suspended(void)          { return 0; }
void _own_start_watchdog(void)             { }
void _own_revoke(void)                     { }
void _own_request_logout(void)             { }
int  _own_penny_callsite(void)             { return 0; }
void _own_present_original_key_ui(void)    { }
int  _own_original_key_style(void)         { return 0; }

// ─── Metadata functions ───────────────────────────────────────────────────────
void _own_metadata_clear(void)                     { }
void _own_metadata_prepare(void)                   { }
void _own_metadata_set_installation(const char *s) { (void)s; }
void* _own_metadata_target(void)                   { return NULL; }
void _own_metadata_update(void)                    { }

// ─── Device / key storage functions ──────────────────────────────────────────
// Return empty/valid values so app doesn't get stuck in registration loop.
int  _own_valid_udid(void)                              { return 1; }
int  _own_device_storage_status(void)                   { return 0; } // 0 = OK
int  _own_installation_storage_status(void)             { return 0; }
int  _own_key_storage_status(void)                      { return 0; }
void _own_forget_saved_key(void)                        { }
void _own_forget_saved_key_checked(void)                { }
NSString* _own_load_saved_key(void)                     { return nil; } // nil = no saved key
void _own_save_verified_key(NSString *k)                { (void)k; }
NSString* _own_load_or_create_installation_id(void)     { return @"FAKE-INSTALL-ID-0000"; }
void _own_save_device_registration(NSData *d)           { (void)d; }
NSData* _own_load_device_registration(void)             { return nil; }
NSString* _own_load_device_proof(void)                  { return nil; }
NSString* _own_load_registered_udid(void)               { return nil; }
int  _own_device_enrollment_pending(void)               { return 0; }
void _own_begin_device_enrollment(void (^cb)(int))      { if (cb) cb(1); }
void _own_resume_device_enrollment(void)                { }

// ─── License copy ─────────────────────────────────────────────────────────────
NSString* _own_license_copy(void)   { return @"FAKE-LICENSE"; }
void* _own_encode_config(void)      { return NULL; }

// ─── Logging (no-op) ─────────────────────────────────────────────────────────
void _own_log(int level, NSString *fmt, ...) { (void)level; (void)fmt; }
void _own_log_storage(void)              { }
void _own_logger_dispatch(void *ev)      { (void)ev; }
void _logger_event_set_________________(void *ev, int k, id v) { (void)ev;(void)k;(void)v; }
void _logger_once__(void)               { }

// ─── Misc stubs ──────────────────────────────────────────────────────────────
void* _bridge_async__(void (^blk)(void)) { if (blk) blk(); return NULL; }
void _own_validate_server_trust(void *challenge, void (^cb)(int, id)) {
    if (cb) cb(1, nil);  // always allow
}
void _no_dns_gate(void)              { }
void _nosock(void)                   { }
void _oldns(void)                    { }
void* _olcopy(id obj)                { return (__bridge void*)obj; }
void _own_msgSend(id obj, SEL sel)   { }
void _own_check_images(void)         { }  // already defined below as int, but here as stub
int  _kcD(void)                      { return 0; }
void _ownKcDelete_(const char *k)    { (void)k; }
void _pc720_clear(void *p)           { }
int  _pc720_parse(const void *data, size_t len, void *out) { return 1; }
int  _pc720_validate(const void *a, const void *b) { return 1; }
uint32_t _pc720_word(const void *p, int idx) { return 0; }

// ─── ObjC Classes ────────────────────────────────────────────────────────────
// Minimal implementations to prevent crashes when app calls [OLController ...].

@interface OLLoggerLock : NSObject
@end
@implementation OLLoggerLock
@end

@interface OLMenuActions : NSObject
+ (void)prepare;
+ (id)target;
@end
@implementation OLMenuActions
+ (void)prepare {}
+ (id)target { return nil; }
@end

@interface OLPennyDialogHandle : NSObject
@end
@implementation OLPennyDialogHandle
@end

@interface OLDeviceRegistrar : NSObject
@end
@implementation OLDeviceRegistrar
@end

// OLController – main license controller
// App creates/uses this. We make it always report "granted".
@interface OLController : NSObject
+ (instancetype)sharedController;
- (void)start;
- (void)startWithCompletionHandler:(void(^)(BOOL))handler;
- (BOOL)isActive;
- (BOOL)hasGrant;
- (BOOL)wantsDialog;
- (BOOL)isPending;
- (void)presentKeyDialog;
- (void)dismissKeyDialog;
- (NSString*)licenseKey;
- (void)setKey:(NSString*)key;
@end

@implementation OLController {
    BOOL _active;
}

+ (instancetype)sharedController {
    static OLController *inst;
    static dispatch_once_t tok;
    dispatch_once(&tok, ^{ inst = [OLController new]; inst->_active = YES; });
    return inst;
}

- (void)start                                           { }
- (void)startWithCompletionHandler:(void(^)(BOOL))h    { if (h) h(YES); }
- (BOOL)isActive                                        { return YES; }
- (BOOL)hasGrant                                        { return YES; }
- (BOOL)wantsDialog                                     { return NO; }
- (BOOL)isPending                                       { return NO; }
- (void)presentKeyDialog                                { }
- (void)dismissKeyDialog                                { }
- (NSString*)licenseKey                                 { return @"FAKE"; }
- (void)setKey:(NSString*)key                           { (void)key; }

// Forward unknown messages silently
- (id)forwardingTargetForSelector:(SEL)sel { return nil; }
- (void)doesNotRecognizeSelector:(SEL)sel  { }

@end

// Re-declare check_images as int (needed by Penny)
#undef _own_check_images
int _own_check_images(void) { return 1; }

// ─── Constructor: grant immediately on load ───────────────────────────────────
__attribute__((constructor))
static void fake_own_init(void) {
    s_grant = 1;
}
