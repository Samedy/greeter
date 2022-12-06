
type RespondStatus record{
    int code;
    string? errorCode;
    string? errorMessage;
};

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
    int last3DigitsPhone?;
|};

type OtpRes record {boolean isValid;};

type FinishLinkAccountRes record {boolean requireChangePassword;};

type AuthenticationReq record {|string login;string key;LoginType loginType;|};

type AuthenticationRes record {|boolean requireChangePassword;string accessToken;|};

type TransferReq record {|string 'type;string sourceAcc;string destinationAcc;decimal amount;string ccy;string desc;|};

type TransferRes record {boolean requireOtp;string initRefNumber;decimal debitAmount;string debitCcy;decimal fee;};

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
    decimal amount;
    string ccy;
    string desc;
    string status;
    string cdtDbtInd;
    string transactionId;
    int transactionDate;
    string transactionHash;
};

type AccountTransactionsRes record {
    int totalElement;
    Transaction[] transactions;
};

type Limit record{
    decimal minTrxAmount;
    decimal maxTrxAmount;
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
    decimal balance;
    Limit 'limit;
};