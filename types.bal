// import ballerina/http;

type InitLinkReq record {|
    LoginType loginType;
    string login;
    string key;
    string bakongAccId;
    string phoneNumber;
|};

type InitLinkRes record {|
    string accessToken;
    boolean requireOtp;
    boolean requireChangePhone;
    int last3DigitsPhone;
|};

type AuthenticationReq record {|string login;string key;LoginType loginType;|};

type AuthenticationRes record {|boolean requireChangePassword;string accessToken;|};

type TransferReq record {|string 'type;string sourceAcc;string destinationAcc;float amount;string ccy;string desc;|};

type TransferRes record {boolean requireOtp;string initRefNumber;float debitAmount;string debitCcy;float fee;};

type ConfirmTransferReq record {|string initRefNumber;string otpCode;string 'key;|};

type ConfirmTransferRes record {|string transactionId;int transactionDate;string transactionHash;|};

type TransactionReq record {
    string accNumber;
    int page;
    int 'size;
};

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

type Limit record{
    float minTrxAmount;
    float maxTrxAmount;
};

type AccountReq record{
    string accNumber;
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