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
public class AP_CreateStringToSignTest {
    private final static String TEST_FILE = System.getProperty('user.dir') + '/tst/com/amazon/pay/api/testdata.js';
    private final static List<JSONParse> TEST_CASES = new List<JSONParse>();
    private final static PayConfiguration payConfiguration = new PayConfiguration().setRegion(AP_Region.EU).setPublicKeyId('');
    private final static SignatureHelper signatureHelper = new SignatureHelper(payConfiguration);

    public static void readTestCasesFromFile() {
        String fileTestContent = new String(Files.readAllBytes(Paths.get(TEST_FILE)), StandardCharsets.UTF_8);
        JSONArray allTestCases = new JSONArray(fileTestContent);
        for (int i = 0; i < allTestCases.length(); i++)
            TEST_CASES.add((JSONParse) allTestCases.getJSONParse(i));
    }

    @isTest
    public static void ValidateAllTestCases() {
        for (JSONParse testCase : TEST_CASES) {
            String name = testCase.optString('name');
            String method = testCase.optString('method');
            URI uri = new URI(testCase.optString('uri'));
            Map<String, List<String>> queryParams = getParameters((JSONParse) testCase.get('parameters'));
            String payload = testCase.optString('payload');
            Map<String, List<String>> preSignedHeaders = mockedPreSignedHeaders(uri);

            String actualCanonicalRequest = signatureHelper.createCanonicalRequest(uri, method, queryParams, payload, preSignedHeaders);
            String expectedCanonicalRequest = testCase.optString('canonicalRequest');

            String actualStringToSign = signatureHelper.createStringToSign(actualCanonicalRequest);
            String expectedStringToSign = testCase.optString('stringToSign');

            Assert.assertEquals('Test Case Name : ' + name, expectedCanonicalRequest, actualCanonicalRequest);
            Assert.assertEquals('Test Case Name : ' + name, expectedStringToSign, actualStringToSign);
        }
    }

    private static Map<String, List<String>> mockedPreSignedHeaders(URI uri) {
        Map<String, List<String>> headers = new Map<String, List<String>>();

        List<String> acceptHeaderValue = new List<String>();
        acceptHeaderValue.add('application/json');
        headers.put('accept', acceptHeaderValue);

        List<String> contentHeaderValue = new List<String>();
        contentHeaderValue.add('application/json');
        headers.put('content-type', contentHeaderValue);

        List<String> regionHeaderValue = new List<String>();
        regionHeaderValue.add(Region.EU.toString());
        headers.put('x-amz-pay-region', regionHeaderValue);

        List<String> dateHeaderValue = new List<String>();
        dateHeaderValue.add('20180524T223710Z');
        headers.put('x-amz-pay-date', dateHeaderValue);

        List<String> hostHeaderValue = new List<String>();
        hostHeaderValue.add('pay-api.amazon.eu');
        headers.put('x-amz-pay-host', hostHeaderValue);

        return headers;
    }

    private static HashMap<String, List<String>> getParameters(JSONParse jsonObject) {
        Map<String, List<String>> parameters = new Map<String, List<String>>();
        Iterator<String> keys = jsonObject.keys();
        while (keys.hasNext()) {
            String key = keys.next();
            JSONArray vals = jsonObject.getJSONArray((String) key);
            List<String> l = new List<String>();
            for (Integer i = 0; i < vals.length(); i++) {
                l.add(vals.getString(i));
            }
            parameters.put((String) key, l);
        }

        return parameters;
    }
}