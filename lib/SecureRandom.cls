public class SecureRandom {

  //#region prng4.js
  class Arcfour {
    Integer i = 0;
    Integer j = 0;
    Integer[] S = new Integer[0]; void S_grow(Integer size) { while (S.size() < size) S.add(0); }
  
    // Initialize arcfour context from key, an array of ints, each from [0..255]
    public void init(Integer[] key) {
      Integer i, j, t;
      S_grow(256);
      for (i = 0; i < 256; ++i) this.S[i] = i;
      j = 0;
      for (i = 0; i < 256; ++i) {
        j = (j + this.S[i] + key[Math.mod(i, key.size())]) & 255;
        t = this.S[i];
        this.S[i] = this.S[j];
        this.S[j] = t;
      }
      this.i = 0;
      this.j = 0;
    }
   
    public Integer next() {
      Integer t;
      this.i = (this.i + 1) & 255;
      this.j = (this.j + this.S[this.i]) & 255;
      t = this.S[this.i];
      this.S[this.i] = this.S[this.j];
      this.S[this.j] = t;
      return this.S[(t + this.S[this.i]) & 255];
    }
  }

  Arcfour prng_newstate() { return new Arcfour(); }
   
  // Pool size must be a multiple of 4 and greater than 32.
  // An array of bytes the size of the pool will be passed to init()
  Integer rng_psize = 256;
  //#endregion

  // Random number generator - requires a PRNG backend, e.g. prng4.js

  // For best results, put code like
  // <body onClick='rng_seed_time();' onKeyPress='rng_seed_time();'>
  // in your main HTML document.
  //#region rngLib.ds

  private Arcfour rng_state;
  private List<Integer> rng_pool; void rng_pool_grow(Integer size) { while (rng_pool.size() < size) rng_pool.add(0); }
  private Integer rng_pptr;

  // Mix in a 32-bit integer into the pool
  private void rng_seed_int(Integer x) {
    rng_pool_grow(rng_pptr + 4);
    rng_pool[rng_pptr++] ^= x & 255;
    rng_pool[rng_pptr++] ^= (x >> 8) & 255;
    rng_pool[rng_pptr++] ^= (x >> 16) & 255;
    rng_pool[rng_pptr++] ^= (x >> 24) & 255;
    if (rng_pptr >= rng_psize) rng_pptr -= rng_psize;
  }

  // Mix in the current time (w/milliseconds) into the pool
  private void rng_seed_time() {
    rng_seed_int((Integer)Datetime.now().getTime());
  }

// Initialize the pool with junk if needed.
  public SecureRandom() {
    if (rng_pool == null) {
      rng_pool = new List<Integer>();
      rng_pptr = 0;
      Integer t;
      // if (false) {
      //   // Extract entropy (256 bits) from NS4 RNG if available
      //   var z = window.crypto.random(32);
      //   for (t = 0; t < z.length; ++t)
      //     rng_pool[rng_pptr++] = z.charCodeAt(t) & 255;
      // } 
      while (rng_pptr < rng_psize) {  // extract some randomness from Math.random()
        t = (Integer)Math.floor(65536 * Math.random());
        rng_pool_grow(rng_pptr + 2);
        rng_pool[rng_pptr++] = t >>> 8;
        rng_pool[rng_pptr++] = t & 255;
      }
      rng_pptr = 0;
      rng_seed_time();
    }
  }

  private Integer rng_get_byte() {
    if (rng_state == null) {
      rng_seed_time();
      rng_state = prng_newstate();
      rng_state.init(rng_pool);
      for (rng_pptr = 0; rng_pptr < rng_pool.size(); ++rng_pptr) rng_pool[rng_pptr] = 0;
      rng_pptr = 0;
    }

    return rng_state.next();
  }

  public void nextBytes(Integer[] ba) {
    Integer i;
    for (i = 0; i < ba.size(); ++i) ba[i] = rng_get_byte();
  }

  //#endregion
}
