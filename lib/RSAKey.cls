public class RSAKey {
//#region rsaLib.ds

  // convert a (hex) string to a bignum object
  static BigInteger parseBigInt(String str, Integer r) {
    return new BigInteger(str, r);
  }

  static String linebrk(String s, Integer n) {
    String ret = '';
    Integer i = 0;
    while (i + n < s.length) {
      ret += s.substring(i, i + n) + '\n';
      i += n;
    }
    return ret + s.substring(i, s.length);
  }

  static String byte2Hex(Integer b) {
    if (b < 16)
      return '0' + b.toString(16);
    else
      return b.toString(16);
  }

  // PKCS#1 (type 2, random) pad input string s to n bytes, and return a bigint
  static BigInteger pkcs1pad2(String s, Integer n) {
    if (n < s.length + 11) {
      throw new IllegalArgumentException('Message too long for RSA'); 
      return null;
    }
    Integer[] ba = new Integer[0];
    Integer i = s.length - 1;
    while (i >= 0 && n > 0) {
      Integer c = s.codePointAt(i--);
      if (c < 128) { // encode using utf-8
        ba[--n] = c;
      }
      else if ((c > 127) && (c < 2048)) {
        ba[--n] = (c & 63) | 128;
        ba[--n] = (c >> 6) | 192;
      }
      else {
        ba[--n] = (c & 63) | 128;
        ba[--n] = ((c >> 6) & 63) | 128;
        ba[--n] = (c >> 12) | 224;
      }
    }
    ba[--n] = 0;
    SecureRandom rng = new SecureRandom();
    Integer[] x = new Integer[0];
    while (n > 2) { // random non-zero pad
      x[0] = 0;
      while (x[0] == 0) rng.nextBytes(x);
      ba[--n] = x[0];
    }
    ba[--n] = 2;
    ba[--n] = 0;
    return new BigInteger(ba);
  }

  // PKCS#1 (OAEP) mask generation function
  static String oaep_mgf1_arr(Integer seed, Integer len, Integer hash) {
    String mask = ''; Long i = 0;

    while (mask.length < len) {
        mask += hash(String.fromCharCode.apply(String, seed.concat([
                (i & 4278190080L) >> 24,
                (i & 16711680) >> 16,
                (i & 65280) >> 8,
                i & 255])));
        i += 1;
    }

    return mask;
  }

  static Integer SHA1_SIZE = 20;

  // PKCS#1 (OAEP) pad input string s to n bytes, and return a bigint
  static BigInteger oaep_pad(String s, Integer n, Integer hash) {
      if (s.length + 2 * SHA1_SIZE + 2 > n) {
        throw new IllegalArgumentException('Message too long for RSA'); 
      }

      String PS = ''; Integer i;
      for (i = 0; i < n - s.length - 2 * SHA1_SIZE - 2; i += 1) {
          PS += '\x00';
      }

      String DB = rstr_sha1('') + PS + '\x01' + s;
      Integer[] seed = new Integer[SHA1_SIZE];
      new SecureRandom().nextBytes(seed);
      
      String dbMask = oaep_mgf1_arr(seed, DB.length, hash || rstr_sha1);
      Integer[] maskedDB = new Integer[0];

      for (i = 0; i < DB.length; i += 1) {
          maskedDB[i] = DB.codePointAt(i) ^ dbMask.codePointAt(i);
      }

      String seedMask = oaep_mgf1_arr(maskedDB, seed.length, rstr_sha1);
      Integer[] maskedSeed = new Integer[1] { 0 };

      for (i = 0; i < seed.length; i += 1) {
          maskedSeed[i + 1] = seed[i] ^ seedMask.codePointAt(i);
      }

      return new BigInteger(maskedSeed.concat(maskedDB));
  }

  public String type = 'RSA';
  BigInteger n;
  Integer e;
  BigInteger d;
  BigInteger p;
  BigInteger q;
  BigInteger dmp1;
  BigInteger dmq1;
  BigInteger coeff;
  Boolean isPublic;

  // 'empty' RSA key constructor
  public RSAKey() {
    this.n = null;
    this.e = 0;
    this.d = null;
    this.p = null;
    this.q = null;
    this.dmp1 = null;
    this.dmq1 = null;
    this.coeff = null;
  }

  // Set the public key fields N and e from hex strings
  public void setPublic(BigInteger N, Integer E) {
      this.isPublic = true;
      this.n = N;
      this.e = E;
  }
  public void setPublic(String N, String E) {
    this.isPublic = true;
    if (N != null && E != null && N.length > 0 && E.length > 0) {
      this.n = parseBigInt(N, 16);
      this.e = parseInt(E, 16);
    }
    else throw new IllegalArgumentException('Invalid RSA public key'); 
  }

  // Perform raw public operation on 'x': return x^e (mod n)
  private BigInteger doPublic(BigInteger x) {
    return x.modPowInt(this.e, this.n);
  }

  // Return the PKCS#1 RSA encryption of 'text' as an even-length hex string
  public String encrypt(String text) {
    BigInteger m = pkcs1pad2(text, (this.n.bitLength() + 7) >> 3);
    if (m == null) return null;
    String c = this.doPublic(m);
    if (c == null) return null;
    String h = c.toString(16);
    if ((h.length & 1) == 0) return h; else return '0' + h;
  }

  // Return the PKCS#1 OAEP RSA encryption of 'text' as an even-length hex string
  public String encryptOAEP(String text, Integer hash) {
    BigInteger m = oaep_pad(text, (this.n.bitLength() + 7) >> 3, hash);
    if (m == null) return null;
    String c = this.doPublic(m);
    if (c == null) return null;
    String h = c.toString(16);
    if ((h.length & 1) == 0) return h; else return '0' + h;
  }

  // Return the PKCS#1 RSA encryption of 'text' as a Base64-encoded string
  // public String encrypt_b64(String text) {
  //   String h = this.encrypt(text);
  //   if (h != null) return hex2b64(h); else return null;
  // }
}