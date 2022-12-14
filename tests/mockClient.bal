import ballerina/http;

// import ballerina/io;
// import ballerina/log;
var requireOtp = false;
var requireChangePhone = false;
json decryptToken = {"sub": "user@domain", "exp": 1624585517749, "iat": 1669967382, "Issuer": "Issuer", "auth": ["can_get_balance", "can_top_up"]};
var accessToken = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1c2VyQGRvbWFpbiIsIklzc3VlciI6Iklzc3VlciIsImF1dGgiOiJbXCJjYW5fZ2V0X2JhbGFuY2VcIiwgXCJjYW5fdG9wX3VwXCJdIiwiZXhwIjoiMTYyNDU4NTUxNzc0OSIsImlhdCI6MTY2OTk2NzM4Mn0.Ixol_dmUxDJm-BBhEsZ5NFMnPGzE1o8TS2J5ZbJv1VM";
json linkReq = {"loginType": "USER_PWD", "login": "string", "key": "string", "bakongAccId": "string", "phoneNumber": "string"};
json linkRes = {accessToken: accessToken, requireOtp: false, requireChangePhone: requireChangePhone, last3DigitsPhone: "789"};
json linkResWithOtp = {accessToken: accessToken, requireOtp: true, requireChangePhone: requireChangePhone, last3DigitsPhone: "789"};
Customer customer = {phoneNumber: "123 456 789", requireChangePhone: requireChangePhone, requiredOtp: requireOtp};
json txnRes = {"initRefNumber": "0kElMrPzHeq5luVSvZaFjrB64kiJWiaM", "debitAmount": 10.0d, "debitCcy": "USD", "fee": 0, "requireOtp": requireOtp};
Account account = {
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
};
Transaction txn1 = {
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
};
Transaction[] txn = [txn1];

listener http:Listener cbsEP = new (9092);
listener http:Listener otpEP = new (9093);

service /login on probeEP {
    resource function get .() returns json {
        return {
            accessToken: accessToken
        };
    }
    resource function post .() returns json {
        return {
            accessToken: accessToken,
            requireChangePassword: false
        };
    }
}

service / on otpEP {
    resource function put .(@http:Payload record {|string ref; int otpCode;|} req) returns @tainted http:Response|anydata|http:ClientError {
        http:Response response = new;
        response.statusCode = 200;
        return response;
    }
    resource function post .(@http:Payload record {|string ref;|} req) returns @tainted http:Response|anydata|http:ClientError {
        http:Response response = new;
        response.statusCode = 200;
        return response;
    }
}

service /cbs on cbsEP {

    resource function get customers/[string cus]() returns Customer {
        return customer;
    }
    resource function get customers/[string cus]/accounts() returns Account[] {
        return [account];
    }
    resource function get accounts/[string acc]() returns Account {
        return account;
    }
    resource function get accounts/[string acc]/transactions(int page, int size) returns Transaction[] {
        return txn;
    }
    resource function post transactions(@http:Payload json req) returns json {
        // do {
        //     return {reference: check txnRes.initRefNumber};
        // } on fail var e {

        // }
        return {reference: "0kElMrPzHeq5luVSvZaFjrB64kiJWiaM"};
    }
    resource function put transactions(@http:Payload json req) returns record {} {
        return {
            "reference": "xxxxxxxxx",
            "transactionDate": 1624585517749,
            "transactionHash": "xxxxxxxxx"
        };
    }
    resource function delete transactions(@http:Payload json req) returns record {} {
        return {
            "reference": "xxxxxxxxx",
            "transactionDate": 1624585517749,
            "transactionHash": "xxxxxxxxx"
        };
    }
}

// public client class MockHttpClient {

//     remote function get(@untainted string path, map<string|string[]>? headers = (), http:TargetType targetType = http:Response) 
//     returns @tainted http:Response| anydata | http:ClientError {
//         io:println("get path: "+ path);
//         log:printInfo("get path: "+ path, id = 845315);
//         http:Response response = new;
//         response.statusCode = 500;
//         response.setPayload(linkRes);
//         return response;
//     }

//     remote function post(@untainted string path,http:RequestMessage payload, map<string|string[]>? headers = (), string? mediaType=(), http:TargetType targetType = http:Response) 
//     returns @tainted http:Response| anydata | http:ClientError {
//         log:printInfo("post path: "+ path, id = 845315);
//         http:Response response = new;
//         response.statusCode = 500;
//         response.setPayload({
//                 accessToken: accessToken,
//                 requireOtp: false,
//                 requireChangePhone: true,
//                 last3DigitsPhone: 123
//             });
//         return response;
//     }

//     remote function put(@untainted string path,http:RequestMessage payload, map<string|string[]>? headers = (), string? mediaType=(), http:TargetType targetType = http:Response) 
//     returns @tainted http:Response| anydata | http:ClientError {

//         http:Response response = new;
//         response.statusCode = 500;
//         response.setPayload({
//                 accessToken: accessToken,
//                 requireOtp: false,
//                 requireChangePhone: true,
//                 last3DigitsPhone: 123
//             });
//         return response;
//     }
// }