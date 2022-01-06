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
public abstract class AP_AmazonPayClient {
    final protected AP_PayConfiguration payConfiguration;
    final protected AP_RequestSigner requestSigner;

    public AP_AmazonPayClient(final AP_PayConfiguration payConfiguration) {
        this.payConfiguration = payConfiguration;
        requestSigner = new AP_RequestSigner(payConfiguration);
    }

    /**
     * The Delivery Tracker operation is used to track the delivery status
     *
     * @param payload JSONParse request body
     * @param header Map&lt;String, String&gt; containining key-value pair of required headers (e.g., keys such as x-amz-pay-idempotency-key, x-amz-pay-authtoken)
     * @return The response from the deliveryTracker service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse deliveryTracker(final JSONParse payload, final Map<String, String> header) {
        final URL deliveryTrackerURI = AP_Util.getServiceURI(payConfiguration, AP_ServiceConstants.DELIVERY_TRACKERS);
        return callAPI(deliveryTrackerURI, 'POST', null, payload.toString(), header);
    }

    /**
     * The get Authorization Token operation is used to obtain retrieve a delegated authorization token
     *  used in order to make API calls on behalf of a merchant.
     *  This token is needed to make delegated calls.
     * Important: getAuthorizationToken() requires a Client configured to use the live environment.
     *
     * @param  mwsAuthToken MWS Authorization Token previously shared by Merchant to the Solution Provider
     * @param  merchantId Merchant ID that generated the MWS Authorization Token
     * @param header Map&lt;String, String&gt; containining key-value pair of required headers (e.g., keys such as x-amz-pay-idempotency-key, x-amz-pay-authtoken)
     * @return The response from the getAuthorizationToken service API, as returned by Amazon Pay.
     * @see AmazonPayClient
     * @see PayConfiguration
     * @see com.amazon.pay.api.types.Environment
     */
    public AP_AmazonPayResponse getAuthorizationToken(final String mwsAuthToken, final String merchantId, final Map<String, String> header) {
        final URL authorizationTokenURI = AP_Util.getServiceURI(payConfiguration, AP_ServiceConstants.AUTHORIZATION_TOKEN);
        final URL getAuthorizationTokenURI = new URL(authorizationTokenURI, authorizationTokenURI.getPath() + '/' + mwsAuthToken + '?merchantId=' + merchantId);
        final Map<String, List<String>> queryParametersMap = new Map<String, List<String>>();
        List<String> auxList = new List<String>();
        auxList.add(merchantId);
        queryParametersMap.put('merchantId', auxList);
        return callAPI(getAuthorizationTokenURI, 'GET', queryParametersMap, '', header);
    }

    /**
     * The Delivery Tracker operation is used to track the delivery status
     *
     * @param payload JSONParse request body
     * @return The response from the deliveryTracker service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse deliveryTracker(final JSONParse payload) {
        return deliveryTracker(payload, null);
    }

    /**
     * generateButtonSignature is a convenience method to assist the developer in generating static signatures
     * that can be used by Checkout v2's amazon.Pay.renderButton method.  Unlike API call signatures, the
     * system timestamp is not part of the signing logic, so these signatures do not expire.
     *
     * @param payload The payloadJSON attribute from createCheckoutSessionConfig object used by amazon.Pay.renderButton method from checkout.js
     * @return String signature attribute value for createCheckoutSessionConfig object on your website frontend
     */
    public String generateButtonSignature(final JSONParse payload) {
        return generateButtonSignature(payload.toString());
    }

    /**
     * generateButtonSignature is a convenience method to assist the developer in generating static signatures
     * that can be used by Checkout v2's amazon.Pay.renderButton method.  Unlike API call signatures, the
     * system timestamp is not part of the signing logic, so these signatures do not expire.
     *
     * @param payload The payloadJSON attribute from createCheckoutSessionConfig object used by amazon.Pay.renderButton method from checkout.js
     * @return String signature attribute value for createCheckoutSessionConfig object on your website frontend
     */
    public String generateButtonSignature(final String payload) {
        String signature = null;
        final AP_SignatureHelper signatureHelper = new AP_SignatureHelper(payConfiguration);
        try {
            final String stringToSign = signatureHelper.createStringToSign(payload);
            signature =  signatureHelper.generateSignature(stringToSign, payConfiguration.getPrivateKey());
        }
        catch (Exception e) { 
            throw new AP_AmazonPayClientException(e.getMessage(), e);
        }
        return signature;
    }

    /**
     * API to process the request and return the
     *
     * @param uri             The uri that needs to be executed
     * @param httpMethodName  the HTTP request method(GET,PUT,POST etc) to be used
     * @param queryParameters the query parameters map
     * @param request         the payload to be sent with the request
     * @param header          the header of the solution provider
     * @return response of type AmazonPayResponse
     */
    public AP_AmazonPayResponse callAPI(final URL uri,
                                     final String httpMethodName,
                                     final Map<String, List<String>> queryParameters,
                                     final String request,
                                     final Map<String, String> header) {
        Map<String, String> postSignedHeaders;

        postSignedHeaders = requestSigner.signRequest(uri, httpMethodName, queryParameters, request, header);
        return processRequest(uri, postSignedHeaders, request, httpMethodName);
    }

    /**
     * Helper method to send the request and also retry in case the request is throttled
     *
     * @param uri               the uri to be executed
     * @param postSignedHeaders the signed headers
     * @param payload           the payload to be sent with the request
     * @param httpMethodName    the HTTP request method(GET,PUT,POST etc) to be used
     * @return the AmazonPayResponse
     */
    private AP_AmazonPayResponse processRequest(final URL uri,
                                             final Map<String, String> postSignedHeaders,
                                             final String payload,
                                             final String httpMethodName) {
        List<String> response;
        String rawResponseObject = null;
        JSONParse jsonResponse = null;

        final AP_AmazonPayResponse responseObject = new AP_AmazonPayResponse();
        responseObject.setUrl(uri);
        responseObject.setMethod(httpMethodName);
        responseObject.setRawRequest(payload);
        responseObject.setHeaders(postSignedHeaders);
        try {
            Long millisBefore = System.currentTimeMillis();
            response = sendRequest(uri, postSignedHeaders, payload, httpMethodName);
            Integer statusCode = Integer.valueOf(response.get(AP_ServiceConstants.RESPONSE_STATUS_CODE));
            Integer retry = 0;
            // Check for service errors
            while (AP_ServiceConstants.serviceErrors.containsKey(statusCode) && retry < payConfiguration.getMaxRetries()) {
                retry++;
                //retry request maxRetries number of times
                Long waitTime = AP_Util.getExponentialWaitTime(retry);
                AP_Util.sleep(waitTime);

                response = sendRequest(uri, postSignedHeaders, payload, httpMethodName);
                statusCode = Integer.valueOf(response.get(AP_ServiceConstants.RESPONSE_STATUS_CODE));
            }
            responseObject.setRetries(retry);
            responseObject.setStatus(statusCode);
            responseObject.setDuration(System.currentTimeMillis() - millisBefore);
            if (response.get(AP_ServiceConstants.RESPONSE_STRING) != null) {
                // Converting the response string into a JSONParse
                rawResponseObject = response.get(AP_ServiceConstants.RESPONSE_STRING);
                jsonResponse = new JSONParse(response.get(AP_ServiceConstants.RESPONSE_STRING));
            }
        }
        catch (JSONException e) { throw new AP_AmazonPayClientException(e.getMessage(), e); }
        catch (Exception e) { 
            throw new AP_AmazonPayClientException(e.getMessage(), e);
        }
        responseObject.setResponse(jsonResponse);
        responseObject.setRawResponse(rawResponseObject);
        responseObject.setRequestId(response.get(AP_ServiceConstants.REQUEST_ID));

        return responseObject;
    }

    /**
     * Helper method to post the request
     *
     * @param uri            the uri to be executed
     * @param headers        the signed headers
     * @param payload        the payload ot be sent with the request
     * @param httpMethodName the HTTP request method(GET,PUT,POST etc) to be used
     * @return the response and response code
     */
    private List<String> sendRequest(final URL uri,
                                     final Map<String, String> headers,
                                     final String payload,
                                     final String httpMethodName) {
        return null;
        // final List<String> result = new ArrayList<String>();
        // final StringBuffer response = new StringBuffer();
        // String requestId = null;
        // Integer responseCode = 0;
        // try (final CloseableHttpClient client = Optional.ofNullable(payConfiguration.getProxySettings()).isPresent()
        //         ? APP_Util.getCloseableHttpClientWithProxy(payConfiguration.getProxySettings())
        //             : HttpClients.createDefault()) {
        //     final HttpUriRequest httpUriRequest = AP_Util.getHttpUriRequest(uri, httpMethodName, payload);
        //     for (Map.Entry<String, String> entry : headers.entrySet()) {
        //         httpUriRequest.addHeader(entry.getKey(), entry.getValue());
        //     }
        //     final HttpResponse responses = client.execute(httpUriRequest);
        //     responseCode = responses.getStatusLine().getStatusCode();
        //     if (responseCode < HttpURLConnection.HTTP_BAD_REQUEST) {
        //         requestId = responses.getFirstHeader(AP_ServiceConstants.X_AMZ_PAY_REQUEST_ID).toString();
        //         String inputLine;
        //         try (final BufferedReader in = new BufferedReader(
        //                 new InputStreamReader(responses.getEntity().getContent(), AP_Util.DEFAULT_ENCODING))) {
        //             while ((inputLine = in.readLine()) != null) {
        //                 response.append(inputLine).append(System.lineSeparator());
        //             }
        //         }
        //     } else {
        //         response.append(EntityUtils.toString(responses.getEntity()));
        //     }
        // } catch (IOException exception) { throw new AP_AmazonPayClientException(exception.getMessage(), exception); }
        // result.add(String.valueOf(responseCode));
        // result.add(response.toString());
        // result.add(requestId);
        // return result;
    }
}