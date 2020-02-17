import Flutter
import UIKit
import ZendeskSDK
import ZendeskCoreSDK


public class SwiftFlutterZenDeskPlugin: NSObject, FlutterPlugin {
    
    let controller: FlutterViewController
    
    var flutterResult: FlutterResult?
    
    init(controller: FlutterViewController) {
        self.controller = controller
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        
        let channel = FlutterMethodChannel(name: "flutter_zendesk", binaryMessenger: registrar.messenger())
        
        let storyboard : UIStoryboard? = UIStoryboard.init(name: "Main", bundle: nil);
        
        let viewController: UIViewController? = storyboard!.instantiateViewController(withIdentifier: "FlutterViewController")
        
        let instance = SwiftFlutterZenDeskPlugin(controller: viewController as! FlutterViewController)
        
        registrar.addMethodCallDelegate(instance, channel: channel)
        
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.flutterResult = result

        switch call.method {
        case "initiate":
            let args = call.arguments as? NSDictionary

            let appId = args!["appId"]as? String
            let clientId  = args!["clientId"]as? String
            let url = args!["url"]as? String

            Zendesk.initialize(appId: appId!,
                               clientId: clientId!,
                               zendeskUrl: url!)
            Support.initialize(withZendesk: Zendesk.instance)

            let ident = Identity.createAnonymous()
            Zendesk.instance?.setIdentity(ident)
            result(nil)

        case "help":
            let hcConfig = HelpCenterUiConfiguration()
            hcConfig.hideContactSupport = true

            let articleUiConfig = ArticleUiConfiguration()
            articleUiConfig.showContactOptions = false   // hide in article screen

            let helpCenter = HelpCenterUi.buildHelpCenterOverviewUi(withConfigs: [hcConfig, articleUiConfig])

            let rootViewController:UIViewController! = UIApplication.shared.keyWindow?.rootViewController
              if (rootViewController is UINavigationController) {
                  (rootViewController as! UINavigationController).pushViewController(helpCenter, animated:true)
              } else {
                  let navigationController:UINavigationController! = UINavigationController(rootViewController:helpCenter)
                rootViewController.present(navigationController, animated:true, completion:nil)
              }
             result(nil)

        case "feedback":
           let feedback = RequestUi.buildRequestList()
           let rootViewController:UIViewController! = UIApplication.shared.keyWindow?.rootViewController
             if (rootViewController is UINavigationController) {
                 (rootViewController as! UINavigationController).pushViewController(feedback, animated:true)
             } else {
                 let navigationController:UINavigationController! = UINavigationController(rootViewController:feedback)
               rootViewController.present(navigationController, animated:true, completion:nil)
             }
           result(nil)

        default:
            flutterResult!(FlutterMethodNotImplemented)
        }

    }
}
