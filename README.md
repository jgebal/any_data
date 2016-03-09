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

## Logging parameters

### Printing outputs with to_string
Given the following user defined types exist
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
When I execute the following PL/SQL block
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
Then I get the following string printed on dbms_output
```
GENERIC_UTIL.DEPARTMENT(
   DEPT_NAME => 'Texas Rangers'
)
```

When I execute the following PL/SQL block
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
Then I get the following string printed on dbms_output
```
GENERIC_UTIL.EMPLOYEES(
   GENERIC_UTIL.EMPLOYEE(
      EMP_NO => 1,
      EMP_NAME => 'Chuck Norris',
      HIRE_DATE => 1960-01-01 00:00:00,
      DEPT => GENERIC_UTIL.DEPARTMENT(
         DEPT_NAME => 'Texas Rangers'
      )
   ),
   GENERIC_UTIL.EMPLOYEE(
      EMP_NO => 1,
      EMP_NAME => 'Chuck Norris',
      HIRE_DATE => 1960-01-01 00:00:00,
      DEPT => GENERIC_UTIL.DEPARTMENT(
         DEPT_NAME => 'Texas Rangers'
      )
   )
)
```

When I execute the following PL/SQL block
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
Then I get the following string printed on dbms_output
```
GENERIC_UTIL.NUMBERS(
   1,
   2,
   3,
   4,
   5
)
GENERIC_UTIL.NUMBERS(
   1.2,
   .1234567890123456789012345678912345678901
)
```
When I execute the following PL/SQL block
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
Then I get the following string printed on dbms_output
```
1
'a string'
```

### Selecting outputs with to_string_array
Given the following user defined types exist
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
When I execute the following SQL statement
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
Then I get result set is rows
```
COLUMN_VALUE
GENERIC_UTIL.EMPLOYEE(
   EMP_NO => 1,
   EMP_NAME => 'Chuck Norris',
   HIRE_DATE => 1960-01-01 00:00:00,
   DEPT => GENERIC_UTIL.DEPARTMENT(
      DEPT_NAME => 'Texas Rangers'
   )
)
```

### Comparing any data
Given the following user defined types exist
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
When I execute the following PL/SQL block
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
Then I get results
```
Expected: GENERIC_UTIL.EMPLOYEE(
   EMP_NO => 1,
   EMP_NAME => 'Chuck Norris',
   HIRE_DATE => 1960-01-01 00:00:00,
   DEPT => GENERIC_UTIL.DEPARTMENT(
      DEPT_NAME => 'Texas Rangers'
   )
)
Got: GENERIC_UTIL.EMPLOYEES(
   GENERIC_UTIL.EMPLOYEE(
      EMP_NO => 1,
      EMP_NAME => 'Chuck Norris',
      HIRE_DATE => 1960-01-01 00:00:00,
      DEPT => GENERIC_UTIL.DEPARTMENT(
         DEPT_NAME => 'Texas Rangers'
      )
   ),
   GENERIC_UTIL.EMPLOYEE(
      EMP_NO => 1,
      EMP_NAME => 'Chuck Norris',
      HIRE_DATE => 1960-01-01 00:00:00,
      DEPT => GENERIC_UTIL.DEPARTMENT(
         DEPT_NAME => 'Texas Rangers'
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

# Known issues and limitations

TODO

