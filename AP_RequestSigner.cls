/**
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the 'License').
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 * http://aws.amazon.com/apache2.0
 *
 * or in the 'license' file accompanying this file. This file is distributed
 * on an 'AS IS' BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */
public class AP_RequestSigner {
    final private AP_PayConfiguration payConfiguration;
    final private AP_SignatureHelper signatureHelper;
    final private AP_PrivateKey privateKey;

    public AP_RequestSigner(final AP_PayConfiguration payConfiguration) {
        checkIfConfigParametersAreSet(payConfiguration);
        this.payConfiguration = payConfiguration;
        signatureHelper = new AP_SignatureHelper(payConfiguration);
        privateKey = payConfiguration.getPrivateKey();
    }

    /**
     * Signs the request provided and returns the signed headers map
     * @param uri The uri that needs to be executed
     * @param httpMethodName the HTTP request method(GET,PUT,POST etc) to be used
     * @param queryParameters the query parameters map
     * @param requestPayload the payload to be sent with the request
     * @param header Map&lt;String, String&gt; containining key-value pair of required headers (e.g., keys such as x-amz-pay-idempotency-key, x-amz-pay-authtoken)
     * @return a map of signed headers
     */
    public Map<String, String> signRequest(final URL uri,
                                           final String httpMethodName,
                                           final Map<String, List<String>> queryParameters,
                                           final String requestPayload,
                                           final Map<String, String> header) {
        final String publicKeyId = payConfiguration.getPublicKeyId();
        final Map<String, List<String>> preSignedHeaders = signatureHelper.createPreSignedHeaders(uri, header);
        final String userAgent = buildUserAgentHeader();

        String signature = null;
        try {
            final String canonicalRequest = signatureHelper.createCanonicalRequest(uri, httpMethodName, queryParameters, requestPayload, preSignedHeaders);
            final String stringToSign = signatureHelper.createStringToSign(canonicalRequest);
            signature = signatureHelper.generateSignature(stringToSign, privateKey);
        }
        catch (Exception e) { 
            throw new AP_AmazonPayClientException(e.getMessage(), e);
        }

        final String authorizationHeader = buildAuthorizationHeader(publicKeyId, preSignedHeaders, signature);

        Map<String, String> postSignedHeadersMap = new Map<String, String>();

        for (String key : preSignedHeaders.keySet()) {
            postSignedHeadersMap.put(key.toLowerCase(), preSignedHeaders.get(key).get(0));
        }
        postSignedHeadersMap.put('authorization', authorizationHeader);
        postSignedHeadersMap.put('user-agent', userAgent);

        return postSignedHeadersMap;
    }

    /**
     * Builds the user agent header
     * @return the user agent string
     */
    private String buildUserAgentHeader() {
        final String javaVersion = payConfiguration.isUserAgentRedaction() ? AP_ServiceConstants.REDACTED : AP_Util.JAVA_VERSION;
        final String osName = payConfiguration.isUserAgentRedaction() ? AP_ServiceConstants.REDACTED : AP_Util.OS_NAME;
        final String osVersion = payConfiguration.isUserAgentRedaction() ? AP_ServiceConstants.REDACTED : AP_Util.OS_VERSION;

        final List<String> b = new List<String>();
        b.add(AP_ServiceConstants.GITHUB_SDK_NAME); b.add('/');
        b.add(AP_ServiceConstants.APPLICATION_LIBRARY_VERSION);
        b.add(' ('); b.add('Apex/'); b.add(javaVersion);
        b.add('; '); b.add(osName);
        b.add('/'); b.add(osVersion); b.add(')');

        return String.join(b, '');
    }

    /**
     * Builds the authorization header
     * @param publicKeyId the public key id from the PayConfiguration
     * @param preSignedHeaders the set of pre signed headers
     * @param signature the generated signature
     * @return the authorization string
     */
    private String buildAuthorizationHeader(String publicKeyId,
                                            Map<String, List<String>> preSignedHeaders,
                                            String signature) {

        // The parameters being null should never happen at this point, because that
        // case should be caught by other exceptions upstream.
        // Including this as a final sanity check.
        if (publicKeyId == null || preSignedHeaders == null || signature == null) {
            throw new AP_AmazonPayClientException('Invalid parameter while constructing authorization header');
        }

        final List<String> b = new List<String>();
        b.add(AP_ServiceConstants.AMAZON_SIGNATURE_ALGORITHM);
        b.add(' PublicKeyId=');b.add(publicKeyId);b.add(', ');b.add('SignedHeaders=');
        b.add(signatureHelper.getSignedHeadersString(preSignedHeaders));
        b.add(', Signature=');b.add(signature);

        return String.join(b, '');
    }

    /**
     * Helper method to check if required values are set.
     * @param payConfiguration the PayConfiguration object
     */
    private void checkIfConfigParametersAreSet(AP_PayConfiguration payConfiguration) {
        if (payConfiguration.getRegion() == null || String.isEmpty(payConfiguration.getRegion().name())) {
            generateException(AP_ServiceConstants.REGION);
        }
        if (payConfiguration.getPrivateKey() == null) {
            generateException(AP_ServiceConstants.PRIVATE_KEY);
        }
        if (payConfiguration.getPublicKeyId() == null || String.isEmpty(payConfiguration.getPublicKeyId())) {
            generateException(AP_ServiceConstants.PUBLIC_KEY_ID);
        }
    }

    /**
     * To throw an exception if required values in the PayConfiguration are missing
     * @param parameter
     */
    private void generateException(String parameter) {
        throw new IllegalArgumentException(parameter + ' is not set in the PayConfiguration, this is a required parameter');
    }
}