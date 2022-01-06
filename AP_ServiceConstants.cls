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
public class AP_ServiceConstants {
    public static final Map<AP_Region, String> endpointMappings;
    public static final Map<Integer, String> serviceErrors;

    public static final String APPLICATION_LIBRARY_VERSION = '0.0.1';
    public static final String GITHUB_SDK_NAME = 'amazon-pay-api-sdk-apex';
    public static final String AMAZON_PAY_API_VERSION = 'v2';

    public static final String AMAZON_SIGNATURE_ALGORITHM = 'AMZN-PAY-RSASSA-PSS';
    public static final String HASH_ALGORITHM = 'SHA-256';
    public static final String SIGNATURE_ALGORITHM = 'SHA256WithRSA/PSS';
    public static final String MASK_GENERATION_FUNCTION = 'MGF1';

    public static final String PRIVATE_KEY = 'Private Key';
    public static final String REGION = 'Region';
    public static final String PUBLIC_KEY_ID = 'Public key id';
    public static final String REDACTED = 'Redacted';

    public static final String DELIVERY_TRACKERS = AMAZON_PAY_API_VERSION + '/deliveryTrackers';

    public static final String INSTORE_MERCHANT_SCAN = AMAZON_PAY_API_VERSION + '/in-store/merchantScan';
    public static final String INSTORE_REFUND = AMAZON_PAY_API_VERSION + '/in-store/refund';
    public static final String INSTORE_CHARGE = AMAZON_PAY_API_VERSION + '/in-store/charge';

    public static final String CHECKOUT_SESSIONS = AMAZON_PAY_API_VERSION + '/checkoutSessions';
    public static final String CHARGE_PERMISSIONS = AMAZON_PAY_API_VERSION + '/chargePermissions';
    public static final String CHARGES = AMAZON_PAY_API_VERSION + '/charges';
    public static final String REFUNDS = AMAZON_PAY_API_VERSION + '/refunds';

    public static final String BUYERS = AMAZON_PAY_API_VERSION + '/buyers';

    public static final String AUTHORIZATION_TOKEN = AMAZON_PAY_API_VERSION + '/authorizationTokens';

    public static final Integer RESPONSE_STATUS_CODE = 0;
    public static final Integer RESPONSE_STRING = 1;
    public static final Integer REQUEST_ID = 2;

    static {
        Map<AP_Region, String> endpointMappingsMap = new Map<AP_Region, String>();
        endpointMappingsMap.put(AP_Region.EU, 'https://pay-api.amazon.eu');
        endpointMappingsMap.put(AP_Region.JP, 'https://pay-api.amazon.jp');
        endpointMappingsMap.put(AP_Region.NA, 'https://pay-api.amazon.com');
        endpointMappings = endpointMappingsMap;
    }

    static {
        Map<Integer, String> serviceErrorsMap = new Map<Integer, String>();
        serviceErrorsMap.put(500, 'Internal Server Error'); //: HttpURLConnection.HTTP_INTERNAL_ERROR
        serviceErrorsMap.put(503, 'Service Unavailable'); //: HttpURLConnection.HTTP_UNAVAILABLE
        serviceErrorsMap.put(429, 'Too Many Requests');
        serviceErrorsMap.put(502, 'HTTP Bad Gateway'); //: HttpURLConnection.HTTP_BAD_GATEWAY
        serviceErrorsMap.put(504, 'HTTP Gateway Timeout'); //: HttpURLConnection.HTTP_GATEWAY_TIMEOUT
        serviceErrors = serviceErrorsMap;
    }
    public static final String X_AMZ_PAY_REQUEST_ID = 'X-Amz-Pay-Request-Id';
}
