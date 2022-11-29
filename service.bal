import ballerina/http;
//import ballerina/io;

enum LoginType{
    PHONE_PIN, USER_PWD
}

configurable string apiMgrToken = "";
configurable string authUrl = "http://localhost:9091/";
configurable string otpUrl = "http://localhost:9091/";
configurable boolean requiredOtpConfig = false;
configurable boolean requireChangePhoneConfig = false;

boolean requiredOtp = requiredOtpConfig;
boolean requireChangePhone = requireChangePhoneConfig;

service / on new http:Listener(9090) {
    resource function get greeting(@http:Header {name: "App-Name"} string appName) returns string {
        return "Hello, World!";
    }

    resource function get greeting/[string name]() returns string {
        return "Hello " + name;
    }

    resource function post 'init\-link\-account(@http:Payload InitLinkReq req) returns record {|RespondStatus status; InitLinkRes? data;|}|error? {
        http:Client authClient = check new(authUrl);
        map<string> headers = {
            "Accept": "application/json",
            "Authorization": "token " + apiMgrToken
        };
        //call to db to store request record
        //call to external service to validate username and password
        http:Response res = check authClient->post("login",{username:req.login,password:req.key}, headers);
        int phoneNumber = 0;
        var canGenerateOtp = true;
        if requireChangePhone {
            //call to cbs to get CIF phone number
            phoneNumber = 123;
        }

        if requiredOtp {
            canGenerateOtp = false;
            //generate otp
            http:Client otpClient = check new(otpUrl);
            http:Response otpRes = check otpClient->post("/",{username:req.login}, headers);
            if otpRes.statusCode == http:CREATED.status.code
            {
                canGenerateOtp = true;
            }
        }
        
        if res.statusCode == http:CREATED.status.code && canGenerateOtp{
            var result = check res.getJsonPayload();
            // io:println(y.toJsonString());
            return {
                status: {
                    code: 0,
                    errorCode: null,
                    errorMessage: null
                },
                data:{
                    accessToken: check result.accessToken,
                    requireOtp: requiredOtp,
                    requireChangePhone: requireChangePhone,
                    last3DigitsPhone: phoneNumber
                }
            };
        } else {
            return {
                status: {
                    code: 1,
                    errorCode: null,
                    errorMessage: null
                },
                data:null
            };
        }
    }

    resource function post 'verify\-otp(@http:Payload record {|int otpCode;|} req) returns record {|RespondStatus status; OtpRes data;|} |error?{
        //decrypt access token
        var username ="";
        //get login request data for validate
        // hashing login request
        //call to otp service
        http:Client otpClient = check new(otpUrl);
        map<string> headers = {
            "Accept": "application/json",
            "Authorization": "token " + apiMgrToken
        };
        http:Response res = check otpClient->put("/",{username:username,otp:req.otpCode}, headers);
        if res.statusCode == http:CREATED.status.code {
            return {
                status: {
                    code: 0,
                    errorCode: null,
                    errorMessage: null
                },
                data:{
                    isValid: true
                }
            };
        } else {
            return {
                status: {
                    code: 1,
                    errorCode: null,
                    errorMessage: null
                },
                data:{
                    isValid: false
                }
            };
        }
    }

    resource function post 'finish\-link\-account(@http:Payload AccountReq req) returns record {|RespondStatus status; FinishLinkAccountRes data;|} {
        return {
            status: {
                code: 0,
                errorCode: null,
                errorMessage: null
            },
            data:{
                requireChangePassword: true
            }
        };
    }
    resource function post 'authenticate(@http:Payload AuthenticationReq req) returns record {|RespondStatus 'status; AuthenticationRes data;|} |error?{
        //call to db to store request record

        //call to external service to validate username and password
        http:Client authClient = check new(authUrl);
        map<string> headers = {
            "Accept": "application/json",
            "Authorization": "token " + apiMgrToken
        };
        http:Response res = check authClient->post("login",{username:req.login,password:req.key}, headers);
        var result = check res.getJsonPayload();
        return {
            "status": {
                "code": 0,
                "errorCode": null,
                "errorMessage": null
            },
            data:{
                requireChangePassword: check result.requireChangePassword,
                accessToken: check result.accessToken
            }
        };
    }
    resource function post 'unlink\-account(@http:Payload AccountReq req) returns record {|RespondStatus 'status; string data;|} {
        return {
            status: {
                code: 0,
                errorCode: null,
                errorMessage: null
            },
            data: ""
        };
    }
    resource function post 'account\-detail(@http:Payload AccountReq req) returns record {|RespondStatus 'status; Account data;|} {
        return {
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
                balance: 1000.0,
                'limit: {
                    minTrxAmount: 1.0,
                    maxTrxAmount: 100.0
                }
            }
        };
    }
    resource function post 'init\-transaction(@http:Payload TransferReq req) returns record {|RespondStatus 'status; TransferRes data;|} {
        return {
            status: {
                "code": 0,
                "errorCode": null,
                "errorMessage": null
            },
            data:{
                "initRefNumber": "0kElMrPzHeq5luVSvZaFjrB64kiJWiaM",
                "debitAmount": 10.0,
                "debitCcy": "USD",
                "fee": 0,
                "requireOtp": false
            }
        };
    }
    resource function post 'finish\-transaction(@http:Payload ConfirmTransferReq req) returns record {|RespondStatus 'status; ConfirmTransferRes data;|} {
        return {
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
            };
    }
    resource function post 'account\-transactions(@http:Payload TransactionReq req) returns record {|RespondStatus 'status; AccountTransactionsRes data;|} {
        return {
            status: {
            code: 0,
            errorCode: null,
            errorMessage: null
            },
            data: {
                totalElement: 56,
                transactions: [
                        {
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
                        }]
            }
        };
    }
}
