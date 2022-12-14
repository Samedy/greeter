import ballerina/constraint;

type RespondStatus record {|
    @constraint:Int {
        minValue: 0
    }
    int code;
    string? errorCode;
    string? errorMessage;
|};

type InitLinkReq record {|

    LoginType loginType;

    @constraint:String {
        minLength: 1,
        maxLength: 30
    }string login;

    @constraint:String {
        minLength: 1,
        maxLength: 64
    }string key;

    @constraint:String {
        minLength: 4,
        maxLength: 60
    }string bakongAccId;

    @constraint:String {
        minLength: 1,
        maxLength: 30
    }string phoneNumber;
|};

type InitLinkRes record {|
    string accessToken;
    boolean requireOtp;
    boolean requireChangePhone;
    string last3DigitsPhone?;
|};

type OtpRes record {|
    boolean isValid;
|};

type FinishLinkAccountRes record {|
    boolean requireChangePassword;
|};

type AuthenticationReq record {|
    @constraint:String {
        minLength: 1,
        maxLength: 30
    }
    string login;
    string key;
    LoginType loginType;
|};

type AuthenticationRes record {|
    boolean requireChangePassword;
    string accessToken;
|};

type TransferReq record {|
    @constraint:String {
        minLength: 1,
        maxLength: 30
    }
    string 'type;

    @constraint:String {
        minLength: 1,
        maxLength: 30
    }
    string sourceAcc;

    @constraint:String {
        minLength: 1,
        maxLength: 30
    }
    string destinationAcc;

    @constraint:Number {
        minValueExclusive:0
    }decimal amount;

    @constraint:String {
        minLength: 1,
        maxLength: 10
    }
    string ccy;

    string desc;
|};

type TransferRes record {|
    boolean requireOtp;
    string initRefNumber;
    decimal debitAmount;
    string debitCcy;
    decimal fee;
|};

type ConfirmTransferReq record {|
    @constraint:String {
        minLength: 1
    }
    string initRefNumber;
    @constraint:String {
        minLength: 1
    }
    string otpCode;
    @constraint:String {
        minLength: 1
    }
    string 'key;
|};

type ConfirmTransferRes record {|
    string transactionId;
    int transactionDate;
    string transactionHash;
|};

type TransactionReq record {|
    @constraint:String {
        minLength: 1,
        maxLength: 30
    }
    string accNumber;
    @constraint:Int {
        minValueExclusive: 0
    }
    int page;
    @constraint:Int {
        minValueExclusive: 0
    }
    int 'size;
|};

type Transaction record {|
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
|};

type AccountTransactionsRes record {|
    int totalElement;
    Transaction[] transactions;
|};

type Limit record {|
    decimal minTrxAmount;
    decimal maxTrxAmount;
|};

type AccountReq record {|
    @constraint:String {
        minLength: 1,
        maxLength: 30
    }
    string accNumber;
|};

type Account record {|
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
|};

type LinkRequest record {|
    string id;
    LoginType loginType;
    string login;
    string key;
    string bakongAccId;
    string phoneNumber;
|};

type Customer record {|
    string phoneNumber;
    boolean requireChangePhone;
    boolean requiredOtp;
|};
