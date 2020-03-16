package com.nowappstech.flutter_zendesk;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.List;
import android.content.Intent;
import android.util.Log;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import zendesk.core.AnonymousIdentity;
import zendesk.core.Identity;
import zendesk.core.Zendesk;
import zendesk.support.Support;
import zendesk.support.guide.HelpCenterActivity;
import zendesk.support.request.RequestActivity;
import zendesk.support.request.RequestConfiguration;
import zendesk.support.requestlist.RequestListActivity;
import zendesk.core.JwtIdentity;
import com.zendesk.logger.Logger;
import com.zendesk.service.ErrorResponse;
import com.zendesk.service.ZendeskCallback;

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
                //Logger.setLoggable(true);

                String url = call.argument("url");
                String appId = call.argument("appId");
                String clientId = call.argument("clientId");
                String token = call.argument("token");

                Zendesk.INSTANCE.init(mRegistrar.context(), url,
                        appId,
                        clientId);

                Identity identity = new JwtIdentity(token);
                Zendesk.INSTANCE.setIdentity(identity);
                Support.INSTANCE.init(Zendesk.INSTANCE);
                result.success("Zendesk Initialized");
                break;
            case "initNotifications":

                String fcmToken = call.argument("fcmToken");
                Log.d("Zendesk","got fcmToken " + fcmToken);

                Zendesk.INSTANCE.provider().pushRegistrationProvider().registerWithDeviceIdentifier(fcmToken, new ZendeskCallback<String>() {
                    @Override
                    public void onSuccess(String result) {
                        Log.d("Zendesk","successful fcm registration result " + result);

                    }

                    @Override
                    public void onError(ErrorResponse errorResponse) {
                        Log.d("Zendesk","error fcm registration errorResponse reason:" + errorResponse.getReason() + " getResponseBody" + errorResponse.getResponseBody()+ " getStatus" + errorResponse.getStatus() );

                    }
                });
                result.success("Zendesk Notifications Initialized");
                break;
            case "openTicket":
                String ticketId = call.argument("ticketId");
                Log.d("Zendesk","got ticketId " + ticketId);

                new RequestConfiguration.Builder()
                        .withRequestId(ticketId)
                        .show(mRegistrar.activity());
                result.success("Zendesk open ticket init");
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

