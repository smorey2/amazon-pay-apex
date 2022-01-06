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
public class AP_UtilTest {
    @isTest
    public static void urlEncode() {
        Test.startTest();
        String expectedUrl = AP_Util.urlEncode('/live/v2/in-store/refund', true);
        System.assertEquals(expectedUrl, '/live/v2/in-store/refund', 'invalid url');

        String expectedUrl1 = AP_Util.urlEncode('/live/v2/in-store/refund', false);
        System.assertEquals(expectedUrl1, '%2Flive%2Fv2%2Fin-store%2Frefund', 'invalid url');
        Test.stopTest();
    }

    @isTest
    public static void uriWithASpaceTest() {
        Test.startTest();
        String expectedUrl = AP_Util.urlEncode('/ /foo', true);
        Test.stopTest();
        System.assertEquals(expectedUrl, '/%20/foo', 'invalid url');
    }

    @isTest
    public static void uriWithRedundantSlashTest() {
        Test.startTest();
        String expectedUrl = AP_Util.urlEncode('//', true);
        Test.stopTest();
        System.assertEquals(expectedUrl, '/', 'invalid url');
    }

    @isTest
    public static void uriWithRedundantSlashesTest() {
        Test.startTest();
        String expectedUrl = AP_Util.urlEncode('///foo//', true);
        Test.stopTest();
        System.assertEquals(expectedUrl, '/foo/', 'invalid url');
    }

    @isTest
    public static void uriWithUnreservedCharactersTest() {
        Test.startTest();
        String expectedUrl = AP_Util.urlEncode('/-._~0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz', true);
        Test.stopTest();
        System.assertEquals(expectedUrl, '/-._~0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz', 'invalid url');
    }

    @isTest
    public static void uriWithUTF8CharactersTest() {
        Test.startTest();
        String expectedUrl = AP_Util.urlEncode('/\u1234', true);
        Test.stopTest();
        System.assertEquals(expectedUrl, '/%E1%88%B4', 'invalid url');
    }

    @isTest
    public static void lowerCase() {
        String str1 = 'Signature';
        String str2 = 'signature';
        String str3 = 'SIGNATURE';

        Test.startTest();
        System.assertEquals(AP_Util.lowerCase(str1), 'signature', 'invalid signature');
        System.assertEquals(AP_Util.lowerCase(str2), 'signature', 'invalid signature');
        System.assertEquals(AP_Util.lowerCase(str3), 'signature', 'invalid signature');
        Test.stopTest();
    }

    @isTest
    public static void getServiceURI() {
        Test.startTest();
        // Environment is Sandbox
        final AP_PayConfiguration payConfiguration1 = new AP_PayConfiguration()
                .setPublicKeyId('XXXXXXXXXXXXXXXXXXXXXXXX')
                .setRegion(AP_Region.EU)
                .setEnvironment(AP_Environment.SANDBOX);

        URL expectedURL = new URL('https://pay-api.amazon.eu/sandbox/v2/in-store/merchantScan');
        URL actualURL = AP_Util.getServiceURI(payConfiguration1, AP_ServiceConstants.INSTORE_MERCHANT_SCAN);
        System.assertEquals(expectedURL.toExternalForm(), actualURL.toExternalForm(), 'invalid url');

        // Environment is Live
        final AP_PayConfiguration payConfiguration2 = new AP_PayConfiguration()
                .setPublicKeyId('XXXXXXXXXXXXXXXXXXXXXXXX')
                .setRegion(AP_Region.EU)
                .setEnvironment(AP_Environment.LIVE);
        expectedURL = new URL('https://pay-api.amazon.eu/live/v2/in-store/refund');
        actualURL = AP_Util.getServiceURI(payConfiguration2, AP_ServiceConstants.INSTORE_REFUND);
        System.assertEquals(expectedURL.toExternalForm(), actualURL.toExternalForm(), 'invalid url');
        
        // Environment is Null (i.e Default value is live)
        final AP_PayConfiguration payConfiguration3 = new AP_PayConfiguration()
                .setPublicKeyId('XXXXXXXXXXXXXXXXXXXXXXXX')
                .setRegion(AP_Region.EU);
        
        expectedURL = new URL('https://pay-api.amazon.eu/live/v2/in-store/refund');
        actualURL = AP_Util.getServiceURI(payConfiguration3, AP_ServiceConstants.INSTORE_REFUND);
        System.assertEquals(expectedURL.toExternalForm(), actualURL.toExternalForm(), 'invalid url');
        Test.stopTest();
    }
    
    @isTest
    public static void getServiceURIForEnvironmentSpecificKeys() {
        Test.startTest();
        final AP_PayConfiguration payConfiguration1 = new AP_PayConfiguration()
                .setPublicKeyId('LIVE-XXXXXXXXXXXXXXXXXXXXXXXX')
                .setRegion(AP_Region.EU);

        URL expectedURL = new URL('https://pay-api.amazon.eu/v2/in-store/merchantScan');
        URL actualURL = AP_Util.getServiceURI(payConfiguration1, AP_ServiceConstants.INSTORE_MERCHANT_SCAN);
        System.assertEquals(expectedURL.toExternalForm(), actualURL.toExternalForm(), 'invalid url');

        final AP_PayConfiguration payConfiguration2 = new AP_PayConfiguration()
                .setPublicKeyId('SANDBOX-XXXXXXXXXXXXXXXXXXXXXXXX')
                .setRegion(AP_Region.EU);
        
        expectedURL = new URL('https://pay-api.amazon.eu/v2/in-store/refund');

        actualURL = AP_Util.getServiceURI(payConfiguration2, AP_ServiceConstants.INSTORE_REFUND);
        System.assertEquals(expectedURL.toExternalForm(), actualURL.toExternalForm(), 'invalid url');
        Test.stopTest();
    }
    
    @isTest
    public static void updateHeader() {
        Test.startTest();
        AP_PayConfiguration payConfiguration1 = new AP_PayConfiguration()
                .setRegion(AP_Region.EU)
                .setEnvironment(AP_Environment.SANDBOX);

        Map<String, String> header = new Map<String, String>();
        Map<String, String> actualHeader = AP_Util.updateHeader(header);
        System.assert(!actualHeader.isEmpty(), 'header is empty');

        header = AP_Util.updateHeader(null);
        System.assert(header != null, 'header is null');
        Test.stopTest();
    }

    @isTest
    public static void testGetHttpRequestForValidHttpMethod() {
        final List<String> httpMethods = new List<String> {
            'GET',
            'POST',
            'PUT',
            'PATCH',
            'HEAD',
            'DELETE',
            'OPTIONS',
            'TRACE'
        };
        Test.startTest();
        for (String httpMethodName : httpMethods) {
            HttpRequest httpRequest = AP_Util.getHttpRequest(new URL('http://localhost'), httpMethodName, '');
            System.assertEquals(httpMethodName, httpRequest.getMethod(), 'invalid method');
        }
        Test.stopTest();
    }

    @isTest
    public static void testGetHttpRequestForInvalidHttpMethod() {
        Boolean validException;
        Test.startTest();
        try {
            AP_Util.getHttpRequest(new URL('http://localhost'), 'Invalid', '');
        }
        catch (AP_AmazonPayClientException e) { validException = true; }
        catch (Exception e) { validException = false; }
        Test.stopTest();
        System.assert(validException, 'invalid exception'); 
    }
    
    @isTest
    public static void testGetHttpClientWithProxyMethod() {
        final String proxyhost = 'host';
        final Integer proxyPort = 8080;
        final String proxyUser = 'user';
        final Blob proxyPassword = Blob.valueOf('password');
        final AP_ProxySettings proxySettings = new AP_ProxySettings()
                .setProxyHost(proxyhost)
                .setProxyPort(proxyPort)
                .setProxyUser(proxyUser)
                .setProxyPassword(proxyPassword);
        final AP_PayConfiguration payConfiguration = new AP_PayConfiguration()
                .setProxySettings(proxySettings);
        Test.startTest();
        final Http httpClient = AP_Util.getHttpClientWithProxy(proxySettings);
        Test.stopTest();
        // Assertions
        System.assertEquals(proxyhost, payConfiguration.getProxySettings().getProxyHost(), 'proxyhost invalid');
        System.assertEquals(proxyPort, payConfiguration.getProxySettings().getProxyPort(), 'proxyPort invalid');
        System.assertEquals(proxyUser, payConfiguration.getProxySettings().getProxyUser(), 'proxyUser invalid');
        System.assertEquals(proxyPassword, payConfiguration.getProxySettings().getProxyPassword(), 'proxyPassword invalid');
        System.assert(httpClient != null, 'httpClient is null');
    }
}