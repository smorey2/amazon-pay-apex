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
@isTest
public class AP_SignatureHelperTest {
    private static AP_SignatureHelper spy;
    private static AP_PayConfiguration payConfiguration = new AP_PayConfiguration();
    private static URL uri;
    private static Map<String, List<String>> preSignedHeaders;
    private static Map<String, String> header;

    public class MockProvider implements System.StubProvider {
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, 
            Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames, 
            List<Object> listOfArgs) {
                if (stubbedMethodName == 'createStringToSign') {
                    return 'AMZN-PAY-RSASSA-PSS' + '\n' + '95b0d65e9efb9f0b9e8c2f3b77';
                }
                return null;
        }
    }

    public static void setUp() {
        payConfiguration.setRegion(AP_Region.EU).setPublicKeyId('');
        spy = new AP_SignatureHelper(payConfiguration);
        uri = new URL('https://pay-api.amazon.eu/live/v2/in-store/refund');
        header = new Map<String, String>();
        preSignedHeaders = mockedPreSignedHeaders(uri, header);
    }

    @isTest
    public static void createStringToSign() {
        setUp();
        String canonicalRequest = 'POST\n/live/v2/in-store/refund\naccept:application/json\ncontent-type:application/json\naccept;content-type\n95b0d65e9efb9f0b9e8c2f3b7744628c765477';
        spy = (AP_SignatureHelper)Test.createStub(AP_SignatureHelper.class, new MockProvider());

        Test.startTest();
        String stringToSign = spy.createStringToSign(canonicalRequest);
        String expectedString = 'AMZN-PAY-RSASSA-PSS' + '\n' + '95b0d65e9efb9f0b9e8c2f3b77';
        Test.stopTest();
        System.assertEquals(expectedString, stringToSign, 'invalid value');
    }

    @isTest
    public static void createPreSignedHeaders() {
        setUp();
        Test.startTest();
        Map<String, List<String>> actualHeaders = spy.createPreSignedHeaders(uri, header);
        Test.stopTest();
        System.assertEquals(preSignedHeaders, actualHeaders, 'invalid value');
    }

    @isTest
    public static void getSignedHeadersString() {
        setUp();
        String expectedHeadersString = 'accept;content-type;x-amz-pay-date;x-amz-pay-host;x-amz-pay-region';
        
        Test.startTest();
        String actualHeadersString = spy.getSignedHeadersString(preSignedHeaders);
        Test.stopTest();
        System.assertEquals(expectedHeadersString, actualHeadersString, 'invalid value');
    }

    @isTest
    public static void getCanonicalizedHeaderString() {
        setUp();
        String expectedCanonicalHeaderString = 'accept:application/json\ncontent-type:application/json\nx-amz-pay-date:' + preSignedHeaders.get('x-amz-pay-date').get(0) + '\nx-amz-pay-host:pay-api.amazon.eu\nx-amz-pay-region:EU\n';
        
        Test.startTest();
        String actualCanonicalHeaderString = spy.getCanonicalizedHeaderString(preSignedHeaders);
        Test.stopTest();
        System.assertEquals(expectedCanonicalHeaderString, actualCanonicalHeaderString, 'invalid value');
    }

    @isTest
    public static void getCanonicalizedQueryString() {
        setUp();
        Map<String, List<String>> parametersMap = new Map<String, List<String>>();
        List<String> amount = new List<String>();
        amount.add('100.50');
        parametersMap.put('amount', amount);
        List<String> info = new List<String>();
        info.add('Information about order');
        parametersMap.put('customInformation', info);
        String expectedCanonicalQueryString = 'amount=100.50&customInformation=Information%20about%20order';

        Test.startTest();
        String actualCanonicalQueryString = spy.getCanonicalizedQueryString(parametersMap);
        Test.stopTest();
        System.assertEquals(expectedCanonicalQueryString, actualCanonicalQueryString, 'invalid value');
    }

    private static Map<String, List<String>> mockedPreSignedHeaders(URL uri, Map<String, String> header) {
        Map<String, List<String>> headers = new Map<String, List<String>>();

        List<String> acceptHeaderValue = new List<String>();
        acceptHeaderValue.add('application/json');
        headers.put('accept', acceptHeaderValue);

        List<String> contentHeaderValue = new List<String>();
        contentHeaderValue.add('application/json');
        headers.put('content-type', contentHeaderValue);

        List<String> regionHeaderValue = new List<String>();
        regionHeaderValue.add(payConfiguration.getRegion().name());
        headers.put('x-amz-pay-region', regionHeaderValue);

        List<String> dateHeaderValue = new List<String>();
        dateHeaderValue.add(AP_Util.getFormattedTimestamp());
        headers.put('x-amz-pay-date', dateHeaderValue);

        List<String> hostHeaderValue = new List<String>();
        hostHeaderValue.add(uri.getHost());
        headers.put('x-amz-pay-host', hostHeaderValue);

        if (header.isEmpty() || header == null) {
            return headers;
        }

        for (String key : header.keySet()) {
            final List<String> authHeaderValue = new List<String>();
            authHeaderValue.add(header.get(key));
            headers.put(key, authHeaderValue);
        }
        return headers;
    }
}