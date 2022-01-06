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
public class AP_RequestSignerTest {
    private static final AP_SignatureHelper signatureHelper = Mockito.mock(SignatureHelper.class);
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
    private static String authToken;
    private static Map<String, String> header;

    public static void setUp() {
        System.setProperty('os.version', '4.9.93-0.1.ac.178.67.327.metal1.x86_64');
        System.setProperty('java.version', '1.8.0_172');
        System.setProperty('os.name', 'Linux');
        AP_PrivateKey mockKey = Mockito.mock(PrivateKey.class);
        mockStatic(Util.class);
        Mockito.when(Util.buildPrivateKey(Mockito.any(char[].class))).thenReturn(mockKey);
        payConfiguration.setRegion(Region.EU).setPublicKeyId('ADGUHQIH9988').setPrivateKey(new char[] {'p','r','i','v','a','t','e','K','e','y'});
        setUpMockValues();
    }

    private static void setUpMockValues() {
        authToken = 'eyJhbGciOiJIbWFjU0hBMjU2IiwidHlwIjoiSldUIn0=';
        header = new HashMap<String, String>();
        uri = new URL('https://pay-api.amazon.eu/sandbox/v2/in-store/refund');
        payload = 'payload';
        canonicalRequest = 'POST\n' +
                '/sandbox/v2/in-store/refund\n' +
                '\n' +
                'accept:application/json\n' +
                'content-type:application/json\n' +
                'x-amz-pay-date:20180524T223710Z\n' +
                'x-amz-pay-host:pay-api.amazon.eu\n' +
                'x-amz-pay-region:EU\n' +
                '\n' +
                'accept;content-type;x-amz-pay-date;x-amz-pay-host;x-amz-pay-region\n' +
                '81dd99309152d21f2cef921656d3f57830fe9c36fe193af1b62de504e806aceb';

        stringToSign = 'AMZN-PAY-RSASSA-PSS\n' +
                '227f8d4a6974e65a62ebe6648fab8666fe25f10dc2ec41fba9c439e633ba4b94';

        signature = 'c062NjivoUW+TcHegKebFamCX8Cpmpmy6EiPmKwdpEuZZIpOHJYO';

        signedHeaderString = 'accept;content-type;x-amz-pay-date;x-amz-pay-host;x-amz-pay-region';

        authorizationHeader = 'AMZN-PAY-RSASSA-PSS PublicKeyId=ADGUHQIH9988, SignedHeaders=accept;content-type;x-amz-pay-date;x-amz-pay-host;x-amz-pay-region, Signature=c062NjivoUW+TcHegKebFamCX8Cpmpmy6EiPmKwdpEuZZIpOHJYO';

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
        dateHeaderValue.add(Util.getFormattedTimestamp());
        headers.put('x-amz-pay-date', dateHeaderValue);

        List<String> hostHeaderValue = new List<String>();
        hostHeaderValue.add(uri.getHost());
        headers.put('x-amz-pay-host', hostHeaderValue);

        for (String key : header.keySet()) {
            final List<String> authHeaderValue = new List<String>();
            authHeaderValue.add(header.get(key));
            headers.put(key, authHeaderValue);
        }

        PowerMockito.whenNew(SignatureHelper.class).withAnyArguments().thenReturn(signatureHelper);
        Mockito.when(signatureHelper.createCanonicalRequest(Mockito.anyObject(), Mockito.anyString(), Mockito.anyMap(), Mockito.anyString(), Mockito.anyMap())).thenReturn(canonicalRequest);
        Mockito.when(signatureHelper.createStringToSign(Mockito.anyString())).thenReturn(stringToSign);
        Mockito.when(signatureHelper.generateSignature(Mockito.anyObject(), Mockito.anyObject())).thenReturn(signature);
        Mockito.when(signatureHelper.getSignedHeadersString(Mockito.anyMap())).thenReturn(signedHeaderString);
        Mockito.when(signatureHelper.createPreSignedHeaders(Mockito.anyObject(), Mockito.anyMap())).thenReturn(headers);

        postSignedHeadersMap = new Map<String, String>();
        postSignedHeadersMap.put('accept', 'application/json');
        postSignedHeadersMap.put('content-type', 'application/json');
        postSignedHeadersMap.put('x-amz-pay-host', 'pay-api.amazon.eu');
        postSignedHeadersMap.put('x-amz-pay-date', dateHeaderValue.get(0));
        postSignedHeadersMap.put('x-amz-pay-region', 'EU');
        postSignedHeadersMap.put('authorization', authorizationHeader);
        postSignedHeadersMap.put('user-agent', 'amazon-pay-api-sdk-java/' + ServiceConstants.APPLICATION_LIBRARY_VERSION + ' (Java/1.8.0_172; Linux/4.9.93-0.1.ac.178.67.327.metal1.x86_64)');
    }

    @isTest
    public static static void signRequestWithEmptyHeader() {
        setUp();
        AP_RequestSigner requestSigner = new AP_RequestSigner(payConfiguration);
        Map<String, String> header = new HashMap<String, String>();
        Map<String, String> actualHeaders = requestSigner.signRequest(uri, 'POST', parameters, payload, header);
        System.assertEquals(postSignedHeadersMap, actualHeaders);

        payConfiguration.setUserAgentRedaction(true);
        postSignedHeadersMap.put('user-agent', 'amazon-pay-api-sdk-java/' + ServiceConstants.APPLICATION_LIBRARY_VERSION + ' (Java/Redacted; Redacted/Redacted)');
        actualHeaders = requestSigner.signRequest(uri, 'POST', parameters, payload, header);
        System.assertEquals(postSignedHeadersMap, actualHeaders);
    }
}