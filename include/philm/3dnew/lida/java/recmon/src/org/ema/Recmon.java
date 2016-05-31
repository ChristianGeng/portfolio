/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.ema;

import java.io.DataInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

/**
 *
 * @author lasse
 */
public class Recmon {
//cnt gives sample count, and uses 1 bit to indicate trial active
//dummy contains trial (sweep) number
    int cnt = 0;
    int dummy = 0;
    float[][] dataS;
    float[][] dataC;
    int[] extra = new int[10];
    float[][] pos;
    boolean active = false;
    private int bufSize, numTrans, numChans;

    public Recmon() {
        setup("AG500");
    }

    public Recmon(String agType) {
        if (agType.equals("AG500") || agType.equals("AG501")) {
            setup(agType);
        } else {
            throw new IllegalArgumentException("Unknown EMA device" + agType);
        }
    }

    private void setup(String agType) {
//the formular for buffer size is
    //4+4+((nchans*ntrans*4)*2)+(10*4)+(nchans*7*4)    
    //cnt, dummy, dataS, dataC, extra, pos
        if (agType.equals("AG500")) {
            //AG500 has 6 transceivers
            numChans = 12;
            numTrans = 6;
            bufSize = 960;
        } else if (agType.equals("AG501")) {
//Phil. 13.10.2012            
//AG501 has 9 transmitters. Assume standard configuration is 16 sensor channels
            //May need additional options in future
            numChans = 16;
            numTrans = 9;
            bufSize = 1648;
            //AG501 has 9 transmitters. Preliminary version with 12 sensor channels up to summer 2012
            /*            numChans = 12;
            numTrans = 9;
            bufSize = 1248;
             */
        } else {
            throw new IllegalArgumentException("Unknown EMA device" + agType);
        }
        dataS = new float[numChans][numTrans];
        dataC = new float[numChans][numTrans];
        pos = new float[numChans][7];
    }

    public int read(InputStream inp) throws IOException {
        int position = 0;
        ByteBuffer bb = ByteBuffer.allocate(bufSize);
        byte[] bytes = new byte[bufSize];
        inp.read(bytes);
        long result = inp.skip(inp.available());
        bb.put(bytes);
        bb.order(ByteOrder.LITTLE_ENDIAN);
        cnt = bb.getInt(position);
        active = (cnt & 0x80000000) != 0;
        cnt = cnt & 0x7fffffff;
        position += 4;
        dummy = bb.getInt(4);
        position += 4;
        for (int m = 0; m < numChans; m++) {
            for (int n = 0; n < numTrans; n++) {
                dataS[m][n] = bb.getFloat(position);
                position += 4;
            }
        }
        for (int m = 0; m < numChans; m++) {
            for (int n = 0; n < numTrans; n++) {
                dataC[m][n] = bb.getFloat(position);
                position += 4;
            }
        }
        for (int m = 0; m < 10; m++) {
            extra[m] = bb.getInt(position);
            position += 4;
        }
        for (int m = 0; m < numChans; m++) {
            for (int n = 0; n < 7; n++) {
                pos[m][n] = bb.getFloat(position);
                position += 4;
            }
        }
        return (int) result;
    }

    public int getSample() {
        return this.cnt;
    }

    public int getSweep() {
        return this.dummy;
    }

    public float[][] getDataS() {
        return this.dataS;
    }

    public float[][] getDataC() {
        return this.dataC;
    }

    public float[][] getPos() {
        return this.pos;
    }

    public int[] getExtra() {
        return this.extra;
    }

    public boolean getActive() {
        return this.active;
    }
}
