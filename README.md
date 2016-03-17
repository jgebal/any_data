# any_data - Making real use case from Oracle ANYDATA
[![Build Status](https://travis-ci.org/jgebal/any_data.svg?branch=master)](https://travis-ci.org/jgebal/any_data)

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

This project is making use of ANYDATA and ANYTYPE to inspect the objects and convert them into a reportable and comparable structure.

Use-case scenarios for using the library.

# Main Features

* Convert from ANYDATA Oracle datatype into a flexible object structure

* Convert scalar, user defined types and collections into:
    * Multiline string value (for reporting)
    * Collection of string values (for reporting)

* Compare scalar, user defined types and collections for:
    * equality
    * inequality
    * inclusion (collections) - TODO
    * likeness (objects, strings) - TODO
    * regex match (strings) - TODO

* Strong type comparison between type families - it's assumed that type families are not comparable ()apple vs. grape) - stronger than Oracle comparison
    * varchar does not equal number
    * varchar does not equal date
    * raw does not equal varchar

Through 17 years of work with Oracle I've seen so many NVL's that you could probably build a bridge from Dublin to London using printout of those with font size 8.
This project supports a different NULL logic for comparing.
* Generic NULL comparison
    * NULL value compared to NULL value is True
    * non NULL value compared to NULL value is NULL
* Equality comparison
    * NULL == NULL is True
    * NOT NULL == NULL is False



* Simplified type comparison. All types can be compared and comparison returns some result ( without raising runtime or compile time exception )

* Compare cursors with CSV/Collection of objects for likeness -TODO

* Construction of objects from string representation (constructor/json/xml) - TODO

# Sample use cases

The below examples illustrate some of the great thing that can be easily achieved with the framework.

## Logging parameters

Using the framework you can easly obtain string representation of any object either in form of a string value or a collection of strings that you can iterate over or use in SQL query.

### Printing outputs with to_string
Given: I'm connected as user `generic_util`

And: the following user defined types exist
```sql
create or replace type department as object(
   dept_name varchar2(30)
);
/

create or replace type employee as object(
  emp_no    integer,
  emp_name  varchar2(30),
  hire_date date,
  dept      department
);
/

create or replace type employees as table of employee;
/

create or replace type numbers as table of number;
/
```
When: I execute the following PL/SQL block
```sql
--reporting an object as string
declare
   texas_rangers department := department('Texas Rangers');
begin
   dbms_output.put_line(
      any_data_builder.build(
         ANYDATA.convertObject(texas_rangers)
      ).to_string
   );
end;
/
```
Then: I get the following string printed on dbms_output
```
generic_util.department(
   dept_name => 'Texas Rangers'
)
```

When: I execute the following PL/SQL block
```sql
--reporting a collection of objects as string
declare
   texas_rangers department := department('Texas Rangers');
   chuck employee := employee(1, 'Chuck Norris', date '1960-01-01', texas_rangers);
   chucks employees := employees(chuck, chuck);
begin
   dbms_output.put_line(
      any_data_builder.build(
         ANYDATA.convertCollection(chucks)
      ).to_string
   );
end;
/
```
Then: I get the following string printed on dbms_output
```
generic_util.employees(
   generic_util.employee(
      emp_no => 1,
      emp_name => 'Chuck Norris',
      hire_date => to_date( '1960-01-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss' ),
      dept => generic_util.department(
         dept_name => 'Texas Rangers'
      )
   ),
   generic_util.employee(
      emp_no => 1,
      emp_name => 'Chuck Norris',
      hire_date => to_date( '1960-01-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss' ),
      dept => generic_util.department(
         dept_name => 'Texas Rangers'
      )
   )
)
```

When: I execute the following PL/SQL block
```sql
--reporting a collection of primitives as string
declare
   decimals numbers := numbers(1,2,3,4,5);
   floats   numbers := numbers(1.2,0.1234567890123456789012345678912345678901);
begin
   dbms_output.put_line(
      any_data_builder.build(
         ANYDATA.convertCollection(decimals)
      ).to_string
   );
   dbms_output.put_line(
      any_data_builder.build(
         ANYDATA.convertCollection(floats)
      ).to_string
   );
end;
/
```
Then: I get the following string printed on dbms_output
```
generic_util.numbers(
   1,
   2,
   3,
   4,
   5
)
generic_util.numbers(
   1.2,
   .1234567890123456789012345678912345678901
)
```
When: I execute the following PL/SQL block
```sql
--reporting a primitive (not really useful, but still available...)
declare
   a_number number := 1;
   a_string varchar2(30) := 'a string';
begin
   dbms_output.put_line(
      any_data_builder.build(
         ANYDATA.convertNumber(a_number)
      ).to_string
   );
   dbms_output.put_line(
      any_data_builder.build(
         ANYDATA.convertVarchar2(a_string)
      ).to_string
   );
end;
/
```
Then: I get the following string printed on dbms_output
```
1
'a string'
```

### Selecting outputs with to_string_array
Given: I'm connected as user `generic_util`

And: the following user defined types exist
```sql
create or replace type department as object(
   dept_name varchar2(30)
);
/

create or replace type employee as object(
  emp_no    integer,
  emp_name  varchar2(30),
  hire_date date,
  dept      department
);
/

```
When: I execute the following SQL statement
```sql
select *
  from table(
         any_data_builder.build(
            ANYDATA.convertObject(
               employee( 1, 'Chuck Norris', date '1960-01-01', department('Texas Rangers') )
            )
         ).to_string_array()
      )
;
```
Then: I get result set is rows
```
COLUMN_VALUE
---------------------
generic_util.employee(
   emp_no => 1,
   emp_name => 'Chuck Norris',
   hire_date => to_date( '1960-01-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss' ),
   dept => generic_util.department(
      dept_name => 'Texas Rangers'
   )
)
```

### Comparing any data

Using the framework it takes only one line to compare two objects or two collections.
You can even compare 2 objects of different type.

Given: I'm connected as user `generic_util`

And: the following user defined types exist
```sql
create or replace type department as object(
   dept_name varchar2(30)
);
/

create or replace type employee as object(
  emp_no    integer,
  emp_name  varchar2(30),
  hire_date date,
  dept      department
);
/

create or replace type employees as table of employee;
/

```
When: I execute the following PL/SQL block
```sql
declare
   chuck employee := employee(1, 'Chuck Norris', date '1960-01-01', department('Texas Rangers'));
   chucks employees := employees(chuck, chuck);
   results  any_data := any_data_builder.build( ANYDATA.convertCollection( chucks ) );
   expected any_data := any_data_builder.build( ANYDATA.convertObject( chuck ) );
begin
  if expected.eq( results ) then
    dbms_output.put_line( 'OK' );
  else
    dbms_output.put_line( 'Expected: '||expected.to_string() );
    dbms_output.put_line( 'Got: '||results.to_string() );
  end if;
end;
/
```
Then: I get results
```
Expected: generic_util.employee(
   emp_no => 1,
   emp_name => 'Chuck Norris',
   hire_date => to_date( '1960-01-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss' ),
   dept => generic_util.department(
      dept_name => 'Texas Rangers'
   )
)
Got: generic_util.employees(
   generic_util.employee(
      emp_no => 1,
      emp_name => 'Chuck Norris',
      hire_date => to_date( '1960-01-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss' ),
      dept => generic_util.department(
         dept_name => 'Texas Rangers'
      )
   ),
   generic_util.employee(
      emp_no => 1,
      emp_name => 'Chuck Norris',
      hire_date => to_date( '1960-01-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss' ),
      dept => generic_util.department(
         dept_name => 'Texas Rangers'
      )
   )
)
```

# Supported data types

* Numeric
  * BINARY_FLOAT
  * BINARY_DOUBLE
  * NUMBER / INTEGER
* String
  * CHAR
  * VARCHAR
  * VARCHAR2
  * CLOB
* Binary
  * RAW
  * BLOB
* Date
  * DATE
* INTERVAL YEAR TO MONTH
* INTERVAL DAY TO SECOND
* Compound
  * OBJECT
  * COLLECTION


# Type and data comparison rules

TODO

# Comparators

TODO

# Why it's differrent

TODO

# Known issues and limitations

TODO

