
package com.accenture.ali.faceverify;

import android.util.Log;

import com.aliyun.aliyunface.api.ZIMCallback;
import com.aliyun.aliyunface.api.ZIMFacade;
import com.aliyun.aliyunface.api.ZIMFacadeBuilder;
import com.aliyun.aliyunface.api.ZIMResponse;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import okhttp3.Call;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class RNAliFaceVerifyModule extends ReactContextBaseJavaModule {

    private static final String TAG = RNAliFaceVerifyModule.class.getSimpleName();

    private final ReactApplicationContext reactContext;

    public RNAliFaceVerifyModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        ZIMFacade.install(reactContext.getBaseContext());
    }

    @Override
    public String getName() {
        return "RNAliFaceVerify";
    }

    /**
     * 获取 认证url and id
     *
     * @param certName
     * @param certNo
     * @param successCallback 返回code, message, certifyId
     * @param errorCallback， 返回code, message
     */
    @ReactMethod
    public void getZimFace(String certName, String certNo, final Callback successCallback, final Callback errorCallback) {

        String url = "https://kumili.net/apiV2/FaceInit";
        MediaType MediaTypeJSON = MediaType.parse("application/json; charset=utf-8");

        Map<String, String> map = new HashMap<>();
        map.put("certName", certName);
        map.put("certNo", certNo);
        String json = JSON.toJSONString(map);
        RequestBody requestBody = RequestBody.create(MediaTypeJSON, json);

        final Request request = new Request.Builder()
                .url(url)
                .post(requestBody)
                .build();

        new Thread(new Runnable() {
            @Override
            public void run() {
                new OkHttpClient().newCall(request).enqueue(new okhttp3.Callback() {
                    @Override
                    public void onFailure(Call call, IOException e) {
                        Log.e(TAG, "onFailure");
                        errorCallback.invoke("10001", e.getMessage());
                    }

                    @Override
                    public void onResponse(Call call, Response response) throws IOException {
                        if (response.isSuccessful()) {
                            String responseString = response.body().string();
                            Log.e(TAG, responseString);
                            successCallback.invoke("10000", "", "11111");
                        } else {
                            Log.e(TAG, "onResponse error" + response.body().string());
                            errorCallback.invoke("10002", "服务返回失败");
                        }
                    }
                });
            }
        }).start();
    }

    /**
     * identify interface for android
     *
     * @param certifyUrl 服务端返回认证链接
     * @param certifyId  刷脸认证唯一标识，请从刷脸认证服务端认证初始化接口获取
     * @param callback   认证结果的回调接口
     */
    @ReactMethod
    public void verify(String certifyUrl, String certifyId, final Callback callback) {
        // 封装认证数据
        JSONObject requestInfo = new JSONObject();
        requestInfo.put("url", certifyUrl);
        requestInfo.put("certifyId", certifyId);
        ZIMFacade zimFacade = ZIMFacadeBuilder.create(this.reactContext.getBaseContext());
        zimFacade.verify(certifyId, true, new ZIMCallback() {
            @Override
            public boolean response(ZIMResponse response) {

                if (null != response && 1000 == response.code) {
                    Log.e(TAG, "认证成功");
                } else {
                    Log.e(TAG, "认证失败");
                }

                return true;
            }
        });
    }
}