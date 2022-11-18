import ballerina/test;
import ballerina/http;

http:Client testClient = check new ("http://localhost:9090/");

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
function postInitLinkAccount() returns error? {
    json req = {"loginType": "USER_PWD","login": "string","key": "string","bakongAccId": "string","phoneNumber": "string"};
    http:Response response = check testClient->post("init-link-account",req);
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
            status: {code: 0,errorCode: null,errorMessage: null},
            data:{accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c",requireOtp: false,requireChangePhone: true,last3DigitsPhone: 123}
        });
}

@test:Config {}
function postVerifyOtp() returns error? {
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
    http:Response response = check testClient->post("finish-link-account",req);
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
            data:{requireChangePassword: true,accessToken: ""}
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
    json req = {"type": "string",
  "sourceAcc": "string",
  "destinationAcc": "string",
  "amount": 0,
  "ccy": "string",
  "desc": "string"};
    http:Response response = check testClient->post("init-transaction",req);
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
            status: {
                "code": 0,
                "errorCode": null,
                "errorMessage": null
            },
            data:{
                "initRefNumber": "0kElMrPzHeq5luVSvZaFjrB64kiJWiaM",
                "debitAmount": 10.0d,
                "debitCcy": "USD",
                "fee": 0,
                "requireOtp": false
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