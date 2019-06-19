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


## SDK Installation

1. Copy lpabcsdk.framework to your XCode project, make sure it is included in **Embedded Binaries** section, under **project settings/ General** tab for the iMessageApp Target, and  your App target (if needed ).

2. In project settings, navigate to the Build Phases tab, and click the + button to paste the following:

```
${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/LPABCSDK.framework/LPABCSDKStrippingScript.sh
```

3. For each implementing target, make sure to enable App groups in capabilities section in the info.plist: 
- create a dictionary with the key **‘LPABC_PARAMS’** and add a key: **lpabc_appgroup**  with the value of your app group (same across all targeta):  **lpabc_appgroup : <your_app_group_id>**

4. Import lpabcsdk and initialize the SDK  

5. For enabling sde reporting ability, In the iMessage app/extension add the following code in the 2 override of

- **override func didBecomeActive(with conversation: MSConversation)**

- **override func didReceive(_ message: MSMessage, conversation: MSConversation)  of MSMessagesAppViewController:**

```
lpabcsdk.update(with: conversation)

lpabcsdk.update(with: conversation, message: message)

```

## SDK Implementation
-  Initializing the SDK:

```    LPABCSDK.initializeSDK() - default: log level is .info, enable = true
     LPABCSDK.initializeSDK(minimumLogLevel: .trace, enableLog: true)
```
-  Disposing the SDK:
```
    LPABCSDK.dispose()
```

### Create SDEs

When you create one or more SDEs, they get added to a Stack that the framework manages for you.

The `createSDE` function generates and calls back an SDEBase object with a template of the relevant SDE type as its property, which then needs to implement a 'setup' function.

Pass in the [SDE type](engagement-attributes-types-of-engagement-attributes.html) that you want, and it will return an SDEBase object containing an instantiated property of the relevant SDE template object.

All dependant schema objects could be initiated and passed in as arguments to the SDE setup 

Inside of the completion callback, on the sde setup method, it is required to define the relevant params to initiate the sde.

Example 1: 

``` 
lpabcsdk.createSDE(sdeType: .visitorError) { (sdeBase) in
                sdeBase.visitorError?.setup(
                    contextId: "<CONTEXID>",
                    message: "<MESSAGE>",
                    code: "<CODE>",
                    level: 0,
                    resolved: true)
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
                        quantity: 3)

//Setup the sde:
sdeBase.cartUpdate?.setup(
            total: 100, 
            currency: "<>", 
            numItems: 1, 
            products: [product])
}
```

The SDE `setup` call could also be created using 'LPUnifiedLooseSDEProtocol', as **json** string or **Dictionary** object:

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


### Implicit Event Callback

Some consumer actions can trigger an implicit event flow (eg. a new conversation starts). If you would like to send an SDE upon one of these events triggering, you can do so by implenting the `implicitEventClosure` method.

``` 
        lpabcsdk.implicitEventClosure = { implicitEventCallbackType in 
            // implement 
}
```

- `ImplicitEventCallbackType` - Indicates the type of implicit event that is being called back from the implicitEventClosure. 

- `implicitEventClosure` - Invoked when a qualifying event is met, and callback the type of that event 


You can set the desired SDEs to express your custom reporting for the  event triggered. 

**Supported Event Types**:
- `newConversation` - Receiving an **incoming (agent to consumer)**, new first time CIM - per conversation.

Example:

``` 
    lpabcsdk.implicitEventClosure = { implicitType in 
        switch implicitType {
        case .newConversation:
            // Create and send desired SDE
            }
        }
```

### Reply CIM from Consumer to Agent

An agent can recieve back from the consumer a Custom Interactive Message with contextual text. This text can be displayed to the agent in the LiveEngage workspace.

For example, if the consumer selects a product inside of your iMessage app, the Agent can see which product they selected via the `textContent` of this method.

``` 
    // create MSMessage object

        pabcsdk.appendReplayMessagePayload(message: MSMessage, textContext: String)

    // send MSMessage object
```

Pass in the initiated MSMessage object, and the desired textual String. 



