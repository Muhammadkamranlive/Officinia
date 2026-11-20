package io.identy.identy_finger;

import android.app.Activity;
import android.util.Base64;
import android.util.Pair;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.identy.Attempt;
import com.identy.FingerAS;
import com.identy.GuideNoGuideHelper;
import com.identy.IdentyError;
import com.identy.IdentyQualityCheck;
import com.identy.IdentyResponse;
import com.identy.IdentyResponseListener;
import com.identy.IdentySdk;
import com.identy.InitializationListener;
import com.identy.WSQCompression;
import com.identy.enums.Finger;
import com.identy.enums.FingerDetectionMode;
import com.identy.enums.Hand;
import com.identy.enums.Template;
import com.identy.exceptions.NoDetectionModeException;
import com.identy.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;

/** IdentyFingerPlugin */
public class IdentyFingerPlugin extends Activity implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private FingerDetectionMode[] detectionModes;

  private Activity activity;

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    this.activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {

  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "identy_finger");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      if (call.method.equals("capture")) {
        detectionModes = new FingerDetectionMode[]{FingerDetectionMode.L4F};

        try{
          final HashMap<Template, HashMap<Finger, ArrayList<TemplateSize>>> templatesConfig = new HashMap<>();
          HashMap<Finger,ArrayList<TemplateSize>> sizes = new HashMap<>();

          ArrayList<TemplateSize> sises = new ArrayList<>();
          sises.add(TemplateSize.DEFAULT_MINUS_15);
          sises.add(TemplateSize.DEFAULT_PLUS_15);
          sises.add(TemplateSize.DEFAULT);

          sizes.put(Finger.INDEX,sises);

          sizes.put(Finger.MIDDLE,sises);

          sizes.put(Finger.RING,sises);
          sizes.put(Finger.LITTLE,sises);

          templatesConfig.put(Template.WSQ, sizes);

          IdentySdk.newInstance(activity, "2547-com.autosoft.digitalonboarding-29-09-2023.lic", new InitializationListener<IdentySdk>() {
            @Override
            public void onInit(IdentySdk d) {

              try{

                d.setBase64EncodingFlag(Base64.DEFAULT);
                d.setDisplayImages(true);
                d.setAS(true);
                d.setRequiredTemplates(templatesConfig);
                d.setDisplayBoxes(true);
                d.setWSQCompression(WSQCompression.WSQ_10_1);
                d.setDetectionMode(detectionModes);
                d.setDebug(true);
                d.setQC(new IdentyQualityCheck() {
                  @Override
                  public boolean decide(HashMap<Pair<Hand, Finger>, Integer> scores) {
                    return true;
                  }
                });

                d.capture();

              } catch (Exception e) {
                e.printStackTrace();
              }


            }
          }, new IdentyResponseListener() {
            @Override
            public void onAttempt(Hand hand, int i, Map<Finger, Attempt> map) {

            }

            @Override
            public void onResponse(IdentyResponse identyResponse, HashSet<String> hashSet) {
              String respuesta = identyResponse.toJson(activity).toString();
              result.success("Respuesta: " + respuesta);
            }

            @Override
            public void onErrorResponse(IdentyError identyError, HashSet<String> hashSet) {
              String error =  identyError.getMessage();
              result.error("403", error, error);
            }
          }, "AIzaSyDXGkfIpxx3svm7ZAM5H9OFOvCNZxDMegw", true);


        } catch (Exception e) {
          e.printStackTrace();
        }


      } else {
        result.notImplemented();
      }
    }

  }

}

