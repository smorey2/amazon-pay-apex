@isTest
public class BigIntegerTest {
    //#region jsbnLib.ds

    @isTest
    public static void constr() {
        BigInteger a;
        a = new BigInteger(); System.assert(a != null, 'constr');
        a = new BigInteger(123, 256, new SecureRandom()); System.assertEquals(66051, a.z[0], 'constr 123, 256, SecureRandom');
        a = new BigInteger(123, new SecureRandom()); System.assertEquals(66051, a.z[0], 'constr 123, SecureRandom');
        // a = new BigInteger('123'); System.assertEquals(291, a.z[0], 'constr 123');
        a = new BigInteger('123', 16); System.assertEquals(291, a.z[0], 'constr 123, 16');
    }

    @isTest
    public static void i_nbi() {
        System.assert(BigInteger.nbi() != null, 'nbi invalid');
    }

    @isTest
    public static void i_nbv() {
        System.assertEquals(0, BigInteger.nbv(0).z[0], 'nbv 0');
        System.assertEquals(1, BigInteger.nbv(1).z[0], 'nbv 1');
        System.assertEquals(0, BigInteger.nbv(-1).z[0], 'nbv -1');
        System.assertEquals(0, BigInteger.nbv(-5).z[0], 'nbv -5');
    }

    @isTest
    public static void i_int2char() {
        System.assertEquals('0'.charAt(0), BigInteger.int2char(0), 'int2char 0');
        System.assertEquals('a'.charAt(0), BigInteger.int2char(10), 'int2char 10');
        System.assertEquals('z'.charAt(0), BigInteger.int2char(35), 'int2char 35');
    }

    @isTest
    public static void i_intAt() {
        System.assertEquals(0, BigInteger.intAt('0', 1), 'intAt 0');
        System.assertEquals(35, BigInteger.intAt('a', 1), 'intAt a');
        System.assertEquals(10, BigInteger.intAt('A', 1), 'intAt A');
        System.assertEquals(10, BigInteger.intAt('-', 1), 'intAt -');
    }

    @isTest
    public static void fromString() {
        BigInteger a;
        a = new BigInteger(); a.fromString('123', 16); System.assertEquals(291, a.z[0], 'fromString 16');
        a = new BigInteger(); a.fromString('123', 8); System.assertEquals(83, a.z[0], 'fromString 8');
        a = new BigInteger(); a.fromString('123', 256); System.assertEquals(66051, a.z[0], 'fromString 256');
        a = new BigInteger(); a.fromString('123', 2); System.assertEquals(7, a.z[0], 'fromString 2');
        a = new BigInteger(); a.fromString('123', 32); System.assertEquals(1091, a.z[0], 'fromString 32');
        a = new BigInteger(); a.fromString('123', 4); System.assertEquals(27, a.z[0], 'fromString 4');
        // a = new BigInteger(); a.fromString('123', 10); System.assertEquals(123, a.z[0], 'fromString 10');
    }

    @isTest
    public static void fromInt() {
        BigInteger a;
        a = new BigInteger(); a.fromInt(123); System.assertEquals(123, a.z[0], 'fromInt 123');
        a = new BigInteger(); a.fromInt(0); System.assertEquals(0, a.z[0], 'fromInt 0');
    }

    @isTest
    public static void clamp() {
        BigInteger a;
        a = new BigInteger('123', 16); a.clamp(); System.assertEquals(291, a.z[0], 'clamp');
    }

    //#endregion
}