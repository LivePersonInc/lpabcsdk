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
	CreateSDE method return an SDEBase object in a closure, which then could be setup with a desired SDE.
	Once setup the sde will be added to a stack that will needs an explicit send:



