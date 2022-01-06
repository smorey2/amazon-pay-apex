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
public class AP_Util {
    public static String JAVA_VERSION = '53.0';
    public static String OS_NAME = 'Salesforce';
    public static String OS_VERSION = '53.0';
    public static String DEFAULT_ENCODING = 'UTF-8';

    /**
     * Generates a url encoded string from the given string
     * @param value the string to be encoded
     * @param path to determine if the given value is a string or not
     * @return the url encoded string
     */
    public static String urlEncode(String value, final Boolean path) {
        if (value == null) {
            return '';
        }

        try {
            if (path) {
                value = value.replaceAll('/+', '/');
            }
            final String encoded = EncodingUtil.URLENCODE(value, DEFAULT_ENCODING);

            String replacement = encoded.replace('+', '%20')
                .replace('*', '%2A')
                .replace('%7E', '~');
            return path
                ? replacement.replace('%2F', '/')
                : replacement;
        } catch (Exception ex) {
            throw new AP_AmazonPayClientException('Encountered UnsupportedEncodingException:', ex);
        }
    }

    /**
     * Generates a lower case string from the given string
     * @param str the string to be converted
     * @return the lower case string
     */
    public static String lowerCase(final String str) {
        if (str == null || String.isEmpty(str)) {
            return str;
        }
        return str.toLowerCase();
    }

    /**
     * Generates the current time stamp in 'yyyyMMdd'T'HHmmss'Z'' format
     * @return the formatted timestamp
     */
    public static String getFormattedTimestamp() {
        Datetime now = Datetime.now();
        return now.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
    }

    /**
     * To get the service URL
     * @param payConfiguration the PayConfiguration object
     * @param action the action to be performed by the request
     * @return the service URL
     */
    public static URL getServiceURI(AP_PayConfiguration payConfiguration, String action) {
        URL uri;
        try {
            String endpoint = AP_ServiceConstants.endpointMappings.get(payConfiguration.getRegion());
            if (payConfiguration.getOverrideServiceURL() != null) {
                endpoint = 'https://' + payConfiguration.getOverrideServiceURL();
            } else {
                endpoint = AP_ServiceConstants.endpointMappings.get(payConfiguration.getRegion());
            }
            uri = new URL(endpoint + getServiceVersionName(payConfiguration, action));
        } catch (Exception e) {
            throw new AP_AmazonPayClientException(e.getMessage(), e);
        }
        return uri;
    }

    /**
     * To get the service version name
     * @param payConfiguration the PayConfiguration object
     * @param action the action to be performed by the request
     * @return the service version name
     */
    private static String getServiceVersionName(AP_PayConfiguration payConfiguration, String action) {
        String serviceVersionName = '';
        if (serviceSupportsEnvPublicKeyId(payConfiguration)) {
            serviceVersionName = '/' + action;
        } else {
            if (payConfiguration.getEnvironment() == AP_Environment.SANDBOX) {
                serviceVersionName = '/' + 'sandbox' + '/' + action;
            } else {
                serviceVersionName = '/' + 'live' + '/' + action;
            }
        }
        return serviceVersionName;
    }

    private static Boolean serviceSupportsEnvPublicKeyId(AP_PayConfiguration payConfiguration) {
        return payConfiguration.getPublicKeyId().toUpperCase().startsWith('LIVE') || 
                payConfiguration.getPublicKeyId().toUpperCase().startsWith('SANDBOX');
    }

    /**
     * Returns the next wait interval, in milliseconds, using an exponential
     * backoff algorithm.
     * @param retryCount The current retry count
     * @return the wait time
     */
    public static Long getExponentialWaitTime(Integer retryCount) {
        return ((Long)Math.pow(2, retryCount) * 1000L);
    }

    /**
     * Returns the header with idempotency key, if not provided by the Merchant.
     * Used for Webstore POST requests.
     * @param header Header sent by the merchant
     * @return header Header with Idempotency key
     */
    public static Map<String, String> updateHeader(Map<String, String> header) {
        if (header == null || header.isEmpty()) {
            final Map<String, String> headerMap = new Map<String, String>();
            headerMap.put('x-amz-pay-idempotency-key', getRandomUUID().replace('-', ''));
            return headerMap;
        }

        Boolean isIdempotencyKeyPresent = false;
        for (String key : header.keySet()) {
            if (key.toLowerCase().equals('x-amz-pay-idempotency-key')) {
                isIdempotencyKeyPresent = true;
                break;
            }
        }

        if (!isIdempotencyKeyPresent) {
            header.put('x-amz-pay-idempotency-key', getRandomUUID().replace('-', ''));
        }

        return header;
    }

    /**
     * Returns the HttpRequest object based on the given HTTP Method Name and URL specification.
     * 
     * @param httpMethodName the HTTP method
     * @param uri the URL
     * @return the Commons HttpRequest object
     */
    public static HttpRequest getHttpRequest(final URL uri, final String httpMethodName, final String payload) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(uri.toExternalForm());
        switch on (httpMethodName) {
            when 'GET' { req.setMethod('GET'); return req; }
            when 'POST' {
                req.setMethod('POST');
                req.setBody(payload);
                return req;
            }
            when 'PUT' {
                req.setMethod('PUT');
                req.setBody(payload);
                return req;
            }
            when 'PATCH' {
                req.setMethod('PATCH');
                req.setBody(payload);
                return req;
            }
            when 'HEAD' { req.setMethod('HEAD'); }
            when 'DELETE' {
                req.setMethod('DELETE');
                req.setBody(payload);
                return req;
            }
            when 'OPTIONS' { req.setMethod('OPTIONS'); return req; }
            when 'TRACE' { req.setMethod('TRACE'); return req; }
            when else { throw new AP_AmazonPayClientException('Invalid HTTP method ' + httpMethodName); }
        }
        return req;
    }
    
    /**
     * Returns the Http object based on the given proxy settings.
     * 
     * @param proxySettings the ProxySettings
     * @return the Http
     */
    public static Http getHttpClientWithProxy(final AP_ProxySettings proxySettings) {
        Http http = new Http();
        return http;
    }

    /**
     * Get random UUID
     * @return A random UUID
     */
    public static String getRandomUUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        return h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
    }

    /**
     * Spin locks for given time
     * @param waitTime the delay in milliseconds
     */
    public static void sleep(Long waitTime) {
        Long startingTime = System.now().getTime();
        while (System.now().getTime() - startingTime < waitTime) {
        // Do nothing until desired delay has passed
        }
    }
}
