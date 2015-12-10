drop type anydata_element force;
/

create or replace type anydata_element as object (
   element_name           varchar2(400),
   element_raw_data       anydata,
   element_anytype_info   anytype_info,
   element_anydata_helper anydata_helper_base,
member function get_report return varchar2,
constructor function anydata_element( p_element_name varchar2, p_element_raw_data anydata ) return self as result
);
/

create or replace type body anydata_element as
   constructor function anydata_element( p_element_name varchar2, p_element_raw_data anydata ) return self as result is
      begin
         self.element_name := UPPER( p_element_name );
         self.element_raw_data := p_element_raw_data;
         self.element_anytype_info := anytype_info( p_element_raw_data );
         self.element_anydata_helper := anytype_map.get_element( self.element_anytype_info.type_code );
         if element_anytype_info.type_name is null then
            element_anytype_info.type_name := element_anydata_helper.type_name;
         end if;
         return;
      end;
  member function get_report
      return varchar2 is
      begin
         return element_name
               ||'('||element_anytype_info.get_type()||')'
               || ' => '
               || element_anydata_helper.get_report( element_raw_data );
      end;
   end;
/
