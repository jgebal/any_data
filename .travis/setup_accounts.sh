#!/bin/bash

set -ev

"$ORACLE_HOME/bin/sqlplus" -L -S sys/oracle AS SYSDBA <<SQL
@@support/create_user.sql
exit
SQL
