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
public class AP_InstoreClient extends AP_AmazonPayClient {

    public AP_InstoreClient(final AP_PayConfiguration payConfiguration) {
        super(payConfiguration);
    }

    /**
     * Helps the solution provider make the merchantScan request with their auth token
     * @param scanRequest is the scan request body
     * @param header consists the authToken of the merchant
     * @return the merchant scan response
     */
    public AP_AmazonPayResponse merchantScan(final JSONParse scanRequest, final Map<String, String> header) {
        final URL scanURI = AP_Util.getServiceURI(payConfiguration, AP_ServiceConstants.INSTORE_MERCHANT_SCAN);
        return callAPI(scanURI, 'POST', null, scanRequest.toString(), header);
    }

    /**
     * Helps the merchant make the merchantScan request
     * @param scanRequest is the scan request body
     * @return the merchant scan response
     */
    public AP_AmazonPayResponse merchantScan(final JSONParse scanRequest) {
        return merchantScan(scanRequest, null);
    }

    /**
     * Helps the solution provider make the charge request with their auth token
     * @param chargeRequest is the charge request body
     * @param header consists the authToken of the merchant
     * @return the charge response
     */
    public AP_AmazonPayResponse charge(final JSONParse chargeRequest, final Map<String, String> header) {
        final URL chargeURI = AP_Util.getServiceURI(payConfiguration, AP_ServiceConstants.INSTORE_CHARGE);
        return callAPI(chargeURI, 'POST', null, chargeRequest.toString(), header);
    }

    /**
     * Helps the merchant make the charge request
     * @param chargeRequest is the charge request body
     * @return the charge response
     */
    public AP_AmazonPayResponse charge(final JSONParse chargeRequest) {
        return charge(chargeRequest, null);
    }

    /**
     * Helps the solution provider make the refund request with their auth token
     * @param refundRequest is the refund request body
     * @param header consists the authToken of the merchant
     * @return the refund response
     */
    public AP_AmazonPayResponse refund(final JSONParse refundRequest, final Map<String, String> header) {
        final URL refundURI = AP_Util.getServiceURI(payConfiguration, AP_ServiceConstants.INSTORE_REFUND);
        return callAPI(refundURI, 'POST', null, refundRequest.toString(), header);
    }

    /**
     * Helps the merchant make the refund request
     * @param refundRequest is the refund request body
     * @return the refund response
     */
    public AP_AmazonPayResponse refund(final JSONParse refundRequest) {
        return refund(refundRequest, null);
    }
}