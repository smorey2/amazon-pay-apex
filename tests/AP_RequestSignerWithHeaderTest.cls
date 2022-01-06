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
//:ref https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_stub_api.htm
@isTest
public class AP_RequestSignerWithHeaderTest {
    private static AP_SignatureHelper signatureHelper;
    private static AP_PayConfiguration payConfiguration = new AP_PayConfiguration();
    private static URL uri;
    private static String payload;
    private static Map<String, List<String>> parameters = new Map<String, List<String>>();
    private static String canonicalRequest;
    private static String stringToSign;
    private static String signature;
    private static String signedHeaderString;
    private static String authorizationHeader;
    private static Map<String, List<String>> headers;
    private static Map<String, String> postSignedHeadersMap;
    private static Map<String, String> postSignedWithHeadersMap;
    private static String authToken;
    private static Map<String, String> header;

    public class MockProvider implements System.StubProvider {
        private String type;
        public MockProvider(String type) {
            this.type = type;
        }
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, 
            Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames, 
            List<Object> listOfArgs) {
                switch on (type) {
                    when 'PrivateKey' { return null; }
                    when 'SignatureHelper' {
                        switch on (stubbedMethodName) {
                            when 'createCanonicalRequest' { return AP_RequestSignerWithHeaderTest.canonicalRequest; }
                            when 'createStringToSign' { return AP_RequestSignerWithHeaderTest.stringToSign; }
                            when 'generateSignature' { return AP_RequestSignerWithHeaderTest.signature; }
                            when 'getSignedHeadersString' { return AP_RequestSignerWithHeaderTest.signedHeaderString; }
                            when 'createPreSignedHeaders' { return AP_RequestSignerWithHeaderTest.headers; }
                        }
                    }
                }
                return null;
        }
    }

    public static void setUp() {
        AP_Util.OS_VERSION = '4.9.93-0.1.ac.178.67.327.metal1.x86_64';
        AP_Util.JAVA_VERSION = '1.8.0_172';
        AP_Util.OS_NAME = 'Linux';
        AP_PayConfiguration.mockPrivateKey = (AP_PrivateKey)Test.createStub(AP_PrivateKey.class, new MockProvider('AP_PrivateKey'));
        payConfiguration.setRegion(AP_Region.NA).setPublicKeyId('ADGUHQIH9988').setPrivateKey(Blob.valueOf('privateKey'));
        setUpMockValues();
    }

    private static void setUpMockValues() {
        authToken = 'eyJhbGciOiJIbWFjU0hBMjU2IiwidHlwIjoiSldUIn0=';
        header = new Map<String, String>();
        header.put('x-amz-pay-idempotency-key', '23GGJHGB668344');

        uri = new URL('https://pay-api.amazon.com/sandbox/v2/refunds');
        payload = 'payload';
        canonicalRequest = 'POST\n' +
                '/sandbox/v2/refunds\n' +
                '\n' +
                'accept:application/json\n' +
                'content-type:application/json\n' +
                'x-amz-pay-date:20190826T184058Z\n' +
                'x-amz-pay-host:pay-api.amazon.com\n' +
                'x-amz-pay-idempotency-key:23GGJHGB668344\n' +
                'x-amz-pay-region:EU\n' +
                '\n' +
                'accept;content-type;x-amz-pay-date;x-amz-pay-host;x-amz-pay-idempotency-key;x-amz-pay-region\n' +
                '81dd99309152d21f2cef921656d3f57830fe9c36fe193af1b62de504e806aceb';

        stringToSign = 'AMZN-PAY-RSASSA-PSS\n' +
                '15322736b7e5a9056411168d070b1f3dcc289c46890692c06f07c62d3ef0721d';

        signature = 'BsnrBn7R4QvpWqPzElKnxK8KLm7BzglICqRsWDcj7okwVpHrpZnoOm4D3v2+naryg2vIzP2iIWvscNm3MbX7vR3nClgcB+vVUQZLEu9yg0IJA4QCiybh9etgLHSRv2jwR9ByFe9U5FMdhr7omDG3Q1lAjvvxiPHt9UtL3h1LJ7rirOuQUWp/zL5QDWsIvTty3zEKksdRJuPeCGwijwo0LPuIf2plZGv9TJ5CJBxssw3+phj5Nvo9HWuzFRkJsC1jgknO0+eSTSn5RM6R2Px0mkz3qbd5ZpSX3tIoK937vkmNZALNm/euqYnIKjviGVuSEDo1ite84foCvSqpTmiVrg==';

        signedHeaderString = 'accept;content-type;x-amz-pay-date;x-amz-pay-host;x-amz-pay-idempotency-key;x-amz-pay-region';

        authorizationHeader = 'AMZN-PAY-RSASSA-PSS PublicKeyId=ADGUHQIH9988, SignedHeaders=accept;content-type;x-amz-pay-date;x-amz-pay-host;x-amz-pay-idempotency-key;x-amz-pay-region, Signature=BsnrBn7R4QvpWqPzElKnxK8KLm7BzglICqRsWDcj7okwVpHrpZnoOm4D3v2+naryg2vIzP2iIWvscNm3MbX7vR3nClgcB+vVUQZLEu9yg0IJA4QCiybh9etgLHSRv2jwR9ByFe9U5FMdhr7omDG3Q1lAjvvxiPHt9UtL3h1LJ7rirOuQUWp/zL5QDWsIvTty3zEKksdRJuPeCGwijwo0LPuIf2plZGv9TJ5CJBxssw3+phj5Nvo9HWuzFRkJsC1jgknO0+eSTSn5RM6R2Px0mkz3qbd5ZpSX3tIoK937vkmNZALNm/euqYnIKjviGVuSEDo1ite84foCvSqpTmiVrg==';

        headers = new Map<String, List<String>>();
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

        for (String key : header.keySet()) {
            final List<String> authHeaderValue = new List<String>();
            authHeaderValue.add(header.get(key));
            headers.put(key, authHeaderValue);
        }

        signatureHelper = (AP_SignatureHelper)Test.createStub(AP_SignatureHelper.class, new MockProvider('SignatureHelper'));

        postSignedWithHeadersMap = new Map<String, String>();
        postSignedWithHeadersMap.put('accept', 'application/json');
        postSignedWithHeadersMap.put('content-type', 'application/json');
        postSignedWithHeadersMap.put('x-amz-pay-host', 'pay-api.amazon.com');
        postSignedWithHeadersMap.put('x-amz-pay-date', dateHeaderValue.get(0));
        postSignedWithHeadersMap.put('x-amz-pay-region', 'NA');
        postSignedWithHeadersMap.put('authorization', authorizationHeader);
        postSignedWithHeadersMap.put('x-amz-pay-idempotency-key', '23GGJHGB668344');
        postSignedWithHeadersMap.put('user-agent', 'amazon-pay-api-sdk-java/' + AP_ServiceConstants.APPLICATION_LIBRARY_VERSION + ' (Java/1.8.0_172; Linux/4.9.93-0.1.ac.178.67.327.metal1.x86_64)');
    }

    @isTest
    public static void signRequestWithHeader() {
        setUp();
        AP_RequestSigner requestSigner = new AP_RequestSigner(payConfiguration);

        Map<String, String> actualHeaders = requestSigner.signRequest(uri, 'POST', parameters, payload, header);
        System.assertEquals(postSignedWithHeadersMap, actualHeaders, 'invalid value');

        payConfiguration.setUserAgentRedaction(true);
        postSignedWithHeadersMap.put('user-agent', 'amazon-pay-api-sdk-java/' + AP_ServiceConstants.APPLICATION_LIBRARY_VERSION + ' (Java/Redacted; Redacted/Redacted)');
        actualHeaders = requestSigner.signRequest(uri, 'POST', parameters, payload, header);
        System.assertEquals(postSignedWithHeadersMap, actualHeaders, 'invalid value');
    }
}