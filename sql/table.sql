DROP TABLE IF EXISTS public."Requests";

CREATE TABLE IF NOT EXISTS public."Requests"
(
    id uuid NOT NULL,
    loginType varchar(100) not null,
    "login" varchar(100) not null,
    bakongAccId varchar(100) not null,
    phoneNumber varchar(100) not null,
    CONSTRAINT "Requests_pk" PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public."Requests"
    OWNER to test;