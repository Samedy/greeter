import ballerina/jwt;
function fixPayload(jwt:Payload payload) returns error? {
    var auth =payload["auth"].toString().fromJsonString() ;
    payload["auth"] = check auth;
}
