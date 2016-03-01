# any_data - Making real use case from Oracle ANYDATA
[![Build Status](https://travis-ci.org/jgebal/anydata_reporter.svg?branch=master)](https://travis-ci.org/jgebal/anydata_reporter)

## Introduction

Some time ago i've seen a PL/SQL procedure containing 300+ lines of loops for logging complex type (array/objects) input parameters and ~40 lines to "do the job".
It made me think. Why cant er call a logging framework to log any object as it is?
Well, in fact we can, but then any object needs to have some sort of to_string method.
Since we do not get one out of the box from Oracle, the burden of doing it falls on developer.

That got me thinking about an alternative approach.
We could make use of ANYDATA and ANYTYPE to inspect the objects and convert them into string (VARCHAR2/CLOB) representation.
This however has proven to be a challenge bigger than initially considered.
Anyway, after trying out few different approaches and designs i've ended up with what you get.
It seems like a pretty decent utility with nice extensibility and flexibility.

Below you'll find quite a few use-case scenarios where you can benefit from using this library.

# Sample use cases

### Logging parameters
TODO add description and examples

### Comparing different objects data
TODO add description and examples

# Supported data types

TODO list all supported datatypes

# Known issues


