import ballerina/http;

type Album readonly & record {|
    string id;
    string title;
    string artist;
    decimal price;
|};

enum LoginType{
    PHONE_PIN, USER_PWD
}

type linkRequest record{
    LoginType loginType;
    string login;
    string key;
    string bakongAccId;
    string phoneNumber;
};

type linkRespond record{
    string loginType;
    string login;
    string key;
    string bakongAccId;
    string phoneNumber;
};

listener http:Listener httpListener = new (8080);

service /bakong/api/v1 on httpListener {
    resource function get greeting() returns string {
        return "Hello, World!";
    }

    resource function get greeting/[string name]() returns string {
        return "Hello " + name;
    }

    resource function post 'init\-link\-account(@http:Payload linkRequest req, http:Headers param) returns linkRespond {
        linkRespond res ={
            login: "",
            loginType: "",
            key: "",
            bakongAccId: "",
            phoneNumber: ""
        };
        return res;
    }

    resource function post 'verify\-otp(@http:Payload Album album) returns Album {
        return album;
    }

    resource function post 'finish\-link\-account(@http:Payload Album album) returns Album {
        return album;
    }
    resource function post 'authenticate(@http:Payload Album album) returns Album {
        return album;
    }
    resource function post 'unlink\-account(@http:Payload Album album) returns Album {
        return album;
    }
    resource function post 'account\-detail(@http:Payload Album album) returns Album {
        return album;
    }
    resource function post 'init\-transaction(@http:Payload Album album) returns Album {
        return album;
    }
    resource function post 'finish\-transaction(@http:Payload Album album) returns Album {
        return album;
    }
    resource function post 'account\-transactions(@http:Payload Album album) returns Album {
        return album;
    }
}
