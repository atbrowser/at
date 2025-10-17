#import <Foundation/Foundation.h>
#import "SwiftBridge.h"
#include <napi.h>

class SwiftAddon : public Napi::ObjectWrap<SwiftAddon> {
public:
    static Napi::Object Init(Napi::Env env, Napi::Object exports) {
        Napi::Function func = DefineClass(env, "SwiftAddon", {
            InstanceMethod("helloWorld", &SwiftAddon::HelloWorld),
            InstanceMethod("helloGui", &SwiftAddon::HelloGui),
            InstanceMethod("triggerHapticFeedback", &SwiftAddon::TriggerHapticFeedback),
            InstanceMethod("initCouchDB", &SwiftAddon::InitCouchDB),
            InstanceMethod("getAllDBs", &SwiftAddon::GetAllDBs),
            InstanceMethod("createDB", &SwiftAddon::CreateDB),
            InstanceMethod("deleteDB", &SwiftAddon::DeleteDB),
            InstanceMethod("insertDocument", &SwiftAddon::InsertDocument),
            InstanceMethod("getDocument", &SwiftAddon::GetDocument),
            InstanceMethod("on", &SwiftAddon::On)
        });

        Napi::FunctionReference* constructor = new Napi::FunctionReference();
        *constructor = Napi::Persistent(func);
        env.SetInstanceData(constructor);

        exports.Set("SwiftAddon", func);
        return exports;
    }

    struct CallbackData {
        std::string eventType;
        std::string payload;
        SwiftAddon* addon;
    };

    SwiftAddon(const Napi::CallbackInfo& info)
        : Napi::ObjectWrap<SwiftAddon>(info)
        , env_(info.Env())
        , emitter(Napi::Persistent(Napi::Object::New(info.Env())))
        , callbacks(Napi::Persistent(Napi::Object::New(info.Env())))
        , tsfn_(nullptr) {

        napi_status status = napi_create_threadsafe_function(
            env_,
            nullptr,
            nullptr,
            Napi::String::New(env_, "SwiftCallback"),
            0,
            1,
            nullptr,
            nullptr,
            this,
            [](napi_env env, napi_value js_callback, void* context, void* data) {
                auto* callbackData = static_cast<CallbackData*>(data);
                if (!callbackData) return;

                Napi::Env napi_env(env);
                Napi::HandleScope scope(napi_env);

                auto addon = static_cast<SwiftAddon*>(context);
                if (!addon) {
                    delete callbackData;
                    return;
                }

                try {
                    auto callback = addon->callbacks.Value().Get(callbackData->eventType).As<Napi::Function>();
                    if (callback.IsFunction()) {
                        callback.Call(addon->emitter.Value(), {Napi::String::New(napi_env, callbackData->payload)});
                    }
                } catch (...) {}

                delete callbackData;
            },
            &tsfn_
        );

        if (status != napi_ok) {
            Napi::Error::New(env_, "Failed to create threadsafe function").ThrowAsJavaScriptException();
            return;
        }

        auto makeCallback = [this](const char* eventType) {
            return ^(NSString* payload) {
                if (tsfn_ != nullptr) {
                    auto* data = new CallbackData{
                        eventType,
                        std::string([payload UTF8String]),
                        this
                    };
                    napi_call_threadsafe_function(tsfn_, data, napi_tsfn_blocking);
                }
            };
        };
    }

    ~SwiftAddon() {
        if (tsfn_ != nullptr) {
            napi_release_threadsafe_function(tsfn_, napi_tsfn_release);
            tsfn_ = nullptr;
        }
    }

private:
    Napi::Env env_;
    Napi::ObjectReference emitter;
    Napi::ObjectReference callbacks;
    napi_threadsafe_function tsfn_;

    Napi::Value HelloWorld(const Napi::CallbackInfo& info) {
        Napi::Env env = info.Env();

        if (info.Length() < 1 || !info[0].IsString()) {
            Napi::TypeError::New(env, "Expected string argument").ThrowAsJavaScriptException();
            return env.Null();
        }

        std::string input = info[0].As<Napi::String>();
        NSString* nsInput = [NSString stringWithUTF8String:input.c_str()];
        NSString* result = [SwiftBridge helloWorld:nsInput];

        return Napi::String::New(env, [result UTF8String]);
    }

    void HelloGui(const Napi::CallbackInfo& info) {
        [SwiftBridge helloGui];
    }

    void TriggerHapticFeedback(const Napi::CallbackInfo& info) {
        Napi::Env env = info.Env();

        if (info.Length() < 1 || !info[0].IsNumber()) {
            Napi::TypeError::New(env, "Expected number argument for haptic pattern").ThrowAsJavaScriptException();
            return;
        }

        int pattern = info[0].As<Napi::Number>().Int32Value();
        [SwiftBridge triggerHapticFeedback:pattern];
    }

    Napi::Value InitCouchDB(const Napi::CallbackInfo& info) {
        Napi::Env env = info.Env();

        if (info.Length() < 4 || !info[0].IsString() || !info[1].IsNumber() || 
            !info[2].IsString() || !info[3].IsString()) {
            Napi::TypeError::New(env, "Expected (host, port, username, password) arguments").ThrowAsJavaScriptException();
            return env.Null();
        }

        std::string host = info[0].As<Napi::String>();
        int port = info[1].As<Napi::Number>().Int32Value();
        std::string username = info[2].As<Napi::String>();
        std::string password = info[3].As<Napi::String>();

        NSString* nsHost = [NSString stringWithUTF8String:host.c_str()];
        NSString* nsUsername = [NSString stringWithUTF8String:username.c_str()];
        NSString* nsPassword = [NSString stringWithUTF8String:password.c_str()];

        NSString* result = [SwiftBridge initCouchDBWithHost:nsHost 
                                                       port:port 
                                                   username:nsUsername 
                                                   password:nsPassword];

        return Napi::String::New(env, [result UTF8String]);
    }

    void GetAllDBs(const Napi::CallbackInfo& info) {
        Napi::Env env = info.Env();

        if (info.Length() < 1 || !info[0].IsFunction()) {
            Napi::TypeError::New(env, "Expected callback function").ThrowAsJavaScriptException();
            return;
        }

        Napi::Function callback = info[0].As<Napi::Function>();
        Napi::ThreadSafeFunction tsfn = Napi::ThreadSafeFunction::New(
            env, callback, "GetAllDBs", 0, 1);

        [SwiftBridge getAllDBs:^(NSString* result, NSString* error) {
            tsfn.BlockingCall([=](Napi::Env env, Napi::Function jsCallback) {
                if (error) {
                    jsCallback.Call({env.Null(), Napi::String::New(env, [error UTF8String])});
                } else {
                    jsCallback.Call({Napi::String::New(env, [result UTF8String]), env.Null()});
                }
            });
            tsfn.Release();
        }];
    }

    void CreateDB(const Napi::CallbackInfo& info) {
        Napi::Env env = info.Env();

        if (info.Length() < 2 || !info[0].IsString() || !info[1].IsFunction()) {
            Napi::TypeError::New(env, "Expected (dbName, callback) arguments").ThrowAsJavaScriptException();
            return;
        }

        std::string dbName = info[0].As<Napi::String>();
        Napi::Function callback = info[1].As<Napi::Function>();
        Napi::ThreadSafeFunction tsfn = Napi::ThreadSafeFunction::New(
            env, callback, "CreateDB", 0, 1);

        NSString* nsDbName = [NSString stringWithUTF8String:dbName.c_str()];

        [SwiftBridge createDB:nsDbName callback:^(NSString* result, NSString* error) {
            tsfn.BlockingCall([=](Napi::Env env, Napi::Function jsCallback) {
                if (error) {
                    jsCallback.Call({env.Null(), Napi::String::New(env, [error UTF8String])});
                } else {
                    jsCallback.Call({Napi::String::New(env, [result UTF8String]), env.Null()});
                }
            });
            tsfn.Release();
        }];
    }

    void DeleteDB(const Napi::CallbackInfo& info) {
        Napi::Env env = info.Env();

        if (info.Length() < 2 || !info[0].IsString() || !info[1].IsFunction()) {
            Napi::TypeError::New(env, "Expected (dbName, callback) arguments").ThrowAsJavaScriptException();
            return;
        }

        std::string dbName = info[0].As<Napi::String>();
        Napi::Function callback = info[1].As<Napi::Function>();
        Napi::ThreadSafeFunction tsfn = Napi::ThreadSafeFunction::New(
            env, callback, "DeleteDB", 0, 1);

        NSString* nsDbName = [NSString stringWithUTF8String:dbName.c_str()];

        [SwiftBridge deleteDB:nsDbName callback:^(NSString* result, NSString* error) {
            tsfn.BlockingCall([=](Napi::Env env, Napi::Function jsCallback) {
                if (error) {
                    jsCallback.Call({env.Null(), Napi::String::New(env, [error UTF8String])});
                } else {
                    jsCallback.Call({Napi::String::New(env, [result UTF8String]), env.Null()});
                }
            });
            tsfn.Release();
        }];
    }

    void InsertDocument(const Napi::CallbackInfo& info) {
        Napi::Env env = info.Env();

        if (info.Length() < 3 || !info[0].IsString() || !info[1].IsString() || !info[2].IsFunction()) {
            Napi::TypeError::New(env, "Expected (dbName, documentJson, callback) arguments").ThrowAsJavaScriptException();
            return;
        }

        std::string dbName = info[0].As<Napi::String>();
        std::string documentJson = info[1].As<Napi::String>();
        Napi::Function callback = info[2].As<Napi::Function>();
        Napi::ThreadSafeFunction tsfn = Napi::ThreadSafeFunction::New(
            env, callback, "InsertDocument", 0, 1);

        NSString* nsDbName = [NSString stringWithUTF8String:dbName.c_str()];
        NSString* nsDocumentJson = [NSString stringWithUTF8String:documentJson.c_str()];

        [SwiftBridge insertDocument:nsDbName documentJson:nsDocumentJson callback:^(NSString* result, NSString* error) {
            tsfn.BlockingCall([=](Napi::Env env, Napi::Function jsCallback) {
                if (error) {
                    jsCallback.Call({env.Null(), Napi::String::New(env, [error UTF8String])});
                } else {
                    jsCallback.Call({Napi::String::New(env, [result UTF8String]), env.Null()});
                }
            });
            tsfn.Release();
        }];
    }

    void GetDocument(const Napi::CallbackInfo& info) {
        Napi::Env env = info.Env();

        if (info.Length() < 3 || !info[0].IsString() || !info[1].IsString() || !info[2].IsFunction()) {
            Napi::TypeError::New(env, "Expected (dbName, docId, callback) arguments").ThrowAsJavaScriptException();
            return;
        }

        std::string dbName = info[0].As<Napi::String>();
        std::string docId = info[1].As<Napi::String>();
        Napi::Function callback = info[2].As<Napi::Function>();
        Napi::ThreadSafeFunction tsfn = Napi::ThreadSafeFunction::New(
            env, callback, "GetDocument", 0, 1);

        NSString* nsDbName = [NSString stringWithUTF8String:dbName.c_str()];
        NSString* nsDocId = [NSString stringWithUTF8String:docId.c_str()];

        [SwiftBridge getDocument:nsDbName docId:nsDocId callback:^(NSString* result, NSString* error) {
            tsfn.BlockingCall([=](Napi::Env env, Napi::Function jsCallback) {
                if (error) {
                    jsCallback.Call({env.Null(), Napi::String::New(env, [error UTF8String])});
                } else {
                    jsCallback.Call({Napi::String::New(env, [result UTF8String]), env.Null()});
                }
            });
            tsfn.Release();
        }];
    }

    Napi::Value On(const Napi::CallbackInfo& info) {
        Napi::Env env = info.Env();

        if (info.Length() < 2 || !info[0].IsString() || !info[1].IsFunction()) {
            Napi::TypeError::New(env, "Expected (string, function) arguments").ThrowAsJavaScriptException();
            return env.Undefined();
        }

        callbacks.Value().Set(info[0].As<Napi::String>(), info[1].As<Napi::Function>());
        return env.Undefined();
    }
};

Napi::Object Init(Napi::Env env, Napi::Object exports) {
    return SwiftAddon::Init(env, exports);
}

NODE_API_MODULE(swift_addon, Init)