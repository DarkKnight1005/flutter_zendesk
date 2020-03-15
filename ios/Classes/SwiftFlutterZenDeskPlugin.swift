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
           // CoreLogger.enabled = true
           // CoreLogger.logLevel = .debug
            let args = call.arguments as? NSDictionary

            let appId = args!["appId"]as? String
            let clientId  = args!["clientId"]as? String
            let url = args!["url"]as? String
            let token = args!["token"]as? String

            Zendesk.initialize(appId: appId!,
                               clientId: clientId!,
                               zendeskUrl: url!)
            Support.initialize(withZendesk: Zendesk.instance)

            let ident = Identity.createJwt(token: token ?? "")
            Zendesk.instance?.setIdentity(ident)
            result(nil)

        case "initNotifications" :
            let args = call.arguments as? NSDictionary
            let fcmToken = args!["fcmToken"]as? String
            ZDKPushProvider(zendesk: Zendesk.instance!).register(deviceIdentifier: fcmToken ?? "", locale: NSLocale.preferredLanguages.first ?? "en") { (pushResponse, error) in
                    if (error != nil){
                    print("Couldn't register device: \(fcmToken ?? ""). Error: \(String(describing: error))")
                } else {
                    print("Successfully registered device: \(fcmToken ?? "")")
                 }
            }
            result(nil)
        case "openTicket" :
           let args = call.arguments as? NSDictionary
           let requestID = args!["ticketId"]as? String
           print("Zendesk call openTicket ",  terminator: "")
           print(requestID! as String)

           let viewController = RequestUi.buildRequestUi(requestId: requestID ?? "")

           let rootViewController:UIViewController! = UIApplication.shared.keyWindow?.rootViewController
             if (rootViewController is UINavigationController) {
                 (rootViewController as! UINavigationController).pushViewController(viewController, animated:true)
             } else {
                 let navigationController:UINavigationController! = UINavigationController(rootViewController:viewController)
               rootViewController.present(navigationController, animated:true, completion:nil)
             }
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
