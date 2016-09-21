#!/usr/bin/env python
#coding=utf-8
from pyparsing import *
import sys

methodHeader = (Literal("init") | Literal("deinit") | "func" + Word(alphas, alphanums + "_")("methodname"))
method = SkipTo(methodHeader, failOn="}") + methodHeader + Optional(QuotedString("(", endQuoteChar=")"))
clas = "class" + Word(alphanums)("classname") + ":" + "RxTest"
exte = "extension" +  Word(alphanums)("classname")

defn = (clas | exte) + "{" + ZeroOrMore(Group(method))("methods") + "}"

classes = {}

ast = sys.stdin.read()

for tokens, start, end in defn.scanString(ast):
    if tokens.classname not in classes:
        classes[tokens.classname] = []
    classes[tokens.classname] += [i.methodname for i in tokens.methods if i.methodname.startswith("test")]

print """import XCTest
@testable import RxSwiftTests
"""

for classname, methods in classes.iteritems():
    if len(methods) == 0: continue
    print "extension {} {{".format(classname)
    print "    static var allTests: [(String, ({}) -> () throws -> Void)] {{".format(classname)
    print "        return ["
    for name in methods:
        print "            (\"{0}\", {0}),".format(name)
    print "        ]"
    print "    }"
    print "}"
    print ""

print "XCTMain(["

for classname in classes:
    print "    testCase({}.allTests),".format(classname)

print "])"