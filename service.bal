import ballerina/http;
//import ballerina/io;

enum LoginType{
    PHONE_PIN, USER_PWD
}

configurable string apiMgrToken = "";
configurable string authUrl = "http://localhost:9091/";
configurable string otpUrl = "http://localhost:9091/";
configurable string cbsUrl = "http://localhost:9091/cbs";
configurable boolean requiredOtpConfig = false;
configurable boolean requireChangePhoneConfig = false;
configurable decimal feeConfig = 0;

boolean requiredOtp = requiredOtpConfig;
boolean requireChangePhone = requireChangePhoneConfig;

readonly & map<string> authHeaders = { Accept: "application/json",Authorization: "token " + apiMgrToken};

readonly & map<string> otpHeaders = {Accept: "application/json",Authorization: "token " + apiMgrToken};

readonly & map<string> cbsHeaders = {Accept: "application/json",Authorization: "token " + apiMgrToken};

isolated map<string> x = {"Accept": "application/json","Authorization": "token " + apiMgrToken};

service / on new http:Listener(9090) {
    resource function get greeting(@http:Header {name: "App-Name"} string appName) returns string {
         lock{ x = {"Accept": "application/json","Authorization": "token " + apiMgrToken};}
        return "Hello, World!";
    }

    resource function get greeting/[string name]() returns string {
        return "Hello " + name;
    }

    resource function post 'init\-link\-account(@http:Payload InitLinkReq req) returns record {|RespondStatus status; InitLinkRes? data;|}|error? {
        http:Client authClient = check new(authUrl);

        //call to db to store request record
        //call to external service to validate username and password
        http:Response res = check authClient->post("login",{username:req.login,password:req.key}, authHeaders);
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
            http:Response otpRes = check otpClient->post("/",{ref:req.login}, otpHeaders);
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

        http:Response res = check otpClient->put("/",{ref:username,otp:req.otpCode}, otpHeaders);
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

    resource function post 'finish\-link\-account(@http:Payload AccountReq req) returns record {|RespondStatus status; FinishLinkAccountRes data;|}|error {
        http:Client cbsClient = check new(cbsUrl);
        lock{http:Response res = check cbsClient->get(string `/${req.accNumber}`, cbsHeaders);}
        //where can i save link account
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
        http:Response res = check authClient->post("login",{username:req.login,password:req.key}, authHeaders);
        var result = check res.getJsonPayload();
        return {
            status: {
                code: 0,
                errorCode: null,
                errorMessage: null
            },
            data:{
                requireChangePassword: check result.requireChangePassword,
                accessToken: check result.accessToken
            }
        };
    }
    resource function post 'unlink\-account(@http:Payload AccountReq req) returns record {|RespondStatus 'status; string data;|} {
        //what can i do to unlink account
        return {
            status: {
                code: 0,
                errorCode: null,
                errorMessage: null
            },
            data: ""
        };
    }
    resource function post 'account\-detail(@http:Payload AccountReq req) returns record {|RespondStatus 'status; Account data?;|}|error {
        //call to cbs to get txn record
        http:Client cbsClient = check new(cbsUrl);
        http:Response res = check cbsClient->get(string `/${req.accNumber}`, cbsHeaders);
        if res.statusCode == http:OK.status.code {
            var result = check res.getJsonPayload();
            Account acc = check result.cloneWithType();
            return {
                status: {
                    "code": 0,
                    "errorCode": null,
                    "errorMessage": null
                },
                data:acc
            };
        }
        return {
            status: {
                code: 1,
                errorCode: null,
                errorMessage: null
            }
        };
    }
    resource function post 'init\-transaction(@http:Payload TransferReq req) returns record {|RespondStatus 'status; TransferRes? data;|} |error{
        //submit txn to cbs to block balance
        http:Client cbsClient = check new(cbsUrl);
        http:Response res = check cbsClient->post(string `/transactions`,{}, cbsHeaders);
        var result = check res.getJsonPayload();
        string refNumber =check result.reference;
        if requiredOtp {
            //generate otp
            http:Client otpClient = check new(otpUrl);
            http:Response otpRes = check otpClient->post("/",{ref:refNumber}, otpHeaders);
            if otpRes.statusCode == http:CREATED.status.code
            {
                return {
                    status: {
                        "code": 0,
                        "errorCode": null,
                        "errorMessage": null
                    },
                    data:{
                        "initRefNumber": refNumber,
                        "debitAmount": req.amount,
                        "debitCcy": req.ccy,
                        "fee": feeConfig,
                        "requireOtp": requiredOtp
                    }
                };
            }else{
                //release block balance when otp generation fail
                res = check cbsClient->delete(string `/transactions/${refNumber}`, cbsHeaders);
                //log to false release
            }
        }
        return {
            status: {
                code: 1,
                errorCode: null,
                errorMessage: null
            },
            data:null
        };
    }
    resource function post 'finish\-transaction(@http:Payload ConfirmTransferReq req) returns record {|RespondStatus 'status; ConfirmTransferRes? data;|}|error {
        boolean otpResult = true;
        if requiredOtp {
            http:Client otpClient = check new(otpUrl);
            http:Response res = check otpClient->put("/",{ref:req.initRefNumber,otp:req.otpCode}, otpHeaders);
            if res.statusCode != http:CREATED.status.code {
                otpResult = false;
            }
        }
        //submit txn to cbs to complete the txn
        if otpResult {
            //call to cbs to get CIF phone number
            http:Client cbsClient = check new(cbsUrl);
            http:Response res = check cbsClient->put(string `/transactions`,{}, cbsHeaders);
            var result = check res.getJsonPayload();
            if res.statusCode == http:OK.status.code {
                return {
                    status: {
                        code: 0,
                        errorCode: null,
                        errorMessage: null
                    },
                    data:{
                        transactionId: check result.reference,
                        transactionDate: check result.transactionDate,
                        transactionHash: check result.transactionHash
                    }
                };
            }
        }
        return {
            status: {
                code: 1,
                errorCode: null,
                errorMessage: null
            },
            data:null
        };
    }
    resource function post 'account\-transactions(@http:Payload TransactionReq req) returns record {|RespondStatus 'status; AccountTransactionsRes data;|} |error{
        //validate request
        var emp = {
                status: {
                code: 1,
                errorCode: null,
                errorMessage: "invalid"
                },
                data: {
                    totalElement: 0,
                    transactions: []
                }
            };
        if req.size >100 || req.page<1 {
            return emp;
        }
        else{
            //call to cbs to get txn record
            http:Client cbsClient = check new(cbsUrl);
            http:Response res = check cbsClient->get(string `/${req.accNumber}/transactions?page=${req.page}&size=${req.size}`, cbsHeaders);
            if res.statusCode == http:OK.status.code {
                var result = check res.getJsonPayload();
                Transaction[] txnList = check result.cloneWithType();
                return {
                    status: {
                        code: 0,
                        errorCode: null,
                        errorMessage: null
                    },
                    data: {
                        totalElement: txnList.length(),
                        transactions: txnList
                    }
                };
            }
            else{
                return emp;
            }
        }
    }
}
