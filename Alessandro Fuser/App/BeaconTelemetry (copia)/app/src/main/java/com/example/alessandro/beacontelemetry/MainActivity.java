package com.example.alessandro.beacontelemetry;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.content.Context;
import android.support.v4.content.FileProvider;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;

import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.estimote.coresdk.common.config.EstimoteSDK;
import com.estimote.coresdk.common.requirements.SystemRequirementsChecker;
import com.estimote.coresdk.recognition.packets.EstimoteTelemetry;
import com.estimote.coresdk.repackaged.okhttp_v2_2_0.com.squareup.okhttp.internal.Util;
import com.estimote.coresdk.service.BeaconManager;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;

public class MainActivity extends AppCompatActivity implements View.OnClickListener {

    private BeaconManager beaconManager;
    private TextView accx, accy, accz, timestamp;
    private Button start, stop, record;
    private EditText scanner;
    private boolean mIsRecording = false;
    private LinkedList<Measurement> mRecording;
    SimpleDateFormat formatter = new SimpleDateFormat("HH:mm:ss:SSS", Locale.getDefault());
    int timeForegroundScanner;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        accx = (TextView) findViewById(R.id.tvXAxis);
        accy = (TextView) findViewById(R.id.tvYAxis);
        accz = (TextView) findViewById(R.id.tvZAxis);
        timestamp = (TextView) findViewById(R.id.tvTimestamp);
        start = (Button) findViewById(R.id.bStart);
        stop = (Button) findViewById(R.id.bStop);
        record = (Button) findViewById(R.id.bExport);
        scanner = (EditText) findViewById(R.id.ForegroundScanner);

        start.setOnClickListener(this);
        stop.setOnClickListener(this);
        record.setOnClickListener(this);

        beaconManager = new BeaconManager(this);

        scanner.setText(String.valueOf(800));
        timeForegroundScanner = Integer.valueOf(scanner.getText().toString());

        /*
        beaconManager.setForegroundScanPeriod(509,0);
        beaconManager.setTelemetryListener(new BeaconManager.TelemetryListener() {
            @Override
            public void onTelemetriesFound(List<EstimoteTelemetry> telemetries) {
                if (telemetries.isEmpty()){
                    Log.d("TEL", "No Found");
                }else for (EstimoteTelemetry tlm : telemetries) {
                    Log.d("TELEMETRY", "beaconID: " + tlm.deviceId + ", Accelerometer: [" + tlm.accelerometer.x + " ," + tlm.accelerometer.y + " ," + tlm.accelerometer.z + "]");
                    accx.setText(String.valueOf(tlm.accelerometer.x));
                    accy.setText(String.valueOf(tlm.accelerometer.y));
                    accz.setText(String.valueOf(tlm.accelerometer.z));
                }
            }
        });
        */
    }

    @Override
    protected void onResume() {
        super.onResume();
        start.setEnabled(true);
        stop.setEnabled(false);
        record.setEnabled(false);

        SystemRequirementsChecker.checkWithDefaultDialogs(this);
    }

    @Override protected void onStart() {
        super.onStart();
        start.setEnabled(true);
        stop.setEnabled(false);
        /*
        beaconManager.connect(new BeaconManager.ServiceReadyCallback() {
            @Override
            public void onServiceReady() {
                beaconManager.startTelemetryDiscovery();
                EstimoteSDK.initialize(getApplicationContext(), "alessandro-fuser-studenti--m20", "faf0b6d678375e0e53f9fae9996542cc");
            }
        });
        */
    }

    @Override protected void onStop() {
        super.onStop();
        this.beaconManager.stopTelemetryDiscovery();
    }

    @Override
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.bStart:
                startRecording();
                break;
            case R.id.bStop:
                stopRecording();
                break;

            case R.id.bExport:
                try {
                    // crea e scrive il file in una cache
                    File outputFile = new File(this.getCacheDir(), "recording.csv");
                    OutputStreamWriter writer = new OutputStreamWriter(new FileOutputStream(outputFile));
                    writer.write(com.example.alessandro.beacontelemetry.Util.recordingToCSV(mRecording));
                    writer.close();

                    // get Uri from FileProvider
                    Uri contentUri = FileProvider.getUriForFile(this, "com.example.alessandro.beacontelemetry", outputFile);

                    // create sharing intent
                    Intent shareIntent = new Intent();
                    shareIntent.setAction(Intent.ACTION_SEND);
                    // temp permission for receiving app to read this file
                    shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                    shareIntent.setType("text/csv");
                    shareIntent.putExtra(Intent.EXTRA_STREAM, contentUri);
                    startActivity(Intent.createChooser(shareIntent, "Choose an app"));
                } catch (IOException e) {
                    Toast.makeText(this, R.string.error_file, Toast.LENGTH_SHORT).show();
                }
                break;

        }
    }

    public void startRecording(){
        start.setEnabled(false);
        stop.setEnabled(true);
        record.setEnabled(false);
        mIsRecording = true;
        mRecording = new LinkedList<>();
        timeForegroundScanner = Integer.valueOf(scanner.getText().toString());
        beaconManager.connect(new BeaconManager.ServiceReadyCallback() {
            @Override
            public void onServiceReady() {
                beaconManager.startTelemetryDiscovery();
                EstimoteSDK.initialize(getApplicationContext(), "alessandro-fuser-studenti--m20", "faf0b6d678375e0e53f9fae9996542cc");
            }
        });
        beaconManager.setForegroundScanPeriod(timeForegroundScanner,0);
        beaconManager.setTelemetryListener(new BeaconManager.TelemetryListener() {
            @Override
            public void onTelemetriesFound(List<EstimoteTelemetry> telemetries) {
                if (telemetries.isEmpty()){
                    Log.d("TEL", "No Found");
                }else for (EstimoteTelemetry tlm : telemetries) {
                    Log.d("TELEMETRY", "beaconID: " + tlm.getUniqueKey() + ", Accelerometer: [" + tlm.accelerometer.x + " ," + tlm.accelerometer.y + " ," + tlm.accelerometer.z + " , " + formatter.format(Calendar.getInstance().getTime()) +  "]");
                    accx.setText(String.valueOf(tlm.accelerometer.x));
                    accy.setText(String.valueOf(tlm.accelerometer.y));
                    accz.setText(String.valueOf(tlm.accelerometer.z));
                    timestamp.setText(String.valueOf(formatter.format(Calendar.getInstance().getTime())));
                    if (mIsRecording) {
                        Measurement measurement = new Measurement(tlm.accelerometer.x, tlm.accelerometer.y, tlm.accelerometer.z, formatter.format(Calendar.getInstance().getTime()));
                        mRecording.add(measurement);
                    }
                }
            }
        });
    }

    public void stopRecording(){
        stop.setEnabled(false);
        start.setEnabled(true);
        record.setEnabled(true);
        mIsRecording = false;
        this.beaconManager.stopTelemetryDiscovery();
    }
}
