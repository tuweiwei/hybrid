package cn.sunday.hybridappdemo;

import android.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;

import com.tencent.smtt.sdk.ValueCallback;

import cn.sunday.hybridappdemo.constants.Constants;
import cn.sunday.hybridappdemo.views.X5WebView;


public class MainActivity extends AppCompatActivity {

    private X5WebView mWebView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        init();
    }

    /**
     * 初始化 webview
     */
    private void init () {
        mWebView = findViewById(R.id.web_view);
        mWebView.loadUrl(Constants.WEB_URL);
    }


    /**
     * 原生端调用 web 方法，方法必须是挂载到 web 端 window 对象下面的方法。
     * 调用 JS 中的方法：onFunction1
     */
    public void onJSFunction1 (View v) {
        mWebView.evaluateJavascript("javascript:onFunction('android调用JS方法')", new ValueCallback<String>() {
            @Override
            public void onReceiveValue(String s) {
                AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);
                builder.setMessage(s);
                builder.setNegativeButton("确定", null);
                builder.create().show();
            }
        });
    }
}
