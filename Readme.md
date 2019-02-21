VideoEngager - Client SDK
===

This is the VideoEngager Client SDK for iOS. Embedding it into your application will allow your users to call an agent.

# Install

SDK is distributed as a dynamic iOS framework that you can drag and drop into your existing projects.

Once you've downloaded and unpacked the framework, navigate to your Xcode project's General settings page. Drag and drop VideoEngager.framework onto the Embedded Binaries section. Ensure that "Copy items if needed" is checked and press Finish. This will add VideoEngager.framework to both the Embedded Binaries and Linked Frameworks and Libraries sections. You'll also need to add -ObjC to the Other Linker Flags in your app project settings.

# SDK API

## Obtain instance

The recommended way to install VideoEngager into your application is to place a call to +startWithContainerPath:andServerAddress: in your -application:didFinishLaunchingWithOptions: or -applicationDidFinishLaunching: method.


``` ObjC
NSURL* serverAddress = [NSURL URLWithString:@"https://videome.leadsecure.com"];

NSURL* containerPath = [NSURL fileURLWithPath: [self supportDirectory]];

VideoEngager *videoEngager = [VideoEngager startWithContainerPath:containerPath andServerAddress:serverAddress];
```

## Join an agent

Joins the agent by the given path. The process is asynchronous.

``` ObjC
@param agentPath The agent's path (e.g. "john" or "sales/john")
@param name Optional visitor's name
@param email Optional visitor's email address
@param phone Optional visitor's phone number
@param completionHandler A callback called once the join process has been completed

- (void) joinWithAgentPath: (NSString*) agentPath
                  withName: (NSString*) name
                 withEmail: (NSString*) email
                 withPhone: (NSString*) phone
            withCompletion: (void (^__nonnull)(NSError* __nullable error, VDEAgent* __nullable agent)) completionHandler;
```

Joins the agent by the given url. The process is asynchronous.

``` ObjC
@param agentPath The agent's path (e.g. "john" or "sales/john")
@param externalServerAddress The address of the external system
@param firstName Mandatory visitor's first name
@param lastName Mandatory visitor's last name
@param email Optional visitor's email address
@param subject Optional visitor's subject for the video call
@param completionHandler A callback called once the join process has been completed

- (void) joinWithAgentPath: (NSString*) agentPath
     externalServerAddress: (NSURL   *) externalServerAddress
             withFirstName: (NSString*) firstName
              withLastName: (NSString*) lastName
                 withEmail: (NSString*) email
               withSubject: (NSString*) subject
           withCompletion: (void (^__nonnull)(NSError* __nullable error, VDEAgent* __nullable agent)) completionHandler;
```

## Disconnect

Disconnects from the connected agent if any. The process is asynhcronous.

``` ObjC
@param completionHandler A callback called once the disconnect process has been completed

- (void) disconnectWithCompletion: (void (^__nonnull)(NSError* __nullable error)) completionHandler;

```

## UX/UI

SDK provide a high level API to present agent's In Call functionality
To get the View controller with this functionality invokde the VideoEngager's  agentViewController API

``` ObjC
- (VDEAgentViewController*) agentViewController;
```

# Demo App

For a fully functional sample application you can refer to a project file located inside sample/demo.xcodeproject file.
