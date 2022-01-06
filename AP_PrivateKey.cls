public class AP_PrivateKey {
    private String algorithmName;
    private Blob privateKey;

    public AP_PrivateKey(String algorithmName, final Blob privateKey) {
        this.algorithmName = algorithmName;
        this.privateKey = privateKey;
    }

    public Blob key() {
       return privateKey;
    }
    /**
     * @param input The Input
     */
    public void sign(Blob input) {
        Crypto.sign(algorithmName, input, privateKey);
    }
}
