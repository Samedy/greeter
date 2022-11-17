import ballerina/http;

enum LoginType{
    PHONE_PIN, USER_PWD
}

listener http:Listener httpListener = new (9090);

service / on httpListener {
    resource function get greeting(@http:Header {name: "App-Name"} string appName) returns string {
        return "Hello, World!";
    }

    resource function get greeting/[string name]() returns string {
        return "Hello " + name;
    }

    resource function post 'init\-link\-account(@http:Payload InitLinkReq req) returns record {|*http:Created; InitLinkRes data;|} {
        return {
            data:{
                accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c",
                requireOtp: false,
                requireChangePhone: true,
                last3DigitsPhone: 123
            }
        };
    }

    resource function post 'verify\-otp(@http:Payload record {|int otpCode;|} req) returns record {|*http:Created; boolean isValid;|} {
        return {
            isValid: true
        };
    }

    resource function post 'finish\-link\-account(@http:Payload AccountReq req) returns record {|*http:Created; boolean requireChangePassword;|} {
        return {
            requireChangePassword: true
        };
    }
    resource function post 'authenticate(@http:Payload AuthenticationReq req) returns record {|*http:Created; AuthenticationRes data;|} {
        return {
            data:{
                requireChangePassword: true,
                accessToken: ""
            }
        };
    }
    resource function post 'unlink\-account(@http:Payload AccountReq req) returns record {|*http:Created; string data;|} {
        return {
            data: ""
        };
    }
    resource function post 'account\-detail(@http:Payload AccountReq req) returns Account {
        return {
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
        };
    }
    resource function post 'init\-transaction(@http:Payload TransferReq req) returns record {|*http:Created; TransferRes data;|} {
        return {
            data:{
                "initRefNumber": "0kElMrPzHeq5luVSvZaFjrB64kiJWiaM",
                "debitAmount": 10.0,
                "debitCcy": "USD",
                "fee": 0,
                "requireOtp": false
            }
        };
    }
    resource function post 'finish\-transaction(@http:Payload ConfirmTransferReq req) returns record {|*http:Created; ConfirmTransferRes data;|} {
        return {
            data:{
                "transactionId": "xxxxxxxxx",
                "transactionDate": 1624585517749,
                "transactionHash": "xxxxxxxxx"
                }
            };
    }
    resource function post 'account\-transactions(@http:Payload TransactionReq req) returns record {|*http:Created; Transaction transactions;int totalElement;|} {
        return {
           "totalElement": 56,
           "transactions": 
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
                }
           
        };
    }
}
