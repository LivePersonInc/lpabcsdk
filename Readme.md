# LivePerson iOS ABC SDK
## A lightweight SDK for iMessage app/Extension as well as host apps*
(pending incoming, **agent to consumer** CIM ).


LivePerson ABC SDK goal is to provide integration solutions for iOS apps (Host & iMessage app/ Extension) with LiveEngage platform. After sending a custom interactive message (CIM), this SDK will allows you to enhance the conversation experience with the following features:

-  Reporing any of the supported consumer behavior/SDEs, as engagement attributes to the Liveengage platform:
https://developers.liveperson.com/engagement-attributes-types-of-engagement-attributes.html
-  Abvility to send a Custom Interactive Message (CIM) reply message from consumer to agent, with a unique textual context.
-  Notify special events callback.

Apple and LivePerson Configuration
Make sure you have an Apple Business Chat business ID.
Contact your LivePerson account representative to enable this SDK on the backend server.


## SDK Installation:  Manual installation:

1. Copy lpabcsdk.framework to your XCode project, make sure it is included in **Embedded Binaries** section, under **project settings/ General** tab for the main app Target, and in the Linked Frameworks and Libraries in the iMessageApp Target, as well as in Linked Binary With Libraries under Build Phases of each implementing target.

2. In project settings, navigate to the Build Phases tab, and click the + button to paste the following:

```
${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/LPABCSDK.framework/LPABCSDKStrippingScript.sh
```
## CocoaPods installation:
1. Install CocoaPods:
```
sudo gem install cocoapods
``` 

2. Navigate to your project folder and create a Podfile for your project:
```
pod init
```

3. Open the Podfile.
```open -a Xcode Podfile
```

4. Add the LPABCSDK pod to integrate it into your Xcode project. Make sure you change the target name to your target name:

``` target '<Your Target Name>' do
     platform :ios, '11.3'
     use_frameworks!
     pod 'LPABCSDK'
 end
 ```

3. For each implementing target, make sure to enable App groups in capabilities section in the info.plist: 
- create a dictionary with the key **‘LPABC_PARAMS’** and add a key: **lpabc_appgroup**  with the value of your app group (same across all targeta):  **lpabc_appgroup : <your_app_group_id>**

4. Import lpabcsdk and initialize the SDK : 

### Initializing the SDK

This method initializes the SDK.

```swift
//Basic initializer, the default minimumLogLevel will be .info.
LPABCSDK.initialize()

//Initializer with explicit log level
LPABCSDK.initialize(minimumLogLevel: .trace)

//For disabling logs use LPABCLogLevel.none
LPABCSDK.initialize(minimumLogLevel: .none)


//Use 'eventSubscription' for passing the events 'LPABCEvent' you wish to get a callback notification for. 
//If not explicitly stated, the default would be subscribing to all events.
LPABCSDK.initialize(minimumLogLevel: .none, eventSubscription: [.newConversation])

//To disable events notification use 'LPABCEvent.noEvents'
LPABCSDK.initialize(eventSubscription: LPABCEvent.noEvents)
```

-  Disposing the SDK:
```
    LPABCSDK.dispose()
```

5. In the iMessage app/extension's MessagesViewController class, please make sure to override the following methods:

### Update the SDK with Incoming CIM

Upon an agent sending a [Custom Interactive Message (CIM)](apple-business-chat-templates-custom-interactive-message-template.html) to the consumer, this method will update the SDK with a payload that will enable SDE reporting to LiveEngage.

```swift
func update(with conversation: MSConversation, message: MSMessage? = nil, abcsdkParams: ABCSDKParams? = nil)

```

- `message` sould be used where available and returned by the override method.

- `ABCSDKParams` is optional and should be used for passing references to the sdk. Should be used in `didBecomeActive` and `didSelect`.

Should be implemented from these override functions in the iMessage app extension `MSMessagesAppViewController`:

- `didBecomeActive(with conversation: MSConversation)`
- `didSelect(_ message: MSMessage, conversation: MSConversation)`
- `didReceive(_ message: MSMessage, conversation: MSConversation)`

See [step 6 of Installation for more](apple-business-chat-sdk-installation.html#sdk-installation-in-xcode).

For passing in references to the SDK (optional), please and use SDKParams to reference elements such as MSMessagesAppViewController, etc. See the override of viewDidLoad() in the example below.
In the implementation of these methods, add the appropriate update() methods for each, seen in the example below.

```
import LPABCSDK

class MessagesViewController : MSMessagesViewController {

    var lpabcsdk = LPABCSDK.initializeSDK()
    var sdkParams: SDKParams?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.sdkParams =
        SDKParams(messagesViewController: self,
            secureFormReplyImagee: <Reference to a `UIimage` used for s secure form reply message MSMessageLayout image>,
            secureFormReplyText: `<Contextual text for you secure form reply message in Live Engage>`)
    }

    override func didBecomeActive(with conversation: MSConversation) {
        lpabcsdk.update(with: conversation, sdkParams: sdkParams)
    }

    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        lpabcsdk.update(with: conversation, message: message)
    }

    override func didSelect(_ message: MSMessage, conversation: MSConversation) {
        lpabcsdk.update(with: conversation, message: message, sdkParams: sdkParams)

    }

}
```

 
Update the SDK with Incoming CIM

Upon an agent sending a Custom Interactive Message (CIM) to the consumer, this method will update the SDK with a payload that will enable SDE reporting to LiveEngage.


### Create SDEs

When you create one or more SDEs, they get added to a dedicated stack.

The createSDE function generates and calls back an SDEBase object with a template of the relevant SDE type as its property, which then needs to implement a 'setup' function.

Pass in the SDE type that you want, and it will return an SDEBase object containing an instantiated property of the relevant SDE template object.

All dependent schema objects could be initiated and passed in as arguments to the SDE setup

Inside of the completion callback, on the sde setup method, it is required to define the relevant params to initiate the sde.mpletion callback, on the sde setup method, it is required to define the relevant params to initiate the sde.

Example 1: 

``` 
lpabcsdk.createSDE(sdeType: .visitorError) { (sdeBase) in
    sdeBase.visitorError?.setup(
        contextId: "<CONTEXID>",
        message: "<MESSAGE>",
        code: "<CODE>",
        level: 0,
        resolved: true
    )
}
```

Example 2:

``` 
lpabcsdk.createSDE(sdeType: .cartUpdate) { (sdeBase) in
    //Create a product:
    let product = SDEProduct.init(
        name: "<>",
        category: "<>",
        sku: "<>",
        price: 100,
        quantity: 3
    )

    //Setup the sde:
    sdeBase.cartUpdate?.setup(
        total: 100,
        currency: "<>",
        numItems: 1,
        products: [product]
    )
}
```

The SDE `setup` call could also be created using 'UnifiedLooseSDE', as **json** string or **Dictionary** object:

Example:

```
sdeBase.setupWithJson("{\"type\":\"ctmrinfo\"}")
sdeBase.setupWithJson(["type":"cart"])
```

### Auto Send Aggregated Stack

The optional `aggregate` parameter, when set to true, will add the sde to the **aggregateStack** which will get **sent automatically** once the [aggregation stack timeout](#Aggregated-SDE-Stack-Timeout) is met. Default is 5 sec but could be anything between 1-15 sec. See `setAggregatedInterval(interval:)`

Example:

``` 
    lpabcsdk.createSDE(sdeType: .customerInfo, aggregate: true) { (sdeBase) in
                            sdeBase.customerInfo?.setup(
                                    cstatus: "<cstatus>",
                                    ctype: "<ctype>",
                                    balance: 10,
                                    currency: "<currency>",
                                    socialId: "<socialId>",
                                    imei: "<imei>",
                                    userName: "<userName>",
                                    companySize: 30,
                                    companyBranch: "<companyBranch>",
                                    accountName: "<accountName>",
                                    role: "<role>",
                                    loginStatus: 0,
                                    storeZipCode: "<storeZipCode>",
                                    storeNumber: "<storeNumber>",
                                    lastPaymentDate: SDEDate.init(
                                    day: 23, 
                                    month: 4,     
                                    year: 2019),
                                    registrationDate: nil)
}
```

###  Sending SDE

In order to **manually** send the SDE Stack, use the following:

``` 
    lpabcsdk.sendSDEStack()

        // or using completion callbacks:
            lpabcsdk.sendSDEStack(onSuccess: { (success) in
                
                // success block}) 
                
                { (error) in
                        // error block
                }
``` 
You can check if the sdk has a payload cache loaded before sending SDEs, using  `isCahceLoaded`:
```
lpabcsd.isCahceLoaded
```

### Aggregated SDE Stack Timeout

This will setup a timeout interval for auto sending the aggregated SDE stack (optional). Default is 5 seconds and Max is 15.

``` 
    lpabcsdk.setAggregatedInterval(interval:15)
```

See the [Auto Send aggregated](#Auto-Send-Aggregated) optional parameter in [Create SDEs](#create-sdes).

### Aggregated SDE Stack Send Completion Closure

If you want to execute code whenever the Aggregated SDE Stack auto send completes, implement the `aggregatedSDEStackCompletion` closure:

``` 
    lpabcsdk.aggregatedSDEStackCompletion = {  completion, error in
            // debug code
        }

```

### Event Callback
Some consumer actions can trigger meaningful events (eg. a new conversation starts, secure form completion, etc.). If you would like to act upon, or send an SDE once a subscribed event has been triggered, you can do so by implenting the abcEventCallback closure.

```
lpabcsdk.abcEventCallback = { event  in
    // implement
}
```

`LPABCEvent` - Indicates the type of event that is being called back from the abcEventCallback.

`abcEventCallback` - Invoked when a qualifying subscribed event is met, and callback the type of that event

You can set the desired SDEs to express your custom reporting for the event triggered.

Supported Event Types: - newConversation - Receiving an incoming (agent to consumer), new first time CIM - per conversation. - secureForm - Receiving an incoming (agent to consumer) secure Form: See the Secure Form documentation. Example:


```
lpabcsdk.implicitEventClosure = { implicitType in
    switch implicitType {
        case .newConversation:
            // Create and send desired SDE
             break
        case .secureForm(.submitted):
            // Create and send desired SDE
            break
    }
}

```

## Reply CIM from Consumer to Agent

An agent can recieve back from the consumer a Custom Interactive Message with contextual text. This text can be displayed to the agent in the LiveEngage workspace.

For example, if the consumer selects a product inside of your iMessage app, the Agent can see which product they selected via the textContext of this method.

```
// create MSMessage object

lpabcsdk.appendReplayMessagePayload(message: MSMessage, textContext: String)

// send MSMessage object
```
Pass in the initiated MSMessage object, and the desired textual String.

### Synchronize SDK (Host app target feature)
When called, the SDK will explicitly sync with the latest cache version.

The best practice will be to add this to your AppDelegate/ applicationWillEnterForeground, in order to use the monitoring ability when the host app enters  foreground.

An iMesssage extension target will have no effect calling this function.
```
func applicationWillEnterForeground(_ application: UIApplication) {
    LPABCSDK.synchronize()
}

```
