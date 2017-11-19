package com.example.alessandro.beacontelemetry;

/**
 * Created by alessandro on 02/10/17.
 */
import java.util.List;

/**
 * Classi con funzioni di aiuto.
 */
public class Util {

    /**
     * ritorna un file CSV che rappresenta le misurazioni osservate.
     * quindi la lista delle{@link Measurement} .
     *
     * @param recording la lista delle misurazioni
     * @return la CSV delle misurazioni prese.
     */
    public static String recordingToCSV(List<Measurement> recording) {
        String csv = "tempo,x,y,z,combinate\n";
        for (Measurement measurement : recording) {
            csv += measurement.getTime() + "," + measurement.getX()
                    + "," + measurement.getY() + "," + measurement.getZ()
                    + "," + measurement.getCombined() + "\n";
        }
        return csv;
    }
}
