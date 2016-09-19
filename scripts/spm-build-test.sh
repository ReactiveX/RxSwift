#!/bin/bash
swift build --clean && swift build -Xswiftc -D -Xswiftc TRACE_RESOURCES && swift test -Xswiftc -D -Xswiftc TRACE_RESOURCES