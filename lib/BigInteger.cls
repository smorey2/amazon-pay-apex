public class BigInteger {

  // Basic JavaScript BN library - subset useful for RSA encryption.
  //#region jsbnLib.ds

  // Bits per digit
  static Integer dbits;

  // JavaScript engine analysis
  static final Long canary = 244837814094590L;
  static final Boolean j_lm = (canary & 16777215) == 15715070;

  // constants
  public static final BigInteger ZERO = nbv(0);
  public static final BigInteger ONE = nbv(1);

  // fields
  Integer s;
  Integer t;
  Integer DB;
  Integer DV;
  Integer DM;
  public Integer[] z = new List<Integer>(); void z_grow(Integer size) { while (z.size() < size) z.add(0); }

  // (public) Constructor
  public BigInteger() { }
  public BigInteger(Integer a, Integer b, SecureRandom c) { this.fromNumber(a, b, c); }
  public BigInteger(Integer a, SecureRandom b) { this.fromNumber(a, b); }
  public BigInteger(String a) { this.fromString(a, 256); }
  public BigInteger(String a, Integer b) { this.fromString(a, b); }
        
  // return new, unset BigInteger
  @testVisible static BigInteger nbi() { return new BigInteger(); }

  // return bigint initialized to value
  @testVisible static BigInteger nbv(Integer i) { BigInteger r = nbi(); r.fromInt(i); return r; }
  
  // Digit conversions
  static String BI_RM = '0123456789abcdefghijklmnopqrstuvwxyz';
  static Map<Integer, Integer> BI_RC = new Map<Integer, Integer>();
  static {
    Integer rr, vv;
    rr = '0'.charAt(0);
    for (vv = 0; vv <= 9; ++vv) BI_RC.put(rr++, vv);
    rr = 'a'.charAt(0);
    for (vv = 10; vv < 36; ++vv) BI_RC.put(rr++, vv);
    rr = 'A'.charAt(0);
    for (vv = 10; vv < 36; ++vv) BI_RC.put(rr++, vv);
  }

  @testVisible static Integer int2char(Integer n) { return BI_RM.charAt(n); }
  @testVisible static Integer intAt(String s, Integer i) { Integer c = BI_RC.get(s.codePointAt(i)); return c == null ? -1 : c; }

  // (protected) set from string and radix
  @testVisible private void fromString(String s, Integer b) {
    Integer k;
    if (b == 16) k = 4;
    else if (b == 8) k = 3;
    else if (b == 256) k = 8; // byte array
    else if (b == 2) k = 1;
    else if (b == 32) k = 5;
    else if (b == 4) k = 2;
    else { this.fromRadix(s, b); return; }
    this.t = 0;
    this.s = 0;
    Integer i = s.length(), sh = 0; Boolean mi = false;
    while (--i >= 0) {
      Integer x = (k == 8 ? s.charAt(i) & 255 : intAt(s, i));
      if (x < 0) {
        if (s.charAt(i) == '-'.charAt(0)) mi = true;
        continue;
      }
      z_grow(this.t + 2);
      mi = false;
      if (sh == 0) this.z[this.t++] = x;
      else if (sh + k > this.DB) {
        this.z[this.t - 1] |= (x & ((1 << (this.DB - sh)) - 1)) << sh;
        this.z[this.t++] = (x >> (this.DB - sh));
      }
      else this.z[this.t - 1] |= x << sh;
      sh += k;
      if (sh >= this.DB) sh -= this.DB;
    }
    if (k == 8 && (s.charAt(0) & 128) != 0) {
      this.s = -1;
      if (sh > 0) this.z[this.t - 1] |= ((1 << (this.DB - sh)) - 1) << sh;
    }
    this.clamp();
    if (mi) ZERO.subTo(this, this);
  }

  // (protected) set from integer value x, -DV <= x < DV
  @testVisible private void fromInt(Integer x) {
    this.t = 1;
    this.s = x < 0 ? -1 : 0;
    z_grow(1);
    if (x > 0) this.z[0] = x;
    else if (x < -1) this.z[0] = x + this.DV;
    else this.t = 0;
  }

  // (protected) clamp off excess high words
  @testVisible private void clamp() {
    Integer c = this.s & this.DM;
    while (this.t > 0 && this.z[this.t - 1] == c) --this.t;
  }

  //#endregion

  // Extended JavaScript BN functions, required for RSA protected ops.
  //#region jsbin2Lib.ds

  // (public)
  public BigInteger zclone() { BigInteger r = nbi(); this.copyTo(r); return r; }

  // (public) return value as integer
  public Integer intValue() {
    if (this.s < 0) {   
      if (this.t == 1) return this.z[0] - this.DV;
      else if (this.t == 0) return -1;
    }
    else if (this.t == 1) return this.z[0];
    else if (this.t == 0) return 0;
    // assumes 16 < DB < 32
    return ((this.z[1] & ((1 << (32 - this.DB))-1)) << this.DB) | this.z[0];
  }

  // (public) return value as byte
  public Integer byteValue() { return this.t == 0 ? this.s : (this.z[0] << 24) >> 24; }

  // (public) return value as short (assumes DB>=16)
  public Integer shortValue() { return this.t == 0 ? this.s : (this.z[0] << 16) >> 16; }

  // (protected) return x s.t. r^x < DV
  private Integer chunkSize(Integer r) { return (Integer)Math.floor(Math_LN2 * this.DB / Math.log(r)); }

  // (public) 0 if this == 0, 1 if this > 0
  public Integer signum() {
    if (this.s < 0) return -1;
    else if (this.t <= 0 || (this.t == 1 && this.z[0] <= 0)) return 0;
    else return 1;
  }

  // (protected) convert to radix string
  private String toRadix(Integer b) {
    if (b == null) b = 10;
    if (this.signum() == 0 || b < 2 || b > 36) return '0';
    Integer cs = this.chunkSize(b);
    Integer a = (Integer)Math.pow(b, cs);
    BigInteger d = nbv(a), y = nbi(), z = nbi(); String r = '';
    this.divRemTo(d, y, z);
    while (y.signum() > 0) {
      r = String_valueOf(a + z.intValue(), b).substring(1) + r;
      y.divRemTo(d, y, z);
    }
    return String.valueof(z.intValue()) + r;
  }

  // (protected) convert from radix string
  private void fromRadix(String s, Integer b) {
    this.fromInt(0);
    if (b == null) b = 10;
    Integer cs = this.chunkSize(b);
    Integer d = (Integer)Math.pow(b, cs), j = 0, w = 0; Boolean mi = false;
    for (Integer i = 0; i < s.length(); ++i) {
      Integer x = intAt(s, i);
      if (x < 0) {
        if (s.charAt(i) == '-'.charAt(0) && this.signum() == 0) mi = true;
        continue;
      }
      w = b * w + x;
      if (++j >= cs) {
        this.dMultiply(d);
        this.dAddOffset(w, 0);
        j = 0;
        w = 0;
      }
    }
    if (j > 0) {
      this.dMultiply((Integer)Math.pow(b, j));
      this.dAddOffset(w, 0);
    }
    if (mi) BigInteger.ZERO.subTo(this, this);
  }

  // (protected) alternate constructor
  private void fromNumber(Integer a, Integer b, SecureRandom c) {
      // new BigInteger(int,int,RNG)
      if (a < 2) this.fromInt(1);
      else {
        this.fromNumber(a, c);
        if (!this.testBit(a - 1))	this.bitwiseTo(BigInteger.ONE.shiftLeft(a - 1), OP.OP_OR, this); // force MSB set
        if (this.isEven()) this.dAddOffset(1, 0); // force odd
        while (!this.isProbablePrime(b)) {
          this.dAddOffset(2, 0);
          if (this.bitLength() > a) this.subTo(BigInteger.ONE.shiftLeft(a - 1), this);
        }
      }
  }
  private void fromNumber(Integer a, SecureRandom b) {
      // new BigInteger(int,RNG)
      Integer[] x = new Integer[(a >> 3) + 1]; Integer t = a & 7;
      b.nextBytes(x);
      if (t > 0) x[0] &= ((1 << t) - 1); else x[0] = 0;
      this.fromString(String.fromCharArray(x), 256);
  }

  // (public) convert to bigendian byte array
  public Integer[] toByteArray() {
    Integer i = this.t; Integer[] r = new Integer[0];
    r[0] = this.s;
    Integer p = this.DB - Math.mod(i * this.DB, 8), d, k = 0;
    if (i-- > 0) {
      if (p < this.DB && (d = this.z[i] >> p) != (this.s & this.DM) >> p) { k++; r.add(d | (this.s << (this.DB - p))); }
      while (i >= 0) {
        if (p < 8) {
          d = (this.z[i] & ((1 << p) - 1)) << (8 - p);
          d |= this.z[--i] >> (p += this.DB - 8);
        }
        else {
          d = (this.z[i] >> (p -= 8)) & 255;
          if (p <= 0) { p += this.DB; --i; }
        }
        if ((d & 128) != 0) d |= -256;
        if (k == 0 && (this.s & 128) != (d & 128)) { k++; r.add(null); }
        if (k > 0 || d != this.s) { k++; r.add(d); }
      }
    }
    return r;
  }

  public Boolean equals(BigInteger a) { return this.compareTo(a) == 0; }
  public BigInteger min(BigInteger a) { return this.compareTo(a) < 0 ? this : a; }
  public BigInteger max(BigInteger a) { return this.compareTo(a) > 0 ? this : a; }

  // (protected) r = this op a (bitwise)
  private void bitwiseTo(BigInteger a, Op op, BigInteger r) {
    Integer i, f, m = Math.min(a.t, this.t);
    for (i = 0; i < m; ++i) r.z[i] = op_execute(op, this.z[i], a.z[i]);
    if (a.t < this.t) {
      f = a.s & this.DM;
      for (i = m; i < this.t; ++i) r.z[i] = op_execute(op, this.z[i], f);
      r.t = this.t;
    }
    else {
      f = this.s & this.DM;
      for (i = m; i < a.t; ++i) r.z[i] = op_execute(op, f, a.z[i]);
      r.t = a.t;
    }
    r.s = op_execute(op, this.s, a.s);
    r.clamp();
  }

  enum OP { OP_AND, OP_OR, OP_XOR, OP_ANDNOT }

  static Integer op_execute(OP op, Integer x, Integer y) {
    switch on op {
      when OP_AND { return x & y; }
      when OP_OR { return x | y; }
      when OP_XOR { return x ^ y; }
      when OP_ANDNOT { return x & ~y; }
      when else {	throw new IllegalArgumentException('Invalid Operation'); }
    }
  }

  // (public) this & a
  public BigInteger andOp(BigInteger a) { BigInteger r = nbi(); this.bitwiseTo(a, OP.OP_AND, r); return r; }

  // (public) this | a
  public BigInteger orOp(BigInteger a) { BigInteger r = nbi(); this.bitwiseTo(a, OP.OP_OR, r); return r; }

  // (public) this ^ a
  public BigInteger xorOp(BigInteger a) { BigInteger r = nbi(); this.bitwiseTo(a, OP.OP_XOR, r); return r; }

  // (public) this & ~a
  public BigInteger andNotOp(BigInteger a) { BigInteger r = nbi(); this.bitwiseTo(a, OP.OP_ANDNOT, r); return r; }

  // (public) ~this
  public BigInteger notOp() {
    BigInteger r = nbi();
    for (Integer i = 0; i < this.t; ++i) r.z[i] = this.DM & ~this.z[i];
    r.t = this.t;
    r.s = ~this.s;
    return r;
  }

  // (public) this << n
  public BigInteger shiftLeft(Integer n) {
    BigInteger r = nbi();
    if (n < 0) this.rShiftTo(-n, r); else this.lShiftTo(n, r);
    return r;
  }

  // (public) this >> n
  public BigInteger shiftRight(Integer n) {
    BigInteger r = nbi();
    if (n < 0) this.lShiftTo(-n, r); else this.rShiftTo(n, r);
    return r;
  }

  // return index of lowest 1-bit in x, x < 2^31
  Integer lbit(Integer x) {
    if (x == 0) return -1;
    Integer r = 0;
    if ((x & 65535) == 0) { x >>= 16; r += 16; }
    if ((x & 255) == 0) { x >>= 8; r += 8; }
    if ((x & 15) == 0) { x >>= 4; r += 4; }
    if ((x & 3) == 0) { x >>= 2; r += 2; }
    if ((x & 1) == 0) ++r;
    return r;
  }

  // (public) returns index of lowest 1-bit (or -1 if none)
  public Integer getLowestSetBit() {
    for (Integer i = 0; i < this.t; ++i) if (this.z[i] != 0) return i * this.DB + lbit(this.z[i]);
    if (this.s < 0) return this.t * this.DB;
    return -1;
  }

  // return number of 1 bits in x
  Integer cbit(Integer x) {
    Integer r = 0;
    while (x != 0) { x &= x - 1; ++r; }
    return r;
  }

  // (public) return number of set bits
  public Integer bitCount() {
    Integer r = 0, x = this.s & this.DM;
    for (Integer i = 0; i < this.t; ++i) r += cbit(this.z[i] ^ x);
    return r;
  }

  // (public) true iff nth bit is set
  public Boolean testBit(Integer n) {
    Integer j = (Integer)Math.floor(n / this.DB);
    if (j >= this.t) return this.s != 0;
    return (this.z[j] & (1 << Math.mod(n, this.DB))) != 0;
  }

  // (protected) this op (1<<n)
  private BigInteger changeBit(Integer n, OP op) {
    BigInteger r = BigInteger.ONE.shiftLeft(n);
    this.bitwiseTo(r, op, r);
    return r;
  }

  // (public) this | (1<<n)
  public BigInteger setBit(Integer n) { return this.changeBit(n, OP.OP_OR); }

  // (public) this & ~(1<<n)
  public BigInteger clearBit(Integer n) { return this.changeBit(n, OP.OP_ANDNOT); }

  // (public) this ^ (1<<n)
  public BigInteger flipBit(Integer n) { return this.changeBit(n, OP.OP_XOR); }

  // (protected) r = this + a
  private void addTo(BigInteger a, BigInteger r) {
    Integer i = 0, c = 0, m = Math.min(a.t, this.t);
    while (i < m) {
      c += this.z[i] + a.z[i];
      r.z[i++] = c & this.DM;
      c >>= this.DB;
    }
    if (a.t < this.t) {
      c += a.s;
      while (i < this.t) {
        c += this.z[i];
        r.z[i++] = c & this.DM;
        c >>= this.DB;
      }
      c += this.s;
    }
    else {
      c += this.s;
      while (i < a.t) {
        c += a.z[i];
        r.z[i++] = c & this.DM;
        c >>= this.DB;
      }
      c += a.s;
    }
    r.s = c < 0 ? -1 : 0;
    if (c > 0) r.z[i++] = c;
    else if (c < -1) r.z[i++] = this.DV + c;
    r.t = i;
    r.clamp();
  }

  // (public) this + a
  public BigInteger add(BigInteger a) { BigInteger r = nbi(); this.addTo(a, r); return r; }

  // (public) this - a
  public BigInteger subtract(BigInteger a) { BigInteger r = nbi(); this.subTo(a, r); return r; }

  // (public) this * a
  public BigInteger multiply(BigInteger a) { BigInteger r = nbi(); this.multiplyTo(a, r); return r; }

  // (public) this^2
  public BigInteger square() { BigInteger r = nbi(); this.squareTo(r); return r; }

  // (public) this / a
  public BigInteger divide(BigInteger a) { BigInteger r = nbi(); this.divRemTo(a, r, null); return r; }

  // (public) this % a
  public BigInteger remainder(BigInteger a) { BigInteger r = nbi(); this.divRemTo(a, null, r); return r; }

  // (public) [this/a,this%a]
  public BigInteger[] divideAndRemainder(BigInteger a) {
    BigInteger q = nbi(), r = nbi();
    this.divRemTo(a, q, r);
    return new BigInteger[] { q, r };
  }

  // (protected) this *= n, this >= 0, 1 < n < DV
  private void dMultiply(Integer n) {
    this.z[this.t] = this.am(0, n - 1, this, 0, 0, this.t);
    ++this.t;
    this.clamp();
  }

  // (protected) this += n << w words, this >= 0
  private void dAddOffset(Integer n, Integer w) {
    if (n == 0) return;
    while (this.t <= w) this.z[this.t++] = 0;
    this.z[w] += n;
    while (this.z[w] >= this.DV) {
      this.z[w] -= this.DV;
      if (++w >= this.t) this.z[this.t++] = 0;
      ++this.z[w];
    }
  }

  public interface IExp {
    BigInteger convert(BigInteger x);
    BigInteger revert(BigInteger x);
    void mulTo(BigInteger x, BigInteger y, BigInteger r);
    void sqrTo(BigInteger x, BigInteger r);
  }

  // A 'null' reducer
  public class NullExp implements IExp {
    public BigInteger convert(BigInteger x) { return x; }
    public BigInteger revert(BigInteger x) { return x; }
    public void mulTo(BigInteger x, BigInteger y, BigInteger r) { x.multiplyTo(y, r); }
    public void sqrTo(BigInteger x, BigInteger r) { x.squareTo(r); }
  }

  public class Classic implements IExp {
    public Classic(BigInteger m) { }
    public BigInteger convert(BigInteger x) { throw new IllegalArgumentException('Not Implemented'); }
    public BigInteger revert(BigInteger x) { throw new IllegalArgumentException('Not Implemented'); }
    public void mulTo(BigInteger x, BigInteger y, BigInteger r) { throw new IllegalArgumentException('Not Implemented'); }
    public void sqrTo(BigInteger x, BigInteger r) { throw new IllegalArgumentException('Not Implemented'); }
  }

  public class Montgomery implements IExp {
    public Montgomery(BigInteger m) { }
    public BigInteger convert(BigInteger x) { throw new IllegalArgumentException('Not Implemented'); }
    public BigInteger revert(BigInteger x) { throw new IllegalArgumentException('Not Implemented'); }
    public void mulTo(BigInteger x, BigInteger y, BigInteger r) { throw new IllegalArgumentException('Not Implemented'); }
    public void sqrTo(BigInteger x, BigInteger r) { throw new IllegalArgumentException('Not Implemented'); }
  }

  // (public) this^e
  public BigInteger pow(Integer e) { return this.exp(e, new NullExp()); }

  // (protected) r = lower n words of 'this * a', a.t <= n
  // 'this' should be the larger one if appropriate.
  private void multiplyLowerTo(BigInteger a, Integer n, BigInteger r) {
    Integer i = Math.min(this.t + a.t, n);
    r.s = 0; // assumes a,this >= 0
    r.t = i;
    while (i > 0) r.z[--i] = 0;
    Integer j;
    for (j = r.t - this.t; i < j; ++i) r.z[i + this.t] = this.am(0, a.z[i], r, i, 0, this.t);
    for (j = Math.min(a.t, n); i < j; ++i) this.am(0, a.z[i], r, i, 0, n - i);
    r.clamp();
  }

  // (protected) r = 'this * a' without lower n words, n > 0
  // 'this' should be the larger one if appropriate.
  private void multiplyUpperTo(BigInteger a, Integer n, BigInteger r) {
    --n;
    Integer i = r.t = this.t + a.t - n;
    r.s = 0; // assumes a,this >= 0
    while (--i >= 0) r.z[i] = 0;
    for (i = Math.max(n - this.t, 0); i < a.t; ++i) r.z[this.t + i - n] = this.am(n - i, a.z[i], r, 0, 0, this.t + i - n);
    r.clamp();
    r.drShiftTo(1, r);
  }

  // Barrett modular reduction
  public class Barrett implements IExp {
    BigInteger r2, q3, mu, m;

    public Barrett(BigInteger m) {
      // setup Barrett
      this.r2 = nbi();
      this.q3 = nbi();
      BigInteger.ONE.dlShiftTo(2 * m.t, this.r2);
      this.mu = this.r2.divide(m);
      this.m = m;
    }

    public BigInteger convert(BigInteger x) {
      if (x.s < 0 || x.t > 2 * this.m.t) return x.mod(this.m);
      else if (x.compareTo(this.m) < 0) return x;
      else { BigInteger r = nbi(); x.copyTo(r); this.reduce(r); return r; }
    }

    public BigInteger revert(BigInteger x) { return x; }

    // x = x mod m (HAC 14.42)
    public void reduce(BigInteger x) {
      x.drShiftTo(this.m.t - 1, this.r2);
      if (x.t > this.m.t + 1) { x.t = this.m.t + 1; x.clamp(); }
      this.mu.multiplyUpperTo(this.r2, this.m.t + 1, this.q3);
      this.m.multiplyLowerTo(this.q3, this.m.t + 1, this.r2);
      while (x.compareTo(this.r2) < 0) x.dAddOffset(1, this.m.t + 1);
      x.subTo(this.r2, x);
      while (x.compareTo(this.m) >= 0) x.subTo(this.m, x);
    }

    // r = x^2 mod m; x != r
    public void sqrTo(BigInteger x, BigInteger r) { x.squareTo(r); this.reduce(r); }

    // r = x*y mod m; x,y != r
    public void mulTo(BigInteger x, BigInteger y, BigInteger r) { x.multiplyTo(y, r); this.reduce(r); }
  }

  // (public) this^e % m (HAC 14.85)
  public BigInteger modPow(BigInteger e, BigInteger m) {
    Integer i = e.bitLength(); Integer k; BigInteger r = nbv(1); IExp z;
    if (i <= 0) return r;
    else if (i < 18) k = 1;
    else if (i < 48) k = 3;
    else if (i < 144) k = 4;
    else if (i < 768) k = 5;
    else k = 6;
    if (i < 8) z = new Classic(m);
    else if (m.isEven()) z = new Barrett(m);
    else z = new Montgomery(m);

    // precomputation
    BigInteger[] g = new BigInteger[0]; Integer n = 3, k1 = k - 1, km = (1 << k) - 1;
    g[1] = z.convert(this);
    if (k > 1) {
      BigInteger g2 = nbi();
      z.sqrTo(g[1], g2);
      while (n <= km) {
        g[n] = nbi();
        z.mulTo(g2, g[n-2], g[n]);
        n += 2;
      }
    }

    Integer j = e.t - 1, w; Boolean is1 = true; BigInteger r2 = nbi(), t;
    i = nbits(e.z[j]) - 1;
    while (j >= 0) {
      if (i >= k1) w = (e.z[j]>>(i-k1)) & km;
      else {
        w = (e.z[j] & ((1 << (i + 1)) - 1)) << (k1 - i);
        if (j > 0) w |= e.z[j - 1] >> (this.DB + i - k1);
      }

      n = k;
      while ((w & 1) == 0) { w >>= 1; --n; }
      if ((i -= n) < 0) { i += this.DB; --j; }
      if (is1) { // ret == 1, don't bother squaring or multiplying it
        g[w].copyTo(r);
        is1 = false;
      }
      else {
        while (n > 1) { z.sqrTo(r, r2); z.sqrTo(r2, r); n -= 2; }
        if (n > 0) z.sqrTo(r, r2); else { t = r; r = r2; r2 = t; }
        z.mulTo(r2, g[w], r);
      }

      while (j >= 0 && (e.z[j] & (1 << i)) == 0) {
        z.sqrTo(r, r2); t = r; r = r2; r2 = t;
        if (--i < 0) { i = this.DB - 1; --j; }
      }
    }
    return z.revert(r);
  }

  // (public) gcd(this,a) (HAC 14.54)
  public BigInteger gcd(BigInteger a) {
    BigInteger x = this.s < 0 ? this.negate() : this.zclone();
    BigInteger y = a.s < 0 ? a.negate() : a.zclone();
    if (x.compareTo(y) < 0) { BigInteger t = x; x = y; y = t; }
    Integer i = x.getLowestSetBit(), g = y.getLowestSetBit();
    if (g < 0) return x;
    if (i < g) g = i;
    if (g > 0) {
      x.rShiftTo(g, x);
      y.rShiftTo(g, y);
    }
    while (x.signum() > 0) {
      if ((i = x.getLowestSetBit()) > 0) x.rShiftTo(i, x);
      if ((i = y.getLowestSetBit()) > 0) y.rShiftTo(i, y);
      if (x.compareTo(y) >= 0) {
        x.subTo(y, x);
        x.rShiftTo(1, x);
      }
      else {
        y.subTo(x, y);
        y.rShiftTo(1, y);
      }
    }
    if (g > 0) y.lShiftTo(g, y);
    return y;
  }

  // (protected) this % n, n < 2^26
  private Integer modInt(Integer n) {
    if (n <= 0) return 0;
    Integer d = Math.mod(this.DV, n), r = this.s < 0 ? n - 1 : 0;
    if (this.t > 0)
      if (d == 0) r = Math.mod(this.z[0], n);
      else for (Integer i = this.t - 1; i >= 0; --i) r = Math.mod(d * r + this.z[i], n);
    return r;
  }

  // (public) 1/this % m (HAC 14.61)
  public BigInteger modInverse(BigInteger m) {
    Boolean ac = m.isEven();
    if ((this.isEven() && ac) || m.signum() == 0) return BigInteger.ZERO;
    BigInteger u = m.zclone(), v = this.zclone();
    BigInteger a = nbv(1), b = nbv(0), c = nbv(0), d = nbv(1);
    while (u.signum() != 0) {
      while (u.isEven()) {
        u.rShiftTo(1, u);
        if (ac) {
          if (!a.isEven() || !b.isEven()) { a.addTo(this, a); b.subTo(m, b); }
          a.rShiftTo(1, a);
        }
        else if (!b.isEven()) b.subTo(m, b);
        b.rShiftTo(1, b);
      }
      while (v.isEven()) {
        v.rShiftTo(1, v);
        if (ac) {
          if (!c.isEven() || !d.isEven()) { c.addTo(this, c); d.subTo(m, d); }
          c.rShiftTo(1, c);
        }
        else if (!d.isEven()) d.subTo(m, d);
        d.rShiftTo(1, d);
      }
      if (u.compareTo(v) >= 0) {
        u.subTo(v, u);
        if (ac) a.subTo(c, a);
        b.subTo(d, b);
      }
      else {
        v.subTo(u, v);
        if (ac) c.subTo(a, c);
        d.subTo(b, d);
      }
    }
    if (v.compareTo(BigInteger.ONE) != 0) return BigInteger.ZERO;
    if (d.compareTo(m) >= 0) return d.subtract(m);
    if (d.signum() < 0) d.addTo(m, d); else return d;
    if (d.signum() < 0) return d.add(m); else return d;
  }

  static Integer[] lowprimes = new Integer[] { 2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,101,103,107,109,113,127,131,137,139,149,151,157,163,167,173,179,181,191,193,197,199,211,223,227,229,233,239,241,251,257,263,269,271,277,281,283,293,307,311,313,317,331,337,347,349,353,359,367,373,379,383,389,397,401,409,419,421,431,433,439,443,449,457,461,463,467,479,487,491,499,503,509,521,523,541,547,557,563,569,571,577,587,593,599,601,607,613,617,619,631,641,643,647,653,659,661,673,677,683,691,701,709,719,727,733,739,743,751,757,761,769,773,787,797,809,811,821,823,827,829,839,853,857,859,863,877,881,883,887,907,911,919,929,937,941,947,953,967,971,977,983,991,997 };
  static Integer lplim = (1 << 26) / lowprimes[lowprimes.size() - 1];

  // (public) test primality with certainty >= 1-.5^t
  public Boolean isProbablePrime(Integer t) {
    Integer i; BigInteger x = this.abs();
    if (x.t == 1 && x.z[0] <= lowprimes[lowprimes.size() - 1]) {
      for (i = 0; i < lowprimes.size(); ++i) if (x.z[0] == lowprimes[i]) return true;
      return false;
    }
    if (x.isEven()) return false;
    i = 1;
    while (i < lowprimes.size()) {
      Integer m = lowprimes[i], j = i + 1;
      while (j < lowprimes.size() && m < lplim) m *= lowprimes[j++];
      m = x.modInt(m);
      while (i < j) if (Math.mod(m, lowprimes[i++]) == 0) return false;
    }
    return x.millerRabin(t);
  }

// BigInteger interfaces not implemented in jsbn:
// BigInteger(int signum, byte[] magnitude)
// double doubleValue()
// float floatValue()
// int hashCode()
// long longValue()
// static BigInteger valueOf(long val)

  //#endregion

  final static Double Math_LN2 = 0.6931471805599453;

  //#region polyfill
  String String_valueOf(Integer a, Integer radix) { if (radix != 10) throw new IllegalArgumentException('Not Implemented'); return String.valueOf(a); }
  public void copyTo(BigInteger s) { }
  //#endregion

  //#region missing
  BigInteger negate() { throw new IllegalArgumentException('Not Implemented'); }
  Integer bitLength() { throw new IllegalArgumentException('Not Implemented'); }
  Integer nbits(Integer a) { throw new IllegalArgumentException('Not Implemented'); }
  Boolean isEven() { throw new IllegalArgumentException('Not Implemented'); }
  BigInteger exp(Integer s, IExp exp) { throw new IllegalArgumentException('Not Implemented'); }
  void subTo(BigInteger s, BigInteger b) { throw new IllegalArgumentException('Not Implemented'); }
  void multiplyTo(BigInteger s, BigInteger b) { throw new IllegalArgumentException('Not Implemented'); }
  BigInteger abs() { throw new IllegalArgumentException('Not Implemented'); }
  void rShiftTo(Integer s, BigInteger b) { throw new IllegalArgumentException('Not Implemented'); }
  void lShiftTo(Integer s, BigInteger b) { throw new IllegalArgumentException('Not Implemented'); }
  void dlShiftTo(Integer s, BigInteger b) { throw new IllegalArgumentException('Not Implemented'); }
  void drShiftTo(Integer s, BigInteger b) { throw new IllegalArgumentException('Not Implemented'); }
  Integer compareTo(BigInteger s) { throw new IllegalArgumentException('Not Implemented'); }
  void divRemTo(BigInteger a, BigInteger q, BigInteger r) { throw new IllegalArgumentException('Not Implemented'); }
  void squareTo(BigInteger a) { throw new IllegalArgumentException('Not Implemented'); }
  Boolean millerRabin(Integer a) { throw new IllegalArgumentException('Not Implemented'); }
  BigInteger mod(BigInteger a) { throw new IllegalArgumentException('Not Implemented'); }
  Integer am(Integer a, Integer b, BigInteger c, Integer d, Integer e, Integer f) { throw new IllegalArgumentException('Not Implemented'); }
  //#endregion
}