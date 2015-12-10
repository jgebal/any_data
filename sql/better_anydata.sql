drop type better_anydata force;

/

create type better_anydata as object (
   base_data ANYDATA,
member function getBDouble
      return binary_double,
member function getBfile
      return bfile,
member function getBFloat
      return binary_float,
member function getBlob
      return blob,
member function getChar
      return varchar2,
member function getClob
      return clob,
member function getDate
      return date,
member function getIntervalYM
      return interval year to month,
member function getIntervalDS
      return interval day to second,
member function getNchar
      return nchar,
member function getNClob
      return nclob,
member function getNumber
      return number,
member function getNVarchar2
      return nvarchar2,
member function getRaw
      return raw,
member function getTimestamp
      return timestamp,
member function getTimestampLTZ
      return timestamp with local time zone,
member function getTimestampTZ
      return timestamp with time zone,
member function getVarchar
      return varchar,
member function getVarchar2
      return varchar2,
member function GetCollection( self in out nocopy BETTER_ANYDATA, p_type_info ANYTYPE_INFO )
      return BETTER_ANYDATA,
member function GetObject( self in out nocopy BETTER_ANYDATA, p_type_info ANYTYPE_INFO )
      return BETTER_ANYDATA
);

/

create type body better_anydata as

member function GetCollection( self in out nocopy BETTER_ANYDATA, p_type_info ANYTYPE_INFO )
      return BETTER_ANYDATA is
      v_sql         varchar2(32767);
      v_out_anydata ANYDATA;
      begin
         v_sql := '
        DECLARE
          v_obj ' || p_type_info.get_typename( ) || ';
          v_in_data ANYDATA;
        BEGIN
          v_in_data := :base_data_in;
          IF v_in_data.getTypeName() != ''' || p_type_info.get_typename( ) || ''' THEN
            v_in_data.piecewise();
          END IF;
          IF v_in_data.getCollection( v_obj ) = DBMS_TYPES.NO_DATA THEN
            RAISE NO_DATA_FOUND;
          END IF;
          :base_data_out := v_in_data;
          :v_out_anydata := ANYDATA.convertCollection( v_obj );
        END;';
         execute immediate v_sql using in base_data, out base_data, out v_out_anydata;
         return BETTER_ANYDATA( v_out_anydata );
      end;

member function GetObject( self in out nocopy BETTER_ANYDATA, p_type_info ANYTYPE_INFO )
      return BETTER_ANYDATA is
      v_out_anydata ANYDATA;
      v_sql         varchar2(32767);
      begin
         v_sql := '
      DECLARE
        v_in_data ANYDATA;
        FUNCTION extract_object( p_in_out_data IN OUT NOCOPY ANYDATA) RETURN ' || p_type_info.get_typename( ) || ' IS
          v_obj ' || p_type_info.get_typename( ) || ';
        BEGIN
          IF p_in_out_data.getTypeName() != ''' || p_type_info.get_typename( ) || ''' THEN
            p_in_out_data.piecewise();
          END IF;
          IF p_in_out_data.getObject( v_obj ) = DBMS_TYPES.NO_DATA THEN
            RAISE NO_DATA_FOUND;
          END IF;
          RETURN v_obj;
        END;
       BEGIN
          :v_out_anydata := ANYDATA.convertObject( extract_object( :base_data_in_out ) );
       END;';
         execute immediate v_sql using out v_out_anydata, in OUT base_data;
         return BETTER_ANYDATA( v_out_anydata );
      end;

member function getBDouble
      return binary_double is
      v_result binary_double;
      begin
         if base_data.getBDouble( v_result ) = DBMS_TYPES.NO_DATA
         then
            raise NO_DATA_FOUND;
         end if;
         return v_result;
      end;

member function GetBfile
      return bfile is
      v_result bfile;
      begin
         if base_data.GetBfile( v_result ) = DBMS_TYPES.NO_DATA
         then
            raise NO_DATA_FOUND;
         end if;
         return v_result;
      end;

member function GetBFloat
      return binary_float is
      v_result binary_float;
      begin
         if base_data.GetBFloat( v_result ) = DBMS_TYPES.NO_DATA
         then
            raise NO_DATA_FOUND;
         end if;
         return v_result;
      end;

member function GetBlob
      return blob is
      v_result blob;
      begin
         if base_data.GetBlob( v_result ) = DBMS_TYPES.NO_DATA
         then
            raise NO_DATA_FOUND;
         end if;
         return v_result;
      end;

member function GetChar
      return varchar2 is
      v_result varchar2(32767);
      begin
         if base_data.GetChar( v_result ) = DBMS_TYPES.NO_DATA
         then
            raise NO_DATA_FOUND;
         end if;
         return v_result;
      end;

member function GetClob
      return clob is
      v_result clob;
      begin
         if base_data.GetClob( v_result ) = DBMS_TYPES.NO_DATA
         then
            raise NO_DATA_FOUND;
         end if;
         return v_result;
      end;

member function GetDate
      return date is
      v_result date;
      begin
         if base_data.GetDate( v_result ) = DBMS_TYPES.NO_DATA
         then
            raise NO_DATA_FOUND;
         end if;
         return v_result;
      end;

member function GetIntervalDS
      return interval day to second is
      v_result interval day to second;
      begin
         if base_data.GetIntervalDS( v_result ) = DBMS_TYPES.NO_DATA
         then
            raise NO_DATA_FOUND;
         end if;
         return v_result;
      end;

member function GetIntervalYM
      return interval year to month is
      v_result interval year to month;
      begin
         if base_data.GetIntervalYM( v_result ) = DBMS_TYPES.NO_DATA
         then
            raise NO_DATA_FOUND;
         end if;
         return v_result;
      end;

member function GetNchar
      return nchar is
      v_result nchar(32767);
      begin
         if base_data.GetNchar( v_result ) = DBMS_TYPES.NO_DATA
         then
            raise NO_DATA_FOUND;
         end if;
         return v_result;
      end;

member function GetNClob
      return nclob is
      v_result nclob;
      begin
         if base_data.GetNClob( v_result ) = DBMS_TYPES.NO_DATA
         then
            raise NO_DATA_FOUND;
         end if;
         return v_result;
      end;

member function GetNumber
      return number is
      v_result number;
      begin
         if base_data.GetNumber( v_result ) = DBMS_TYPES.NO_DATA
         then
            raise NO_DATA_FOUND;
         end if;
         return v_result;
      end;

member function GetNVarchar2
      return nvarchar2 is
      v_result nvarchar2(32767);
      begin
         if base_data.GetNVarchar2( v_result ) = DBMS_TYPES.NO_DATA
         then
            raise NO_DATA_FOUND;
         end if;
         return v_result;
      end;

member function GetRaw
      return raw is
      v_result raw(32767);
      begin
         if base_data.GetRaw( v_result ) = DBMS_TYPES.NO_DATA
         then
            raise NO_DATA_FOUND;
         end if;
         return v_result;
      end;

member function GetTimestamp
      return timestamp is
      v_result timestamp;
      begin
         if base_data.GetTimestamp( v_result ) = DBMS_TYPES.NO_DATA
         then
            raise NO_DATA_FOUND;
         end if;
         return v_result;
      end;

member function GetTimestampTZ
      return timestamp with time zone is
      v_result timestamp with time zone;
      begin
         if base_data.GetTimestampTZ( v_result ) = DBMS_TYPES.NO_DATA
         then
            raise NO_DATA_FOUND;
         end if;
         return v_result;
      end;

member function GetTimestampLTZ
      return timestamp with local time zone is
      v_result timestamp with local time zone;
      begin
         if base_data.GetTimestampLTZ( v_result ) = DBMS_TYPES.NO_DATA
         then
            raise NO_DATA_FOUND;
         end if;
         return v_result;
      end;

member function GetVarchar
      return varchar is
      v_result varchar(32767);
      begin
         if base_data.GetVarchar( v_result ) = DBMS_TYPES.NO_DATA
         then
            raise NO_DATA_FOUND;
         end if;
         return v_result;
      end;

member function GetVarchar2
      return varchar2 is
      v_result varchar2(32767);
      begin
         if base_data.GetVarchar2( v_result ) = DBMS_TYPES.NO_DATA
         then
            raise NO_DATA_FOUND;
         end if;
         return v_result;
      end;

   end;
/

