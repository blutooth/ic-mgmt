#!/bin/bash

set -e

$(vessel bin)/moc $(vessel sources) ../src/mgmt.mo
$(vessel bin)/moc $(vessel sources) -wasi-system-api test.mo
wasmtime test.wasm
