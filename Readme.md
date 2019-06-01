# LivePerson iOS ABC SDK: a lightweighted SDK for iMessage app/Extension and host App.


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

2. If embeded in your host app, in project settings, navigate to the Build Phases tab, and click the + button to paste the following:

```
 	${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/LPABCSDK.framework/LPABCSDKStrippingScript.sh
```

3. For each implementing target, make sure to enable App groups in capabilities section in the info.plist: 
	- create a dictionary with the key **‘LPABC_PARAMS’** and add a key: **lpabc_appgroup**  with the value of your app group (same across all targeta):  **lpabc_appgroup : <your_app_group_id>**

4. Import lpabcsdk and initialize the SDK  
5. For enabling sde reporting ability, In the iMessage app/extension add the following code in the overrides of

- **override func didBecomeActive(with conversation: MSConversation)**
	 
- **override func didReceive(_ message: MSMessage, conversation: MSConversation)  of MSMessagesAppViewController:**

```
	self.lpabcsdk.updateWithIncomingInteractiveMessage(with: conversation, message: message)

```



## SDK Implementation
-  Initializing the SDK:

```	LPABCSDK.initializeSDK() - default: log level is .info, enable = true
	LPABCSDK.initializeSDK(minimumLogLevel: .trace, enableLog: true)
```

- Create SDEs: 

	**createSDE** function is return an **SDEBase** object in a callback closure, which then could be setup with a desired SDE.
Once setup, the SDE will be added to a stack that expects an explicit send:

```
	lpabcsdk.createSDE(sdeType: .cartUpdate) { (sdeBase) in  
		
        //setup the sde:
		sdeBase.cartUpdate?.setup(...)
	}
```

Example 1: 

```
	lpabcsdk.createSDE(sdeType: .visitorError) { (sdeBase) in

            	sdeBase.visitorError?.setup(contextId: "<CONTEXID>",
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
            let product = SDEProduct.init(name: "<>", category: "<>", sku: "<>", price: 100, quantity: 3)
           
            //Setup the sde:
            sdeBase.cartUpdate?.setup(total: 100, currency: "<>", numItems: 1, products: [product])
        }
```
 
 Setup sde could be also be created with a **json** string or **Dictionary** object:
	  
Example:
```  
	sdeBase.setupWithJson("{\"type\":\"ctmrinfo\"}")
	sdeBase.setupWithJson(["type":"cart"])
```

- Sending SDE
For sending SDE Stack,  use

```  
	lpabcsdk.sendSDEStack()  

	//Using completion callbacks:
	lpabcsdk.sendSDEStack(onSuccess: { (success) in
         	   	 
        		}) { (error) in
          		 
      	 	 }
```  

- Auto Sending SDE Stack When Idle:
 
	When autoSendWhenIdle is true, SDEs will get aggregated in an SDE stack and will get sent automatically once the stack activity is idle (wait interval).

	You can set the wait time (0-15 sec, default: 5 sec):

```
	lpabcsdk.setSDEStackIdleInterval(interval: 8)
```
Example:


```

 	lpabcsdk.createSDE(sdeType: .customerInfo, autoSendWhenIdle: true) { (sdeBase) in
            
         	  	 sdeBase.customerInfo?.setup(cstatus: "<cstatus>",
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
                                   	 lastPaymentDate: SDEDate.init(day: 23, 
																 month: 4, 	
																  year: 2019),
                                                      registrationDate: nil)
        }

```

-   For getting a success/failure callback of idle SDE stack, you can implement idleSDEStackCompletion closure:

```
	lpabcsdk.idleSDEStackCompletion = {  success  in
    	              <YOUR CUSTOM CODE HERE>
    		 }
```

- Implicit SDE:

 	Some actions will trigger an implicit SDE flow. This will be in a form of a dedicated  callback closure returning the type of flow - ImplicitSDEType)
Then you can set the desired SDEs to express your custom reporting for the  event triggered. 
Currently the only event expressing this is upon receiving a new CIMf or the first time, per conversation ID.

	The type will be called back as follow:
    
    lpabcsdk.implicitSDEClosure = { implicitType  in 

```
	switch implicitType {
			<YOUR CUSTOM CODE HERE i.e sendCustomerInfoSDE()>
		}
   }
```

- Send CIM (custom interactive message) reply * supported in iMessage target only

```
	appendReplayMessagePayload(message: MSMessage, textContext: String)
```

Example:
```
	//Create an MSMEssage to send:
	Let messageToSend = createMessage()  

	//Append text:
	lpabcsdk.appendReplayMessagePayload(message: messageToSend, textContext: "<YOUR_CUSTOM_TEXT>")
```
- Erasable SDE’s (sending onlly the ‘type’)
	- Cart update
	- *Customer info (authenticated fields used by connector)
	- *Personal info (authenticated fields used by connector)
	- Marketing source
	- Service Activity

These SDEs will get deleted from the widgets when sent with type only.

- Sample app (enterprise):
	 
	https://s3.amazonaws.com/lp-mobile-apps/lpabcsdk/index.html
	
   	User: lptester
    	Password: lp1234
    
* Trust certificate:
	Settings/General/Device Management/Lookio
    
- LE Widget: 
	https://s3.amazonaws.com/lp-mobile-apps/structureContentWidget/strcutured-content-widget/index.html   




    
