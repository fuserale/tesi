package com.example.alessandro.beacontelemetry;

/**
 * Created by alessandro on 02/10/17.
 */
/**
 * rappresenta una misura della accelerazione di  x, y , z .
 */
public class Measurement {

    private double x, y, z;
    private String time;

    /**
     * Costruzione di una misura base di x,y,z.
     *
     * @param x    the x axis acceleration
     * @param y    the y axis acceleration
     * @param z    the z axis acceleration
     * @param time the time the measurement was taken
     */
    public Measurement(double x, double y, double z, String time) {
        this.x = x;
        this.y = y;
        this.z = z;
        this.time = time;
    }

    /**
     * ritorna la combinazione dell'accelerazione sqrt(x^2 + y^2 + z^2).
     *
     * @return l'accelerazione dei 3 assi combinati
     */
    public double getCombined() {
        return Math.sqrt(x * x + y * y + z * z);
    }

    public double getX() {
        return x;
    }

    public double getY() {
        return y;
    }

    public double getZ() {
        return z;
    }

    public String getTime() {
        return time;
    }
}