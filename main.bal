import ballerina/http;

type Transaction record {
    string 'type;
    string sourceAcc;
    string destinationAcc;
    float amount;
    string ccy;
    string desc;
    string status;
    string cdtDbtInd;
    string transactionId;
    int transactionDate;
    string transactionHash;
};

enum LoginType{
    PHONE_PIN, USER_PWD
}

type Limit record{
    float minTrxAmount;
    float maxTrxAmount;
};

type Account record{
    string accNumber;
    string accName;
    string accPhone;
    string accType;
    string accCcy;
    string accStatus;
    string kycStatus;
    string country;
    float balance;
    Limit 'limit;
};

listener http:Listener httpListener = new (8080);

service /bakong/api/v1 on httpListener {
    resource function get greeting(@http:Header {name: "App-Name"} string appName) returns string {
        return "Hello, World!";
    }

    resource function get greeting/[string name]() returns string {
        return "Hello " + name;
    }

    resource function post 'init\-link\-account(@http:Payload record {|LoginType loginType;string login;string key;string bakongAccId;string phoneNumber;|} req) 
    returns record {|*http:Created; string accessToken;boolean requireOtp;boolean requireChangePhone;int last3DigitsPhone;|} {
        return {
            accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c",
            requireOtp: false,
            requireChangePhone: true,
            last3DigitsPhone: 123
        };
    }

    resource function post 'verify\-otp(@http:Payload record {|int otpCode;|} req) returns record {|*http:Created; boolean isValid;|} {
        return {
            isValid: true
        };
    }

    resource function post 'finish\-link\-account(@http:Payload record {|string accNumber;|} req) returns record {|*http:Created; boolean requireChangePassword;|} {
        return {
            requireChangePassword: true
        };
    }
    resource function post 'authenticate(@http:Payload record {|string login;string key;LoginType loginType;|} req) returns record {|*http:Created; boolean requireChangePassword;string accessToken;|} {
        return {
            requireChangePassword: true,
            accessToken: ""
        };
    }
    resource function post 'unlink\-account(@http:Payload record {|string accNumber;|} req) returns record {|*http:Created; string data;|} {
        return {
            data: ""
        };
    }
    resource function post 'account\-detail(@http:Payload record {|string accNumber;|} req) returns Account {
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
    resource function post 'init\-transaction(@http:Payload record {|string 'type;string sourceAcc;string destinationAcc;float amount;string ccy;string desc;|} req) 
    returns record {|*http:Created; boolean requireOtp;string initRefNumber;float debitAmount;string debitCcy;float fee;|} {
        return {
            "initRefNumber": "0kElMrPzHeq5luVSvZaFjrB64kiJWiaM",
            "debitAmount": 10.0,
            "debitCcy": "USD",
            "fee": 0,
            "requireOtp": false
        };
    }
    resource function post 'finish\-transaction(@http:Payload record {|string initRefNumber;string otpCode;string 'key;|} req) 
    returns record {|*http:Created; string transactionId;int transactionDate;string transactionHash;|} {
        return {
            "transactionId": "xxxxxxxxx",
            "transactionDate": 1624585517749,
            "transactionHash": "xxxxxxxxx"
            };
    }
    resource function post 'account\-transactions(@http:Payload record {|string accNumber;int page;int 'size;|} req) 
    returns record {|*http:Created; Transaction[] transactions;int totalElement;|} {
        return {
           "totalElement": 56,
           "transactions": [
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
           ]
        };
    }
}
