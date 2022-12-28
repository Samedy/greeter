import ballerina/test;
import ballerina/http;
import ballerina/jwt;
//import ballerinax/postgresql;
// import ballerina/io;
import ballerina/sql;

http:Client testClient = check new ("http://localhost:9090/");
http:Client authEndpoint = check new ("http://localhost:9091/");
http:Client cbsEndpoint = check new ("http://localhost:9092/cbs");
http:Client otpEndpoint = check new ("http://localhost:9093/");

@test:BeforeSuite
function beforeSuiteFunc() {
    // clientEndpoint=<http:Client>test:mock(http:Client, new MockHttpClient());
    // cbsEndpoint=<http:Client>test:mock(http:Client, new MockHttpClient());
    sql:ExecutionResult result = {affectedRowCount:1,lastInsertId: ()};
    stream<record{}, sql:Error?> rowStream = new();
    // test:prepare(db).when("update").doNothing();
    test:prepare(db).when("query").thenReturn(rowStream);
    test:prepare(db).when("queryRow").thenReturn(result);
    test:prepare(db).when("execute").thenReturn(result);
    // test:prepare(testClient).when("init").doNothing();
    // test:prepare(testClient).getMember("db").thenReturn(db);
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
    [jwt:Header, jwt:Payload] [_, payload] = check jwt:decode(accessToken);
    check fixPayload(payload);
    test:assertTrue(payload["auth"] is json[]);
    test:assertEquals(payload.toJson(), decryptToken);
}

@test:Config {}
function postInitLinkAccount() returns error? {
    http:Response response = check testClient->post("init-link-account",linkReq);
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
            status: {code: 0,errorCode: null,errorMessage: null},
            data:linkRes
        });
}

@test:Config {}
function postInitLinkAccountWithOtp() returns error? {
    customer.requiredOtp=true;
    //linkReq.requiredOtp=true;
    http:Response response = check testClient->post("init-link-account",linkReq);
    test:assertEquals(response.statusCode, 201);
    test:assertTrue(customer.requiredOtp);
    test:assertEquals(response.getJsonPayload(), {
            status: {code: 0,errorCode: null,errorMessage: null},
            data:linkResWithOtp
        });
}

@test:Config {}
function postInitLinkAccountWithInvalidPassword() returns error? {
    http:Response response = check testClient->post("init-link-account",invalidLinkReq,headers = {"Authorization": "Bearer "+accessToken});
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
            status: {code: 1,errorCode: null,errorMessage: null}
        });
}

@test:Config {}
function postVerifyOtp() returns error? {
    http:RequestMessage req = {otpCode: 123};
    http:Response response = check testClient->post("verify-otp",req);
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
            status: {code: 0,errorCode: null,errorMessage: null},
            data:{isValid: true}
        });
}

@test:Config {}
function postVerifyInvalidOtp() returns error? {
    http:RequestMessage req = {otpCode: 111};
    http:Response response = check testClient->post("verify-otp",req);
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
            status: {code: 1,errorCode: null,errorMessage: null},
            data:{isValid: false}
        });
}

@test:Config {}
function postFinishLinkAccount() returns error? {
    json req = {"accNumber": accNumber};
    http:Response response = check testClient->post("finish-link-account",req,headers = {"Authorization": "Bearer "+accessToken});
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
            status: {code: 0,errorCode: null,errorMessage: null},
            data:{requireChangePassword: false}
        });
}

@test:Config {}
function postFinishLinkWrongAccount() returns error? {
    json req = {"accNumber": "xxxxxxxxy"};
    http:Response response = check testClient->post("finish-link-account",req,headers = {"Authorization": "Bearer "+accessToken});
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
            status: {code: 1,errorCode: null,errorMessage: null},
            data:{requireChangePassword: false}
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
function postUnlinkWrongAccount() returns error? {
    json req = {"accNumber": wrongAccountNumber};
    http:Response response = check testClient->post("unlink-account",req,headers = {"Authorization": "Bearer "+accessToken});
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
            status: {code: 1,errorCode: null,errorMessage: null},
            data: ""
        });
}

@test:Config {}
function postUnlinkAccount() returns error? {
    json req = {"accNumber": accNumber};
    http:Response response = check testClient->post("unlink-account",req,headers = {"Authorization": "Bearer "+accessToken});
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
            data:account
        });
}

@test:Config {}
function postWrongAccountDetail() returns error? {
    json req = {"accNumber": wrongAccountNumber};
    http:Response response = check testClient->post("account-detail",req);
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
            status: {
                "code": 1,
                "errorCode": null,
                "errorMessage": null
            }
        });
}

@test:Config {}
function postInitTransaction() returns error? {
    json req = {"type": "string", "sourceAcc": "string","destinationAcc": "string","amount": check txnRes.debitAmount,"ccy": check txnRes.debitCcy,"desc": "string"};
    http:Response response = check testClient->post("init-transaction",req);
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
        status: {
            "code": 0,"errorCode": null,"errorMessage": null
        },
        data:txnRes
    });
}

@test:Config {}
function postInitTransactionLargeAmount() returns error? {
    json req = {"type": "string", "sourceAcc": "string","destinationAcc": "string","amount": 10000,"ccy": check txnRes.debitCcy,"desc": "string"};
    http:Response response = check testClient->post("init-transaction",req);
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
        status: {
            "code": 0,"errorCode": null,"errorMessage": null
        },
        data:largeTxnRes
    });
}

@test:Config {}
function postInitTransactionLargeAmountCannotGenerateOtp() returns error? {
    json req = {"type": "string", "sourceAcc": wrongAccountNumber,"destinationAcc": wrongAccountNumber,"amount": 10000,"ccy": check txnRes.debitCcy,"desc": "string"};
    http:Response response = check testClient->post("init-transaction",req);
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
        status: {
            "code": 1,"errorCode": null,"errorMessage": null
        }
    });
}

@test:Config {}
function postInitInvalidTransaction() returns error? {
    json req = {"type": "string", "sourceAcc": wrongAccountNumber,"destinationAcc": "string","amount": check txnRes.debitAmount,"ccy": check txnRes.debitCcy,"desc": "string"};
    http:Response response = check testClient->post("init-transaction",req);
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
        status: {
            "code": 1,"errorCode": null,"errorMessage": null
        }
    });
}

@test:Config {}
function postFinishTransaction() returns error? {
    json req = {"initRefNumber": "string","key": "string"};
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
function postFinishInvalidTransaction() returns error? {
    json req = {"initRefNumber": noOtpRef,"key": "string"};
    http:Response response = check testClient->post("finish-transaction",req);
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
            status: {
                "code": 1,
                "errorCode": null,
                "errorMessage": null
            }
        });
}

@test:Config {}
function postFinishLargeTransaction() returns error? {
    json req = {"initRefNumber": "string","otpCode": "123456","key": "string"};
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
function postFinishInvalidLargeTransaction() returns error? {
    json req = {"initRefNumber": noOtpRef,"otpCode": "123456","key": "string"};
    http:Response response = check testClient->post("finish-transaction",req);
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
            status: {
                "code": 1,
                "errorCode": null,
                "errorMessage": null
            }
        });
}

@test:Config {}
function postAccountTransactions() returns error? {
    json req = {"accNumber": "string","page": 1,"size": 1};
    http:Response response = check testClient->post("account-transactions",req);
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
            status: {
            code: 0,
            errorCode: null,
            errorMessage: null
            },
            data: {
                totalElement: txn.length(),
                transactions: txn
            }
        });
}

@test:Config {}
function postInvalidAccountTransactions() returns error? {
    json req = {"accNumber": wrongAccountNumber,"page": 1,"size": 1};
    http:Response response = check testClient->post("account-transactions",req);
    test:assertEquals(response.statusCode, 201);
    test:assertEquals(response.getJsonPayload(), {
            status: {
                code: 1,
                errorCode: null,
                errorMessage: null
            },
            data: {
                totalElement: 0,
                transactions: []
            }
        });
}