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
//:ref https://developer.commercecloud.com/s/question/0D53k00006e77JrCAI/rsassapss-signture-with-sfcc
public class AP_SignatureHelper {
    private final AP_PayConfiguration payConfiguration;
    private final String LINE_SEPARATOR = '\n';
    public final static Integer SALT_LENGTH = 20;
    public final static Integer TRAILER_FIELD = 1;

    public AP_SignatureHelper(final AP_PayConfiguration payConfiguration) {
        this.payConfiguration = payConfiguration;
    }

    /**
     * Creates a string that includes the information from the request in a standardized(canonical) format.
     * @param uri The uri that needs to be executed
     * @param httpMethodName the HTTP request method(GET,PUT,POST etc) to be used
     * @param parameters the query parameters map
     * @param requestPayload the payload to be sent with the request
     * @param preSignedHeaders the mandatory headers required
     * @return a canonical request
     */
    public String createCanonicalRequest(final URL uri,
                                         final String httpMethodName,
                                         final Map<String, List<String>> parameters,
                                         final String requestPayload,
                                         final Map<String, List<String>> preSignedHeaders) {
        final String path = uri.getPath();
        final List<String> b = new List<String>(); b.add(httpMethodName);

        try {
            b.add(LINE_SEPARATOR);
            b.add(getCanonicalizedURI(path));
            b.add(LINE_SEPARATOR);
            b.add(getCanonicalizedQueryString(parameters));
            b.add(LINE_SEPARATOR);
            b.add(getCanonicalizedHeaderString(preSignedHeaders));
            b.add(LINE_SEPARATOR);
            b.add(getSignedHeadersString(preSignedHeaders));
            b.add(LINE_SEPARATOR);
            b.add(hashThenHexEncode(requestPayload));
        } catch (Exception e) {
            throw new AP_AmazonPayClientException(e.getMessage(), e);
        }

        return String.join(b, '');
    }

    /**
     * Creates the string that is going to be signe
     * @param canonicalRequest The canonical request generated using the createCanonicalRequest() method
     * @return the string to be signed
     */
    public String createStringToSign(final String canonicalRequest) {
        final String hashedCanonicalRequest = hashThenHexEncode(canonicalRequest);

        final List<String> b = new List<String>(); b.add(AP_ServiceConstants.AMAZON_SIGNATURE_ALGORITHM);
        b.add(LINE_SEPARATOR);
        b.add(hashedCanonicalRequest);

        return String.join(b, '');
    }

    /**
     * Generates a signature for the string passed in
     * @param stringToSign the string to be signed
     * @param privateKey the private key to use for signing
     * @return the signature
     */
    public String generateSignature(final String stringToSign, final AP_PrivateKey privateKey) {
        Blob hmac = Crypto.generateMac('HMACSHA256', blob.valueOf(stringToSign), privateKey.key()); 
        return EncodingUtil.convertToHex(hmac);
        
        // final Signature signature = Signature.getInstance(AP_ServiceConstants.SIGNATURE_ALGORITHM, BouncyCastleProvider.PROVIDER_NAME);
        // final MGF1ParameterSpec mgf1ParameterSpec = new MGF1ParameterSpec(AP_ServiceConstants.HASH_ALGORITHM);
        // final PSSParameterSpec pssParameterSpec = new PSSParameterSpec(AP_ServiceConstants.HASH_ALGORITHM,
        //         AP_ServiceConstants.MASK_GENERATION_FUNCTION, mgf1ParameterSpec, SALT_LENGTH, TRAILER_FIELD);
        // signature.setParameter(pssParameterSpec);
        // signature.initSign(privateKey);
        // signature.update(stringToSign.getBytes());
        // privateKey.sign(AP_ServiceConstants.HASH_ALGORITHM)

        // return new String(Base64.encode(signature.sign()));
    }

    /**
     * Creates the mandatory headers required in the request
     * @param uri the uri to be executed
     * @param header Map&lt;String, String&gt; containining key-value pair of required headers (e.g., keys such as x-amz-pay-idempotency-key, x-amz-pay-authtoken)
     * @return a map of mandatory headers
     */
    public Map<String, List<String>> createPreSignedHeaders(final URL uri, final Map<String, String> header) {
        final Map<String, List<String>> headers = new Map<String, List<String>>();

        //List of Headers added by Amazon Pay
        final List<String> acceptHeaderValue = new List<String>();
        acceptHeaderValue.add('application/json');
        headers.put('accept', acceptHeaderValue);

        final List<String> contentHeaderValue = new List<String>();
        contentHeaderValue.add('application/json');
        headers.put('content-type', contentHeaderValue);

        final List<String> regionHeaderValue = new List<String>();
        regionHeaderValue.add(payConfiguration.getRegion().name());
        headers.put('x-amz-pay-region', regionHeaderValue);

        final List<String> dateHeaderValue = new List<String>();
        dateHeaderValue.add(AP_Util.getFormattedTimestamp());
        headers.put('x-amz-pay-date', dateHeaderValue);

        final List<String> hostHeaderValue = new List<String>();
        hostHeaderValue.add(uri.getHost());
        headers.put('x-amz-pay-host', hostHeaderValue);

        //If no header is provided by the merchant, return the headers added by Amazon Pay
        if (header == null || header.isEmpty()) {
            return headers;
        }

        //Executes only if header is sent by the merchant.
        //Converts the Merchant's header to lowercase for case insensitivity.
        final Map<String, String> lowerCaseUserHeader = new Map<String, String>();
        for (String key : header.keySet()) {
            lowerCaseUserHeader.put(key.toLowerCase(), header.get(key));
        }

        final Set<String> headersKeySet = headers.keySet();

        //Checks if the merchant's header is already present in headers added by Amazon Pay
        //If present, override headers by Amazon Pay with Merchant provided header value
        //Adds any new header sent by Merchant
        for (String key : lowerCaseUserHeader.keySet()) {
            String value = lowerCaseUserHeader.get(key);
            if (headersKeySet.contains(key)) {
                final List<String> alreadyPresentHeaderValue = new List<String>();
                alreadyPresentHeaderValue.add(value);
                headers.put(key, alreadyPresentHeaderValue);
            } else {
                final List<String> newHeaderValue = new List<String>();
                newHeaderValue.add(value);
                headers.put(key, newHeaderValue);
            }
        }

        return headers;
    }

    /**
     * Generates a string that is a list of headers names that are included in the canonical headers.
     * This is to identify which headers are a part of the signing process.
     * @param preSignedHeaders the mandatory header
     * @return the string of signed headers
     */
    public String getSignedHeadersString(final Map<String, List<String>> preSignedHeaders) {
        final List<String> sortedHeaders = new List<String>(preSignedHeaders.keySet());
        sortedHeaders.sort();

        final List<String> b = new List<String>();
        for (String header : sortedHeaders) {
            if (b.size() > 0) {
                b.add(';');
            }
            b.add(AP_Util.lowerCase(header));
        }

        return String.join(b, '');
    }

    /**
     * Generates a canonical headers string that consists of a list of all HTTP headers
     * that are included with the request.
     * @param preSignedHeaders the mandatory headers
     * @return the canonical header string
     */
    public String getCanonicalizedHeaderString(final Map<String, List<String>> preSignedHeaders) {
        final List<String> sortedHeaders = new List<String>(preSignedHeaders.keySet());
        sortedHeaders.sort();

        final Map<String, List<String>> requestHeaders = preSignedHeaders;
        final List<String> b = new List<String>();
        for (String header : sortedHeaders) {
            String key = AP_Util.lowerCase(header);
            List<String> values = requestHeaders.get(header);
            List<String> headerValue = new List<String>();
            for (String value : values) {
                if (headerValue != null) {
                    if (headerValue.size() > 0) {
                        headerValue.add(',');
                    }
                    headerValue.add(value.trim().replaceAll('\\s', ' '));
                }
            }
            b.add(key.trim().replaceAll('\\s', ' '));
            b.add(':');
            if (headerValue != null) {
                b.add(String.join(headerValue, ''));
            }
            b.add(LINE_SEPARATOR);
        }

        return String.join(b, '');
    }

    /**
     * Generates a canonical string that consists of all the query parameters
     * @param parameters the query parameters of the request
     * @return the canonical query string
     */
    public String getCanonicalizedQueryString(final Map<String, List<String>> parameters) {
        final Map<String, List<String>> sorted = new Map<String, List<String>>();

        /**
         * Signing protocol expects the param values also to be sorted after url
         * encoding in addition to sorted parameter names.
         */
        if (parameters != null) {
            for (String key : parameters.keySet()) {
                final String encodedParamName = AP_Util.urlEncode(key, false);
                final List<String> paramValues = parameters.get(key);
                final List<String> encodedValues = new List<String>();
                for (String value : paramValues) {
                    encodedValues.add(AP_Util.urlEncode(value, false));
                }
                encodedValues.sort();
                sorted.put(encodedParamName, encodedValues);
            }
        }

        final List<String> b = new List<String>();
        for (String key : sorted.keySet()) {
            for (String value : sorted.get(key)) {
                if (b.size() > 0) {
                    b.add('&');
                }
                b.add(key);
                b.add('=');
                b.add(value);
            }
        }

        return String.join(b, '');
    }

    /**
     * Generates a canonical URL string
     * @param path the path of the uri provided
     * @return canonical URL string
     */
    private String getCanonicalizedURI(final String path) {
        if (path == null || String.isEmpty(path)) {
            return '/';
        } else {
            String value = AP_Util.urlEncode(path, true);
            if (value.startsWith('/')) {
                return value;
            } else {
                return '/' + value;
            }
        }
    }

    /**
     * Generates a Hex encoded string from a hashed value of the payload string
     * @param requestPayload the payload to be hashed
     * @return the hashed payload string
     */
    private String hashThenHexEncode(final String requestPayload) {
        final Blob digest = Crypto.generateDigest(AP_ServiceConstants.HASH_ALGORITHM, Blob.valueOf(requestPayload));
        
        final String contentSha256 = EncodingUtil.convertToHex(digest);
        return contentSha256;
    }
}
