import ballerina/jwt;
import ballerina/sql;
import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;
import ballerina/uuid;
import ballerina/test;

function fixPayload(jwt:Payload payload) returns error? {
    var auth =payload["auth"].toString().fromJsonString() ;
    payload["auth"] = check auth;
}

final postgresql:Client db = isUnitTesting?<postgresql:Client>(test:mock(postgresql:Client)):check new (host, user, password, database, port);

function getLinkRequests(postgresql:Client db) returns LinkRequest[]|error? {
    stream<LinkRequest, sql:Error?> reqStream = db->query(`SELECT * FROM Requests`);
    LinkRequest[]? reqs = check from LinkRequest req in reqStream select req;
    check reqStream.close();
    return reqs;
}

function getLinkRequest(postgresql:Client db,string id) returns LinkRequest|error {
    LinkRequest|sql:Error result = db->queryRow(`SELECT * FROM Requests WHERE id = ${id}`);
    return result;
}

function insertLinkRequest(InitLinkReq req) returns LinkRequest|error {
    string requestId = check uuid:createType5AsString(uuid:NAME_SPACE_DNS, "ballerina.io");
    _ = check db->execute(`INSERT INTO Requests (id, loginType, login, bakongAccId,phoneNumber)
        VALUES (${requestId}, ${req.loginType}, ${req.login}, ${req.bakongAccId}, ${req.phoneNumber});`);
    return {id:requestId,...req};
}