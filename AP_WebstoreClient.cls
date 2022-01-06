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
public class AP_WebstoreClient extends AP_AmazonPayClient {

    public AP_WebstoreClient(final AP_PayConfiguration payConfiguration) {
        super(payConfiguration);
    }

    /**
     * Get Buyer details can include buyer ID, name, email address, postal code, and country code
     * when used with the Amazon.Pay.renderButton 'SignIn' productType and corresponding signInScopes.
     *
     * @param buyerToken Buyer Token
     * @param header Map&lt;String, String&gt; containining key-value pair of required headers (e.g., keys such as x-amz-pay-idempotency-key, x-amz-pay-authtoken)
     * @return The response from the GetBuyer service API, as returned by Amazon Pay.
     */
    public AP_AmazonPayResponse getBuyer(final String buyerToken, final Map<String, String> header) {
        final URL buyerURI = AP_Util.getServiceURI(payConfiguration, AP_ServiceConstants.BUYERS);
        final URL getBuyerURI = new URL(buyerURI, buyerURI.getPath() + '/' + buyerToken);
        return callAPI(getBuyerURI, 'GET', null, '', header);
    }

    /**
     * Get Buyer details can include buyer ID, name, email address, postal code, and country code
     * when used with the Amazon.Pay.renderButton 'SignIn' productType and corresponding signInScopes.
     *
     * @param buyerToken Buyer Token
     * @return The response from the GetBuyer service API, as returned by Amazon Pay.
     */
    public AP_AmazonPayResponse getBuyer(final String buyerToken) {
        return getBuyer(buyerToken, null);
    }

    /**
     * The CreateCheckoutSession operation is used to create a CheckoutSession for a buyer
     * and pass the Id as part of button click.
     *
     * @param payload JSONParse request body
     * @param header Map&lt;String, String&gt; containining key-value pair of required headers (e.g., keys such as x-amz-pay-idempotency-key, x-amz-pay-authtoken)
     * @return The response from the CreateCheckoutSession service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse createCheckoutSession(final JSONParse payload, final Map<String, String> header) {
        final URL createCheckoutSessionURI = AP_Util.getServiceURI(payConfiguration, AP_ServiceConstants.CHECKOUT_SESSIONS);
        final Map<String, String> headerMap = AP_Util.updateHeader(header);
        return callAPI(createCheckoutSessionURI, 'POST', null, payload.toString(), headerMap);
    }

    /**
     * The CreateCheckoutSession operation is used to create a CheckoutSession for a buyer
     * and pass the Id as part of button click.
     *
     * @param payload JSONParse request body
     * @return The response from the CreateCheckoutSession service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse createCheckoutSession(final JSONParse payload) {
        return createCheckoutSession(payload, null);
    }

    /**
     * The GetCheckoutSession operation is used to get checkout session details that contain
     * all session associated details.
     *
     * @param checkoutSessionId Checkout Session ID provided by Checkout v2 service
     * @param header Map&lt;String, String&gt; containining key-value pair of required headers (e.g., keys such as x-amz-pay-idempotency-key, x-amz-pay-authtoken)
     * @return The response from the GetCheckoutSession service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse getCheckoutSession(final String checkoutSessionId, final Map<String, String> header) {
        final URL checkoutSessionURI = AP_Util.getServiceURI(payConfiguration, AP_ServiceConstants.CHECKOUT_SESSIONS);
        final URL getCheckoutSessionURI = new URL(checkoutSessionURI, checkoutSessionURI.getPath() + '/' + checkoutSessionId);
        return callAPI(getCheckoutSessionURI, 'GET', null, '', header);
    }

    /**
     * The GetCheckoutSession operation is used to get checkout session details that contain
     * all session associated details.
     *
     * @param checkoutSessionId Checkout Session ID provided by Checkout v2 service
     * @return The response from the GetCheckoutSession service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse getCheckoutSession(final String checkoutSessionId) {
        return getCheckoutSession(checkoutSessionId, null);
    }

    /**
     * The UpdateCheckoutSession operation is used to update payment details for a session.
     *
     * @param checkoutSessionId Checkout Session ID provided by Checkout v2 service
     * @param payload JSONParse request body
     * @param header Map&lt;String, String&gt; containining key-value pair of required headers (e.g., keys such as x-amz-pay-idempotency-key, x-amz-pay-authtoken)
     * @return The response from the UpdateCheckoutSession service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse updateCheckoutSession(final String checkoutSessionId, final JSONParse payload, final Map<String, String> header) {
        final URL checkoutSessionURI = AP_Util.getServiceURI(payConfiguration, AP_ServiceConstants.CHECKOUT_SESSIONS);
        final URL updateCheckoutSessionURI = new URL(checkoutSessionURI, checkoutSessionURI.getPath() + '/' + checkoutSessionId);
        return callAPI(updateCheckoutSessionURI, 'PATCH', null, payload.toString(), header);
    }

    /**
     * The UpdateCheckoutSession operation is used to update payment details for a session.
     *
     * @param checkoutSessionId Checkout Session ID provided by Checkout v2 service
     * @param payload JSONParse request body
     * @return The response from the UpdateCheckoutSession service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse updateCheckoutSession(final String checkoutSessionId, final JSONParse payload) {
        return updateCheckoutSession(checkoutSessionId, payload, null);
    }

    /**
     * The CompleteCheckoutSession operation is used to confirm completion of a checkout session
     *
     * @param checkoutSessionId Checkout Session ID provided by Checkout v2 service
     * @param payload JSONParse request body
     * @param header Map&lt;String, String&gt; containining key-value pair of required headers (e.g., keys such as x-amz-pay-idempotency-key, x-amz-pay-authtoken)
     * @return The response from the CompleteCheckoutSession service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse completeCheckoutSession(final String checkoutSessionId, final JSONParse payload, final Map<String, String> header) {
        final URL checkoutSessionURI = AP_Util.getServiceURI(payConfiguration, AP_ServiceConstants.CHECKOUT_SESSIONS);
        final URL completeCheckoutSessionURI = new URL(checkoutSessionURI, checkoutSessionURI.getPath() + '/' + checkoutSessionId + '/' + 'complete');
        return callAPI(completeCheckoutSessionURI, 'POST', null, payload.toString(), header);
    }

    /**
     * The CompleteCheckoutSession operation is used to confirm completion of a checkout session.
     *
     * @param checkoutSessionId Checkout Session ID provided by Checkout v2 service
     * @param payload JSONParse request body
     * @return The response from the CompleteCheckoutSession service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse completeCheckoutSession(final String checkoutSessionId, final JSONParse payload) {
        return completeCheckoutSession(checkoutSessionId, payload, null);
    }

    /**
     * The GetChargePermission operation is used to get the complete details of ChargePermission.
     *
     * @param chargePermissionId Charge Permission ID provided by Checkout v2 service
     * @param header Map&lt;String, String&gt; containining key-value pair of required headers (e.g., keys such as x-amz-pay-idempotency-key, x-amz-pay-authtoken)
     * @return The response from the GetChargePermission service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse getChargePermission(final String chargePermissionId, final Map<String, String> header) {
        final URL chargePermissionURI = AP_Util.getServiceURI(payConfiguration, AP_ServiceConstants.CHARGE_PERMISSIONS);
        final URL getChargePermissionURI = new URL(chargePermissionURI, chargePermissionURI.getPath() + '/' + chargePermissionId);
        return callAPI(getChargePermissionURI, 'GET', null, '', header);
    }

    /**
     * The GetChargePermission operation is used to get the complete details of ChargePermission.
     *
     * @param chargePermissionId Charge Permission ID provided by Checkout v2 service
     * @return The response from the GetChargePermission service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse getChargePermission(final String chargePermissionId) {
        return getChargePermission(chargePermissionId, null);
    }

    /**
     * The UpdateChargePermission operation is used to update the metadata of the ChargePermission.
     *
     * @param chargePermissionId Charge Permission ID provided by Checkout v2 service
     * @param payload JSONParse request body
     * @param header Map&lt;String, String&gt; containining key-value pair of required headers (e.g., keys such as x-amz-pay-idempotency-key, x-amz-pay-authtoken)
     * @return The response from the UpdateChargePermission service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse updateChargePermission(final String chargePermissionId, final JSONParse payload, final Map<String, String> header) {
        final URL chargePermissionURI = AP_Util.getServiceURI(payConfiguration, AP_ServiceConstants.CHARGE_PERMISSIONS);
        final URL updateChargePermissionURI = new URL(chargePermissionURI, chargePermissionURI.getPath() + '/' + chargePermissionId);
        return callAPI(updateChargePermissionURI, 'PATCH', null, payload.toString(), header);
    }

    /**
     * The UpdateChargePermission operation is used to update the metadata of the ChargePermission.
     *
     * @param chargePermissionId Charge Permission ID provided by Checkout v2 service
     * @param payload JSONParse request body
     * @return The response from the UpdateChargePermission service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse updateChargePermission(final String chargePermissionId, final JSONParse payload) {
        return updateChargePermission(chargePermissionId, payload, null);
    }

    /**
     * The CloseChargePermission operation Moves the Charge Permission to a Closed state.
     * No future charges can be made and pending charges will be canceled if you set cancelPendingCharges to true.
     *
     * @param chargePermissionId Charge Permission ID provided by Checkout v2 service
     * @param payload JSONParse request body
     * @param header Map&lt;String, String&gt; containining key-value pair of required headers (e.g., keys such as x-amz-pay-idempotency-key, x-amz-pay-authtoken)
     * @return The response from the CloseChargePermission service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse closeChargePermission(final String chargePermissionId, final JSONParse payload, final Map<String, String> header) {
        final URL chargePermissionURI = AP_Util.getServiceURI(payConfiguration, AP_ServiceConstants.CHARGE_PERMISSIONS);
        final URL closeChargePermissionURI = new URL(chargePermissionURI, chargePermissionURI.getPath() + '/' + chargePermissionId + '/' + 'close');
        return callAPI(closeChargePermissionURI, 'DELETE', null, payload.toString(), header);
    }

    /**
     * The CloseChargePermission operation Moves the Charge Permission to a Closed state.
     * No future charges can be made and pending charges will be canceled if you set cancelPendingCharges to true.
     *
     * @param chargePermissionId Charge Permission ID provided by Checkout v2 service
     * @param payload JSONParse request body
     * @return The response from the CloseChargePermission service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse closeChargePermission(final String chargePermissionId, final JSONParse payload) {
        return closeChargePermission(chargePermissionId, payload, null);
    }

    /**
     * The CreateCharge operation is used to create a charges for a buyer
     * and pass the Id as part of button click.
     *
     * @param payload JSONParse request body
     * @param header Map&lt;String, String&gt; containining key-value pair of required headers (e.g., keys such as x-amz-pay-idempotency-key, x-amz-pay-authtoken)
     * @return The response from the CreateCharge service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse createCharge(final JSONParse payload, final Map<String, String> header) {
        final URL createChargesURI = AP_Util.getServiceURI(payConfiguration, AP_ServiceConstants.CHARGES);
        final Map<String, String> headerMap = AP_Util.updateHeader(header);
        return callAPI(createChargesURI, 'POST', null, payload.toString(), headerMap);
    }

    /**
     * The CreateCharge operation is used to create a charges for a buyer
     * and pass the Id as part of button click.
     *
     * @param payload JSONParse request body
     * @return The response from the CreateCharge service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse createCharge(final JSONParse payload) {
        return createCharge(payload, null);
    }

    /**
     * The getCharge operation is used to get charges details that contain
     *
     * @param chargeId Charge ID provided by Checkout v2 service
     * @param header Map&lt;String, String&gt; containining key-value pair of required headers (e.g., keys such as x-amz-pay-idempotency-key, x-amz-pay-authtoken)
     * @return The response from the getCharge service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse getCharge(final String chargeId, final Map<String, String> header) {
        final URL chargesURI = AP_Util.getServiceURI(payConfiguration, AP_ServiceConstants.CHARGES);
        final URL getChargeURI = new URL(chargesURI, chargesURI.getPath() + '/' + chargeId);
        return callAPI(getChargeURI, 'GET', null, '', header);
    }

    /**
     * The getCharge operation is used to get charges details that contain
     *
     * @param chargeId Charge ID provided by Checkout v2 service
     * @return The response from the getCharge service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse getCharge(final String chargeId) {
        return getCharge(chargeId, null);
    }

    /**
     * The CaptureCharge operation is used to create a charges for a buyer
     * and pass the Id as part of button click.
     *
     * @param chargeId Charge ID provided by Checkout v2 service
     * @param payload JSONParse request body
     * @param header Map&lt;String, String&gt; containining key-value pair of required headers (e.g., keys such as x-amz-pay-idempotency-key, x-amz-pay-authtoken)
     * @return The response from the CaptureCharge service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse captureCharge(final String chargeId, final JSONParse payload, final Map<String, String> header) {
        final URL chargesURI = AP_Util.getServiceURI(payConfiguration, AP_ServiceConstants.CHARGES);
        final URL captureChargeURI = new URL(chargesURI, chargesURI.getPath() + '/' + chargeId + '/' + 'capture');
        final Map<String, String> headerMap = AP_Util.updateHeader(header);
        return callAPI(captureChargeURI, 'POST', null, payload.toString(), headerMap);
    }

    /**
     * The CaptureCharge operation is used to create a charges for a buyer
     * and pass the Id as part of button click.
     *
     * @param chargeId Charge ID provided by Checkout v2 service
     * @param payload JSONParse request body
     * @return The response from the CaptureCharge service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse captureCharge(final String chargeId, final JSONParse payload) {
        return captureCharge(chargeId, payload, null);
    }

    /**
     * The cancelCharge operation is used to cancel Charges.
     *
     * @param chargeId Charge ID provided by Checkout v2 service
     * @param payload JSONParse request body
     * @param header Map&lt;String, String&gt; containining key-value pair of required headers (e.g., keys such as x-amz-pay-idempotency-key, x-amz-pay-authtoken)
     * @return The response from the cancelCharge service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse cancelCharge(final String chargeId, final JSONParse payload, final Map<String, String> header) {
        final URL chargesURI = AP_Util.getServiceURI(payConfiguration, AP_ServiceConstants.CHARGES);
        final URL cancelChargeURI = new URL(chargesURI, chargesURI.getPath() + '/' + chargeId + '/' + 'cancel');
        return callAPI(cancelChargeURI, 'DELETE', null, payload.toString(), header);
    }

    /**
     * The cancelCharge operation is used to cancel Charges.
     *
     * @param chargeId Charge ID provided by Checkout v2 service
     * @param payload JSONParse request body
     * @return The response from the cancelCharge service API, as
     * returned by Amazon Pay.
     * @throws AmazonPayClientException When an error response is returned by Amazon Pay due to bad request or other issue
     */
    public AP_AmazonPayResponse cancelCharge(final String chargeId, final JSONParse payload) {
        return cancelCharge(chargeId, payload, null);
    }

    /**
     * The CreateRefund operation is used to create a refund for a buyer
     * and pass the Id as part of button click.
     *
     * @param payload JSONParse request body
     * @param header Map&lt;String, String&gt; containining key-value pair of required headers (e.g., keys such as x-amz-pay-idempotency-key, x-amz-pay-authtoken)
     * @return The response from the CreateRefunds service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse createRefund(final JSONParse payload, final Map<String, String> header) {
        final URL createRefundsURI = AP_Util.getServiceURI(payConfiguration, AP_ServiceConstants.REFUNDS);
        final Map<String, String> headerMap = AP_Util.updateHeader(header);
        return callAPI(createRefundsURI, 'POST', null, payload.toString(), headerMap);
    }

    /**
     * The CreateRefund operation is used to create a refund for a buyer
     * and pass the Id as part of button click.
     *
     * @param payload JSONParse request body
     * @return The response from the CreateRefunds service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse createRefund(final JSONParse payload) {
        return createRefund(payload, null);
    }

    /**
     * The getRefund operation is used to get refund details that contain
     *
     * @param refundId Refund ID provided by Checkout v2 service
     * @param header Map&lt;String, String&gt; containining key-value pair of required headers (e.g., keys such as x-amz-pay-idempotency-key, x-amz-pay-authtoken)
     * @return The response from the getRefund service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse getRefund(final String refundId, final Map<String, String> header) {
        final URL refundsURI = AP_Util.getServiceURI(payConfiguration, AP_ServiceConstants.REFUNDS);
        final URL getRefundURI = new URL(refundsURI, refundsURI.getPath() + '/' + refundId + '/');
        return callAPI(getRefundURI, 'GET', null, '', header);
    }

    /**
     * The getRefund operation is used to get refund details that contain
     *
     * @param refundId Refund ID provided by Checkout v2 service
     * @return The response from the getRefund service API, as
     * returned by Amazon Pay.
     */
    public AP_AmazonPayResponse getRefund(final String refundId) {
        return getRefund(refundId, null);
    }
}
