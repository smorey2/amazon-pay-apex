/**
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the 'License').
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the 'license' file accompanying this file. This file is distributed
 * on an 'AS IS' BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */
public class AP_AmazonPayResponse {
    private URL url;
    private String method;
    private String rawRequest;
    private JSONParse response;
    private String rawResponse;
    private String requestId;
    private Integer status;
    private Integer retries;
    private Long duration;
    private Map<String, String> headers;

    /**
     * @return Returns the url of the API request
     */
    public URL getUrl() {
        return url;
    }

    /**
     * @param url is the Request url of type URL
     */
    public void setUrl(final URL url) {
        this.url = url;
    }

    /**
     * @return Returns the HTTP Method type
     */
    public String getMethod() {
        return method;
    }

    /**
     * @param method is the HTTP method invoked
     */
    public void setMethod(final String method) {
        this.method = method;
    }

    /**
     * @return Returns the Request payload
     */
    public String getRawRequest() {
        return rawRequest;
    }

    /**
     * @param rawRequest is the Request payload
     */
    public void setRawRequest(final String rawRequest) {
        this.rawRequest = rawRequest;
    }

    /**
     * @return Returns the JSON Response from AmazonPayResponse
     */
    public JSONParse getResponse() {
        return response;
    }

    /**
     * @param response is Response from API call of type JSON
     */
    public void setResponse(final JSONParse response) {
        this.response = response;
    }

    /**
     * @return Returns the Raw Response from the API call
     */
    public String getRawResponse() {
        return rawResponse;
    }

    /**
     * @param rawResponse is the Raw Response returned from API call
     */
    public void setRawResponse(final String rawResponse) {
        this.rawResponse = rawResponse;
    }

    /**
     * @return Returns the request id from the Amazon Pay Response
     */
    public String getRequestId() {
        return requestId;
    }

    /**
     * @param requestId is the Request Id from API call
     */
    public void setRequestId(final String requestId) {
        this.requestId = requestId;
    }

    /**
     * @return Returns the Http Status Code from the response
     */
    public Integer getStatus() {
        return status;
    }

    /**
     * @param status Http Status Code of type Integer
     */
    public void setStatus(final Integer status) {
        this.status = status;
    }

    /**
     * @return Returns no. of retries to run the request
     */
    public Integer getRetries() {
        return retries;
    }

    /**
     * @param retries no. of retries to run the request
     */
    public void setRetries(final Integer retries) {
        this.retries = retries;
    }

    /**
     * @return Returns the time taken to run the request in milliseconds
     */
    public Long getDuration() {
        return duration;
    }

    /**
     * @param duration the time taken to run the request in milliseconds
     */
    public void setDuration(final Long duration) {
        this.duration = duration;
    }

    /**
     * @return Returns the headers provided to the request
     */
    public Map<String, String> getHeaders() {
        return headers;
    }

    /**
     * @param headers the headers provided to the request
     */
    public void setHeaders(final Map<String, String> headers) {
        this.headers = headers;
    }

    /**
     * @return Returns Boolean response
     */
    public Boolean isSuccess() {
        // HttpURLConnection.HTTP_OK || HttpURLConnection.HTTP_CREATED || HttpURLConnection.HTTP_ACCEPTED
        return status == 200 || status == 201 || status == 202;
    }

    /**
     * @return Provide troubleshooting information to developer in easy to read form
     */
    public override String toString() {
        return 'AmazonPayResponse{'
                + 'status=' + status
                + ', success=' + isSuccess()
                + ', requestId=' + requestId
                + ', duration=' + duration
                + ', retries=' + retries
                + ', method=' + method
                + ', url= ' + url
                + ', headers=' + headers
                + ', rawRequest=' + rawRequest
                + ', rawResponse=' + rawResponse + '}';
    }

}
