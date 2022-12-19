import ballerina/http;

var requireOtp = false;
var requireChangePhone = false;
var accNumber = "xxxxxxxxx";
var wrongAccountNumber = "xxxxxxxxy";
var noOtpRef = "0kElMrPzHeq5luVSvZaFjrB64kiJWia";
json decryptToken = {"sub": "user@domain", "exp": 1624585517749, "iat": 1669967382, "Issuer": "Issuer", "auth": ["can_get_balance", "can_top_up"]};
var accessToken = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1c2VyQGRvbWFpbiIsIklzc3VlciI6Iklzc3VlciIsImF1dGgiOiJbXCJjYW5fZ2V0X2JhbGFuY2VcIiwgXCJjYW5fdG9wX3VwXCJdIiwiZXhwIjoiMTYyNDU4NTUxNzc0OSIsImlhdCI6MTY2OTk2NzM4Mn0.Ixol_dmUxDJm-BBhEsZ5NFMnPGzE1o8TS2J5ZbJv1VM";
json linkReq = {"loginType": "USER_PWD", "login": "string", "key": "string", "bakongAccId": "string", "phoneNumber": "string"};
json invalidLinkReq = {"loginType": "USER_PWD", "login": "string", "key": "invalid", "bakongAccId": "string", "phoneNumber": "string"};
json linkRes = {accessToken: accessToken, requireOtp: false, requireChangePhone: requireChangePhone, last3DigitsPhone: "789"};
json linkResWithOtp = {accessToken: accessToken, requireOtp: true, requireChangePhone: requireChangePhone, last3DigitsPhone: "789"};
Customer customer = {phoneNumber: "123 456 789", requireChangePhone: requireChangePhone, requiredOtp: requireOtp};
json txnRes = {"initRefNumber": "0kElMrPzHeq5luVSvZaFjrB64kiJWiaM", "debitAmount": 10.0d, "debitCcy": "USD", "fee": 0, "requireOtp": false};
json largeTxnRes = {"initRefNumber": "0kElMrPzHeq5luVSvZaFjrB64kiJWiaM", "debitAmount": 10000.0d, "debitCcy": "USD", "fee": 0, "requireOtp": true};
Account account = {
    accNumber: accNumber,
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
    resource function post .(@http:Payload record {string username; string password;} req) returns @tainted http:Response|json|http:ClientError{
        if req.password=="invalid"{
            http:Response response = new;
            response.statusCode = 401;
            return response;
        }
        return {
            accessToken: accessToken,
            requireChangePassword: false
        };
    }
}

service / on otpEP {
    resource function put .(@http:Payload record {|string ref; int otpCode;|} req) returns @tainted http:Response|anydata|http:ClientError {
        if req.otpCode==111{
            http:Response response = new;
            response.statusCode = 400;
            return response;
        }
        http:Response response = new;
        response.statusCode = 200;
        return response;
    }
    resource function post .(@http:Payload record {|string ref;|} req) returns @tainted http:Response|anydata|http:ClientError {
        if req.ref==noOtpRef{
            http:Response response = new;
            response.statusCode = 400;
            return response;
        }
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
    resource function get accounts/[string acc]() returns http:Response|Account|http:ClientError {
        if acc==wrongAccountNumber{
            http:Response response = new;
            response.statusCode = 400;
            return response;
        }
        return account;
    }
    resource function put accounts/[string acc]/status(@http:Payload record {|boolean link;|} req) returns @tainted http:Response|anydata|http:ClientError {
        if acc==wrongAccountNumber{
            http:Response response = new;
            response.statusCode = 400;
            return response;
        }
        http:Response response = new;
        response.statusCode = 200;
        return response;
    }
    resource function get accounts/[string acc]/transactions(int page, int size) returns http:Response|Transaction[] {
        if acc==wrongAccountNumber{
            http:Response response = new;
            response.statusCode = 400;
            return response;
        }
        return txn;
    }
    resource function post transactions(@http:Payload json req) returns http:Response|json {
        if req.sourceAcc==wrongAccountNumber && req.destinationAcc ==wrongAccountNumber{
            return {reference: noOtpRef};
        }
        if req.sourceAcc==wrongAccountNumber{
            http:Response response = new;
            response.statusCode = 400;
            return response;
        }
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