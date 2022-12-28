import ballerina/http;
import ballerina/jwt;
import ballerina/log;
//import ballerina/constraint;

enum LoginType {
    PHONE_PIN, USER_PWD
}

configurable string apiMgrToken = "";
configurable string OtpToken = "";
configurable string cbsToken = "";
configurable string authUrl = "http://localhost:9091/";
configurable string otpUrl = "http://localhost:9093/";
configurable string cbsUrl = "http://localhost:9092/cbs";
configurable string host = ?;
configurable int port = ?;
configurable string user = ?;
configurable string password = ?;
configurable string database = ?;
configurable boolean isUnitTesting = true;
configurable decimal largeAmount = 1000d;

const ACCEPT_HEADER ="application/json";

service / on new http:Listener(9090) {

    resource function get greeting(@http:Header {name: "App-Name"} string appName) returns string {
        return "Hello, World!";
    }

    resource function get greeting/[string name]() returns string |error?{
        return "Hello " + name;
    }

    # Description
    #
    # + req - Parameter Description
    # + return - Return Value Description
    resource function post 'init\-link\-account(@http:Payload InitLinkReq req) returns record {|RespondStatus status; InitLinkRes data?;|}|error? {
        //_ = check constraint:validate(req,InitLinkReq);
        
        //call to db to store request record
        var request = check insertLinkRequest(req);
        boolean requiredOtp = false;
        boolean requireChangePhone = false;
        //call to external service to validate username and password
        http:Client authClient = check new (authUrl);
        
        http:Response res = check authClient->post("login", {username: req.login, password: req.key}, {Accept: ACCEPT_HEADER, Authorization: "token " + apiMgrToken});
        log:printInfo("auth info: "+ res.statusCode.toString(), id = 845315);
        string phoneNumber = "";
        var canGenerateOtp = true;
        //call to cbs to get CIF phone number
        http:Client cbsClient = check new(cbsUrl);
        http:Response cbsRes = check cbsClient->get(string `/customers/${request.login}`, {Accept: ACCEPT_HEADER, Authorization: "Bearer " + OtpToken});
        log:printInfo("service info: "+ check cbsRes.getTextPayload(), id = 845315);
        var cus = check cbsRes.getJsonPayload();
        string phone = check cus.phoneNumber;
        phoneNumber = phone.substring(phone.length()-3);
        requireChangePhone = check cus.requireChangePhone;
        requiredOtp = check cus.requiredOtp;
        if requiredOtp {
            canGenerateOtp = false;
            //generate otp
            http:Client otpClient = check new (otpUrl);
            http:Response otpRes = check otpClient->post("", {ref: req.login}, {Accept: ACCEPT_HEADER, Authorization: "token " + OtpToken});
            
            if otpRes.statusCode == http:OK.status.code
            {
                canGenerateOtp = true;
            }
        }

        if res.statusCode == http:CREATED.status.code && canGenerateOtp {
            var result = check res.getJsonPayload();
            return {
                status: {
                    code: 0,
                    errorCode: null,
                    errorMessage: null
                },
                data: {
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
                data: null
            };
        }
    }

    resource function post 'verify\-otp(@http:Payload record {|int otpCode;|} req) returns record {|RespondStatus status; OtpRes data;|}|error? {
        //decrypt access token
        var username = "";
        //get login request data for validate
        // hashing login request
        //call to otp service
        http:Client otpClient = check new (otpUrl);
        http:Response res = check otpClient->put("", {ref: username, otpCode: req.otpCode}, {Accept: ACCEPT_HEADER, Authorization: "Bearer " + OtpToken});
        
        if res.statusCode == http:OK.status.code {
            return {
                status: {
                    code: 0,
                    errorCode: null,
                    errorMessage: null
                },
                data: {
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
                data: {
                    isValid: false
                }
            };
        }
    }

    resource function post 'finish\-link\-account(@http:Payload AccountReq req,@http:Header {name: "Authorization"} string authorization) returns record {|RespondStatus status; FinishLinkAccountRes data;|}|error {
        string accessToken = authorization.substring(7,authorization.length()-7);
        [jwt:Header, jwt:Payload] [_, payload] = check jwt:decode(accessToken);
        //get all account belong to user id
        http:Client cbsClient = check new(cbsUrl);
        http:Response res = check cbsClient->get(string `/customers/${payload["sub"].toString()}/accounts`, {Accept: ACCEPT_HEADER, Authorization: "Bearer " + cbsToken});
        var accountOwner = false;
        if res.statusCode == http:OK.status.code{
            //cross check each account number
            var result = check res.getJsonPayload();
            Account[] accList = check result.cloneWithType();
            foreach Account a in accList {
                if a.accNumber==req.accNumber{
                    accountOwner = true;
                    break;
                }
            }
        }
        
        //TODO: do we need to add this to customer?
        var requireChangePassword = false;
        if  accountOwner {
            //log the link account -> set flag in CBS to mark
            http:Response _ = check cbsClient->put(string `/accounts/${req.accNumber}/status`, {link: true}, {Accept: ACCEPT_HEADER, Authorization: "Bearer " + cbsToken});
            return {
                status: {
                    code: 0,
                    errorCode: null,
                    errorMessage: null
                },
                data: {
                    requireChangePassword: requireChangePassword
                }
            };
        } else {
            return {
                status: {
                    code: 1,
                    errorCode: null,
                    errorMessage: null
                },
                data: {
                    requireChangePassword: requireChangePassword
                }
            };
        }
        
    }

    resource function post 'authenticate(@http:Payload AuthenticationReq req) returns record {|RespondStatus 'status; AuthenticationRes data;|}|error? {
        //call to db to store request record

        //call to external service to validate username and password
        http:Client authClient = check new (authUrl);
        http:Response res = check authClient->post("login", {username: req.login, password: req.key}, {Accept: ACCEPT_HEADER, Authorization: "Bearer " + OtpToken});
        var result = check res.getJsonPayload();
        return {
            status: {
                code: 0,
                errorCode: null,
                errorMessage: null
            },
            data: {
                requireChangePassword: check result.requireChangePassword,
                accessToken: check result.accessToken
            }
        };
    }

    resource function post 'unlink\-account(@http:Payload AccountReq req,@http:Header {name: "Authorization"} string authorization) returns record {|RespondStatus 'status; string data;|}|error {
        // string accessToken = authorization.substring(7,authorization.length()-7);
        // [jwt:Header, jwt:Payload] [_, payload] = check jwt:decode(accessToken);
        //log the link account -> unset flag in CBS to mark
        http:Client cbsClient = check new(cbsUrl);
        http:Response res = check cbsClient->put(string `/accounts/${req.accNumber}/status`, {link: false}, {Accept: ACCEPT_HEADER, Authorization: "Bearer " + cbsToken});
        
        if res.statusCode == http:OK.status.code{
            // log:printInfo("acc info: "+ a.toString(), id = 845315);
        
            return {
                status: {
                    code: 0,
                    errorCode: null,
                    errorMessage: null
                },
                data: ""
            };
        }
        return {
            status: {
                code: 1,
                errorCode: null,
                errorMessage: null
            },
            data: ""
        };
    }

    resource function post 'account\-detail(@http:Payload AccountReq req) returns record {|RespondStatus 'status; Account data?;|}|error {
        //call to cbs to get txn record
        http:Client cbsClient = check new (cbsUrl);
        http:Response res = check cbsClient->get(string `/accounts/${req.accNumber}`, {Accept: ACCEPT_HEADER, Authorization: "Bearer " + cbsToken});
        if res.statusCode == http:OK.status.code {
            var result = check res.getJsonPayload();
            Account acc = check result.cloneWithType();
            return {
                status: {
                    "code": 0,
                    "errorCode": null,
                    "errorMessage": null
                },
                data: acc
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

    resource function post 'init\-transaction(@http:Payload TransferReq req) returns record {|RespondStatus 'status; TransferRes data?;|}|error {
        //submit txn to cbs to block balance
        var requiredOtp =false;
        if req.amount > largeAmount {
            requiredOtp=true;
        }
        var fee=0d;
        http:Client cbsClient = check new (cbsUrl);
        http:Response res = check cbsClient->post(string `/transactions`, req, {Accept: ACCEPT_HEADER, Authorization: "Bearer " + cbsToken});
        if res.statusCode == http:CREATED.status.code {
            var result = check res.getJsonPayload();
            string refNumber = check result.reference;
            if requiredOtp {
                //generate otp
                http:Client otpClient = check new (otpUrl);
                http:Response otpRes = check otpClient->post("", {ref: refNumber}, {Accept: ACCEPT_HEADER, Authorization: "Bearer " + OtpToken});
                
                if otpRes.statusCode != http:OK.status.code
                {
                    //release block balance when otp generation fail
                    http:Response delres = check cbsClient->delete(string `/transactions/${refNumber}`, {Accept: ACCEPT_HEADER, Authorization: "Bearer " + OtpToken});
                    
                    if delres.statusCode != http:OK.status.code{
                        //report cannot release txn
                    }
                    return {
                        status: {
                            code: 1,
                            errorCode: null,
                            errorMessage: null
                        },
                        data: null
                    };
                }
            }
            return {
                status: {
                    code: 0,
                    errorCode: null,
                    errorMessage: null
                },
                data: {
                    initRefNumber: refNumber,
                    debitAmount: req.amount,
                    debitCcy: req.ccy,
                    fee: fee,
                    requireOtp: requiredOtp
                }
            };
        }else {
            return {
                status: {
                    code: 1,
                    errorCode: null,
                    errorMessage: null
                },
                data: null
            };
        }
    }

    resource function post 'finish\-transaction(@http:Payload ConfirmTransferReq req) returns record {|RespondStatus 'status; ConfirmTransferRes data?;|}|error {
        //TODO: verify pin key
        boolean otpResult = true;
        var requiredOtp =false;
        if req.hasKey("otpCode") {
            requiredOtp=true;
        }
        if requiredOtp {
            http:Client otpClient = check new (otpUrl);
            http:Response res = check otpClient->put("", {ref: req.initRefNumber, otpCode: check int:fromString(req.otpCode ?: "")}, {Accept: ACCEPT_HEADER, Authorization: "Bearer " + OtpToken});
            if res.statusCode != http:OK.status.code {
                otpResult = false;
            }
        }
        //submit txn to cbs to complete the txn
        if otpResult {
            http:Client cbsClient = check new (cbsUrl);
            http:Response res = check cbsClient->put(string `/transactions/${req.initRefNumber}`, {Accept: ACCEPT_HEADER, Authorization: "Bearer " + cbsToken});
            if res.statusCode == http:OK.status.code {
                var result = check res.getJsonPayload();
                return {
                    status: {
                        code: 0,
                        errorCode: null,
                        errorMessage: null
                    },
                    data: {
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
            data: null
        };
    }
    
    resource function post 'account\-transactions(@http:Payload TransactionReq req) returns record {|RespondStatus 'status; AccountTransactionsRes data;|}|error {
        
        //call to cbs to get txn record
        http:Client cbsClient = check new (cbsUrl);
        http:Response res = check cbsClient->get(string `/accounts/${req.accNumber}/transactions?page=${req.page}&size=${req.size}`, {Accept: ACCEPT_HEADER, Authorization: "Bearer " + cbsToken});
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
        else {
            return {
                status: {
                    code: 1,
                    errorCode: null,
                    errorMessage: null
                },
                data: {
                    totalElement: 0,
                    transactions: []
                }
            };
        }
    }
}
