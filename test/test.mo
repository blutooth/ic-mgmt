
import M "mo:matchers/Matchers";
import S "mo:matchers/Suite";
import T "mo:matchers/Testable";

import mgmt "../src/mgmt";

let IC = actor "aaaaa-aa" : mgmt.Self;

let suite = S.suite("Test", []);

S.run(suite);
