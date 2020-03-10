package com.nowappstech.flutter_zendesk;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.List;
import android.util.Log;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import zendesk.commonui.UiConfig;
import zendesk.core.AnonymousIdentity;
import zendesk.core.Identity;
import zendesk.core.Zendesk;
import zendesk.support.Support;
import zendesk.support.guide.HelpCenterActivity;
import zendesk.support.request.RequestActivity;
import zendesk.support.requestlist.RequestListActivity;
import zendesk.core.JwtIdentity;
import com.zendesk.logger.Logger;

public class FlutterZendeskPlugin implements MethodCallHandler {

    private static Registrar mRegistrar;

    public static void registerWith(Registrar registrar) {
        mRegistrar = registrar;
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_zendesk");
        channel.setMethodCallHandler(new FlutterZendeskPlugin());
    }

    @Override
    public void onMethodCall(MethodCall call, @NonNull Result result) {

        switch(call.method)
        {
            case "initiate":
                Logger.setLoggable(true);

                String url = call.argument("url");
                String appId = call.argument("appId");
                String clientId = call.argument("clientId");
                String token = call.argument("token");

                Zendesk.INSTANCE.init(mRegistrar.context(), url,
                        appId,
                        clientId);

                Log.d("Zendesk","got token " + token);

                Identity identity = new JwtIdentity(token);
                Zendesk.INSTANCE.setIdentity(identity);
                Support.INSTANCE.init(Zendesk.INSTANCE);
                result.success("Zendesk Initialized");
                break;
            case "help":
                HelpCenterActivity.builder()
                        .withContactUsButtonVisible(false)
                        .withShowConversationsMenuButton(false)
                        .show(mRegistrar.activity());
                result.success("Zendesk Help Center Initialized");
                break;
            case "feedback":
                RequestListActivity.builder()
                        .show(mRegistrar.activity());
                result.success("Zendesk Request Center Initialized");
                break;
            default:
                result.notImplemented();
        }
    }
}

