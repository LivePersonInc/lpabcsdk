Liveperson ABC SDK goal is to provide integration solutions for iOS apps (Host & iMessage app/ Extension) with LiveEngage platform. 
After sending a custom interactive message (CIM), this SDK will allows you to enhance the conversation by reporing any of the supported consumer behavior/SDEs, as engagement attributes to the Liveengage platform:  
https://developers.liveperson.com/engagement-attributes-types-of-engagement-attributes.html

LE Account Configuration/ Server side installation:
1. Enable SDK via Houston:  Messaging Gateway- Apple, set SDK Enabled flag to ‘true’
2. Enable App installation and obtain appinstallID in houston/Messaging Gateway/Apple
3. Make sure site settings enabled with messaging.sdes
4. Make sure site setting file sharing isset to 'true'

XCode Installation:

1. Copy lpabcsdk.framework to your XCode project, make sure it is included in Embedded Binaries section, 
    under project settings/ General tab for the iMessageApp Target, and  your App target (if needed ).
    
2. In project settings, navigate to the Build Phases tab, and paste the following:

"${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/LPABCSDK.framework/LPABCSDKStrippingScript.sh"
   
3. In the info.plist of each implemented targets, create a dictionary with the key ‘LPABC_PARAMS’ 
    and add a key: lpabc_appgroup  with the value of your app group:  lpabc_appgroup : <your_app_group_id>

4. Import lpabcsdk and initialize the SDK

5. For enabling sde reporting ability, In the iMessage app/extension -  add the following code in the overrides of
	- override func didBecomeActive(with conversation: MSConversation) AND
	- override func didReceive(_ message: MSMessage, conversation: MSConversation)  of MSMessagesAppViewController:

	self.lpabcsdk.updateWithIncomingInteractiveMessage(with: conversation, message: message)


Implementation:

- Initializing the SDK:
	LPABCSDK.initializeSDK()  - default log level will be .info, enable = true
	LPABCSDK.initializeSDK(minimumLogLevel: .trace, enableLog: true)

- Create SDEs: 

		createSDE(sdeType: SDE_Type,
	                          autoSendWhenIdle: Bool? = false,
	                          completion: (inout SDEBase)

	CreateSDE function will generate an SDEBase object with a template reference to the relevant SDE type that passed in parameter, as a completion closure. 
	A setup call on the callback sde is required inorder to initiate the sde with all relevant params, and add it to a stack. 
	* optional - autoSendWhenIdle, when set to true, the sde will be added to the idleStack which automatically send the stack once idele timeout is met. Detfault is 5 sec but could be anything between 0-15 sec.
	see setSDEStackIdleInterval(interval:)
	 
- setSDEStackIdleInterval(interval:15)
	This will setup an Idle timeout interval for auto sending the idle SDE stack (optional).
	default is 5sec and Max is 15 sec.

- send SDE:
		sendSDEStack(onSuccess success: successClosureType = nil,
	    	                          onFailure failure: failiurClosureType = nil) 

	Sending the agregated SDE stack (when idle stack is not selected). 
	callback with success/faliour closures.

	    	                          
- implicitSDEClosure
	Will get invoked when a qualifying event is met, and callback the type of that event 
	see eventLPimplicitEventCallbackType 


- eventLPimplicitEventCallbackType is the type of event being caled back from the implicitSDEClosure

















