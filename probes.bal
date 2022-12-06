import ballerina/http;

listener http:Listener probeEP = new (9091);

service /probes on probeEP {
    resource function get healthz() returns boolean {
        return true;
    }
    resource function get readyz() returns boolean {
        return true;
    }
}

service /login on probeEP {
    resource function get .() returns json {
        return {
            accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
        };
    }
    resource function post .() returns json {
        return {
            accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c",
            requireChangePassword: false
        };
    }
}

service / on probeEP {
    resource function put .(@http:Payload record {|string ref; int otpCode;|} req) {

    }
    resource function post .(@http:Payload record {|string ref;|} req) {

    }
}

service /cbs on probeEP {
    resource function get [string acc]/transactions(int page, int size) returns Transaction[] {
        Transaction[] arr = [{
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
        return arr;
    }
    resource function get customers/[string cus]() returns Account[]{
        return [];
    }
    resource function get accounts/[string acc]() returns Account{
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
    resource function post transactions(@http:Payload json req) returns record{}{
        return {
                "reference": "xxxxxxxxx",
                "transactionDate": 1624585517749,
                "transactionHash": "xxxxxxxxx"
            };
    }
    resource function put transactions(@http:Payload json req) returns record{}{
        return {
                "reference": "xxxxxxxxx",
                "transactionDate": 1624585517749,
                "transactionHash": "xxxxxxxxx"
            };
    }
    resource function delete transactions(@http:Payload json req) returns record{}{
        return {
                "reference": "xxxxxxxxx",
                "transactionDate": 1624585517749,
                "transactionHash": "xxxxxxxxx"
            };
    }
}
