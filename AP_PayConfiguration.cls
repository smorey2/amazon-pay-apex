/**
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 * http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */
public class AP_PayConfiguration {
    @testVisible private static AP_PrivateKey mockPrivateKey;
    private AP_Region region;
    private String publicKeyId;
    private AP_PrivateKey privateKey;
    private AP_Environment environment;
    private Integer maxRetries = 3;
    private Boolean userAgentRedaction = false;
    private AP_ProxySettings proxySettings;
    protected String overrideServiceURL;

    /**
     * @return Returns region code from PayConfiguration
     */
    public AP_Region getRegion() {
        return region;
    }

    /**
     * @param region Identifies region associated with Amazon Pay API operations.
     * @return the PayConfiguration object
     */
    public AP_PayConfiguration setRegion(final AP_Region region) {
        this.region = region;
        return this;
    }

    /**
     * @return returns the public key id from the PayConfiguration
     */
    public String getPublicKeyId() {
        return publicKeyId;
    }

    /**
     * @param publicKeyId The public key id of the merchant
     * @return the PayConfiguration object
     */
    public AP_PayConfiguration setPublicKeyId(final String publicKeyId) {
        this.publicKeyId = publicKeyId;
        return this;
    }

    /**
     * @return returns the private key object from the PayConfiguration
     */
    public AP_PrivateKey getPrivateKey() {
        return privateKey;
    }

    /**
     * @deprecated This method is deprecated, instead use setPrivateKey(char[] privateKey)
     * @param privateKey The private key String
     * @return the PayConfiguration object
     */
    public AP_PayConfiguration setPrivateKey(final String privateKey) {
        return setPrivateKey(buildPrivateKey(EncodingUtil.base64Decode(privateKey)));
    }

    /**
     * @param privateKey The private key char array
     * @return the PayConfiguration object
     */
    public AP_PayConfiguration setPrivateKey(final Blob privateKey) {
        return setPrivateKey(buildPrivateKey(privateKey));
    }

    /**
     * @param privateKey the PrivateKey object
     * @return the PayConfiguration object
     */
    public AP_PayConfiguration setPrivateKey(AP_PrivateKey privateKey) {
        this.privateKey = privateKey;
        return this;
    }

    /**
     * @return returns the environment from the PayConfiguration
     */
    public AP_Environment getEnvironment() {
        return environment;
    }

    /**
     * @param environment the environment,i.e, Sandbox or Live
     * @return the PayConfiguration object
     */
    public AP_PayConfiguration setEnvironment(AP_Environment environment) {
        this.environment = environment;
        return this;
    }

    /**
     * @return the maximum number of retries to be made
     */
    public Integer getMaxRetries() {
        return maxRetries;
    }

    /**
     * @param maxRetries Sets the maximum number of retries to be made in case of internal server
     *                   errors or throttling errors, in PayConfiguration
     * @return the PayConfiguration object
     */
    public AP_PayConfiguration setMaxRetries(final Integer maxRetries) {
        this.maxRetries = maxRetries;
        return this;
    }

    /**
     * Returns true if the merchant wants to set the Java and OS version segment in
     * the User-Agent header to 'Redacted'.
     *
     * @return Boolean userAgentRedaction
     */
    public Boolean isUserAgentRedaction() {
        return userAgentRedaction;
    }


    /**
     * Sets userAgentRedaction in PayConfiguration
     * If this flag is set to true, the Java and OS version segment in the User-Agent header is
     * 'Redacted'.
     *
     * @param userAgentRedaction - argument that sets userAgentRedaction in PayConfiguration
     * @return the PayConfiguration object
     */
    public AP_PayConfiguration setUserAgentRedaction(final Boolean userAgentRedaction) {
        this.userAgentRedaction = userAgentRedaction;
        return this;
    }

    /**
     * @return proxySettings Returns Proxy Settings in PayConfiguration
     */
    public AP_ProxySettings getProxySettings() {
        return proxySettings;
    }

    /**
     * @param proxySettings Sets the Proxy Settings in PayConfiguration
     * This should only be used if you need to enable internet traffic flows through the proxy server
     * @return the PayConfiguration object
     */
    public AP_PayConfiguration setProxySettings(AP_ProxySettings proxySettings) {
        this.proxySettings = proxySettings;
        return this;
    }
    
    /**
     * @return overrideServiceURL Returns overridden MWS Service URL in PayConfiguration
     */
    public String getOverrideServiceURL() {
        return overrideServiceURL;
    }

    //:ref https://salesforce.stackexchange.com/questions/80804/how-to-create-a-signature-using-crypto-class
    /**
     * Builds the PrivateKey object from the private key provided
     * @param char[] privateKey the private key provided
     * @return the PrivateKey object
     */
    private static AP_PrivateKey buildPrivateKey(final Blob privateKey) {
        if (mockPrivateKey != null) { 
            return mockPrivateKey;
        }
        if (privateKey == null || privateKey.size() == 0) {
            throw new AP_AmazonPayClientException('Private key char array cannot be null or empty');
        }

        AP_PrivateKey privateKeyObject = new AP_PrivateKey('RSA', privateKey);
        try {
            Blob input = Blob.valueOf('12345qwerty');
            privateKeyObject.sign(input);
        }
        catch (Exception e) {
            throw new AP_AmazonPayClientException(e.getMessage(), e);
        }

        return privateKeyObject;
    }

}
