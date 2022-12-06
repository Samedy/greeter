import ballerina/test;
import ballerina/http;
import ballerina/jwt;

http:Client testClient = check new ("http://localhost:9090/");
http:Client clientEndpoint = check new ("http://localhost:9091/");

var accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c";

public client class MockHttpClient {

    remote function get(@untainted string path, map<string|string[]>? headers = (), http:TargetType targetType = http:Response) 
    returns @tainted http:Response| anydata | http:ClientError {

        http:Response response = new;
        response.statusCode = 500;
        response.setPayload({
                accessToken: accessToken,
                requireOtp: false,
                requireChangePhone: true,
                last3DigitsPhone: 123
            });
        return response;
    }
}

@test:Config {}
function get() returns error? {
    http:Response response = check testClient->get("greeting", headers = {"App-Name": "test"});
    test:assertEquals(response.statusCode, 200);

}

@test:Config {}
function getWithName() returns error? {
    http:Response response = check testClient->get("greeting/test");
    test:assertEquals(response.statusCode, 200);
    test:assertEquals(response.getTextPayload(), "Hello test");
}



@test:Config {}
function decodeJwt() returns error? {
    string testtoken = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1c2VyQGRvbWFpbiIsIklzc3VlciI6Iklzc3VlciIsImF1dGgiOiJbXCJjYW5fZ2V0X2JhbGFuY2VcIiwgXCJjYW5fdG9wX3VwXCJdIiwiZXhwIjoiMTYyNDU4NTUxNzc0OSIsImlhdCI6MTY2OTk2NzM4Mn0.Ixol_dmUxDJm-BBhEsZ5NFMnPGzE1o8TS2J5ZbJv1VM";
    [jwt:Header, jwt:Payload] [header, payload] = check jwt:decode(testtoken);
    check fixPayload(payload);
    json x = {"sub":"user@domain","exp":1624585517749,"iat":1669967382,"Issuer":"Issuer","auth":["can_get_balance", "can_top_up"]};
    test:assertTrue(payload["auth"] is json[]);
    test:assertEquals(payload.toJson(), x);
}

@test:Config {}
function postInitLinkAccount() returns error? {
    clientEndpoint=<http:Client>test:mock(http:Client, new MockHttpClient());
    json req = {
        "loginType": "USER_PWD",
        "login": "string",
        "key": "string",
        "bakongAccId": "string",
        "phoneNumber": "string"};
    http:Response response = check testClient->post("init-link-account",req);
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
            status: {code: 0,errorCode: null,errorMessage: null},
            data:{accessToken: accessToken,requireOtp: false,requireChangePhone: true,last3DigitsPhone: 123}
        });
}

@test:Config {}
function postInitLinkAccountWithOtp() returns error? {
    requiredOtp = true;
    clientEndpoint=<http:Client>test:mock(http:Client, new MockHttpClient());
    json req = {
        "loginType": "USER_PWD",
        "login": "string",
        "key": "string",
        "bakongAccId": "string",
        "phoneNumber": "string"};
    http:Response response = check testClient->post("init-link-account",req);
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
            status: {code: 0,errorCode: null,errorMessage: null},
            data:{accessToken: accessToken,requireOtp: true,requireChangePhone: true,last3DigitsPhone: 123}
        });
}

@test:Config {}
function postVerifyOtp() returns error? {
    clientEndpoint=<http:Client>test:mock(http:Client, new MockHttpClient());
    http:RequestMessage req = {"otpCode": 123};
    http:Response response = check testClient->post("verify-otp",req);
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
            status: {code: 0,errorCode: null,errorMessage: null},
            data:{isValid: true}
        });
}

@test:Config {}
function postFinishLinkAccount() returns error? {
    json req = {"accNumber": "string"};
    string testtoken = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1c2VyQGRvbWFpbiIsIklzc3VlciI6Iklzc3VlciIsImF1dGgiOiJbXCJjYW5fZ2V0X2JhbGFuY2VcIiwgXCJjYW5fdG9wX3VwXCJdIiwiZXhwIjoiMTYyNDU4NTUxNzc0OSIsImlhdCI6MTY2OTk2NzM4Mn0.Ixol_dmUxDJm-BBhEsZ5NFMnPGzE1o8TS2J5ZbJv1VM";
    http:Response response = check testClient->post("finish-link-account",req,headers = {"Authorization": testtoken});
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
            status: {code: 0,errorCode: null,errorMessage: null},
            data:{requireChangePassword: true}
        });
}

@test:Config {}
function postAuthenticate() returns error? {
    json req = {"login": "string","key": "string","loginType": "USER_PWD"};
    http:Response response = check testClient->post("authenticate",req);
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
            status: {"code": 0,"errorCode": null,"errorMessage": null},
            data:{requireChangePassword: false,accessToken: accessToken}
        });
}

@test:Config {}
function postUnlinkAccount() returns error? {
    json req = {"accNumber": "string"};
    http:Response response = check testClient->post("unlink-account",req);
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
            status: {code: 0,errorCode: null,errorMessage: null},
            data: ""
        });
}

@test:Config {}
function postAccountDetail() returns error? {
    json req = {"accNumber": "string"};
    http:Response response = check testClient->post("account-detail",req);
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
            status: {
                "code": 0,
                "errorCode": null,
                "errorMessage": null
            },
            data:{
                accNumber: "xxxxxxxxx",
                accName: "Jonh Smith",
                accPhone: "012345678",
                accType: "SAVINGS",
                accCcy: "USD",
                accStatus: "ACTIVE",
                kycStatus: "FULL",
                country: "KH",
                balance: 1000.0d,
                'limit: {
                    minTrxAmount: 1.0d,
                    maxTrxAmount: 100.0d
                }
            }
        });
}

@test:Config {}
function postInitTransaction() returns error? {
    json req = {"type": "string", "sourceAcc": "string","destinationAcc": "string","amount": 0,"ccy": "string","desc": "string"};
    http:Response response = check testClient->post("init-transaction",req);
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
        status: {
            "code": 0,"errorCode": null,"errorMessage": null
        },
        data:{
            "initRefNumber": "0kElMrPzHeq5luVSvZaFjrB64kiJWiaM","debitAmount": 10.0d,"debitCcy": "USD","fee": 0,"requireOtp": false
        }
    });
}

@test:Config {}
function postFinishTransaction() returns error? {
    json req = {"initRefNumber": "string",
  "otpCode": "string",
  "key": "string"};
    http:Response response = check testClient->post("finish-transaction",req);
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
            status: {
                "code": 0,
                "errorCode": null,
                "errorMessage": null
            },
            data:{
                "transactionId": "xxxxxxxxx",
                "transactionDate": 1624585517749,
                "transactionHash": "xxxxxxxxx"
                }
        });
}

@test:Config {}
function postAccountTransactions() returns error? {
    json req = {"accNumber": "string",
  "page": 0,
  "size": 0};
    json[] txn = [{
                        "type": "CASA_TO_WALLET",
                        "sourceAcc": "xxxxxxxxx",
                        "destinationAcc": "user@domain",
                        "amount": 10.0,
                        "ccy": "USD",
                        "desc": "Top up my wallet",
                        "status": "SUCCESS",
                        "cdtDbtInd": "D",
                        "transactionId": "xxxxxxxxx",
                        "transactionDate": 1624585517749,
                        "transactionHash": "xxxxxxxxx"
                        }];
    http:Response response = check testClient->post("account-transactions",req);
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
            status: {
            code: 0,
            errorCode: null,
            errorMessage: null
            },
            data: {
                totalElement: 56,
                transactions: txn
            }
        });
}