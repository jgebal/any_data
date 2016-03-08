# any_data - Making real use case from Oracle ANYDATA
[![Build Status](https://travis-ci.org/jgebal/anydata_reporter.svg?branch=master)](https://travis-ci.org/jgebal/anydata_reporter)

## Introduction

Some time ago I've seen a PL/SQL procedure containing 300+ lines of code for logging complex type (array/objects) input parameters and ~40 lines of actual code that represented the business logic.
It made me think. Why cant one call a logging framework to log any object as it is?
The thing is, Oracle PL/SQL does not allow passing any data into a logging procedure/function.
We can achieve this partly, but then all user defined object types needs to have some sort of to_string method.
This still does not solve it, as PL/SQL does not allow collection types to have methods.
That seems a bit of an overkill, specially when dealing with legacy projects that already have a set of user defined object types.

That got me thinking about an alternative approach.
Oracle supplies ANYDATA type that allows almost any data to be passed into a plsql routine.
Unfortunately, the ANYDATA type is not user (developer) friendly and i guess this is main reason I've never see it in action actually.

This project is making use of ANYDATA and ANYTYPE to inspect the objects and convert them into a set of predefined objects that can be used to achieve quite interesting things.

Use-case scenarios for using the library.

# Sample use cases

### Logging parameters
TODO add description and examples

### Comparing different data types
TODO add description and examples

# Supported data types

TODO list all supported datatypes

# Known issues and limitations


