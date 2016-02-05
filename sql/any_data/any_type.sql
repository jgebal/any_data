drop type any_type force;
/

create or replace type any_type as object (
   type_code          number(38,0),
   type_name          varchar2(100),
   type_def           varchar2(100),
   mapping_fnc_suffix varchar2(30),
   member function get_type_name return varchar2,
   member procedure set_type_name( self in out nocopy any_type, p_type_name varchar2 ),
   member function get_type_def  return varchar2,
   member procedure set_type_def( self in out nocopy any_type, p_type_def varchar2 ),
   member procedure set_type_info( self in out nocopy any_type, p_type_name varchar2, p_type_def varchar2 ),
   member function getter_func_name return varchar2,
   member function converter_func_name return varchar2,
   constructor function any_type( p_type_code number, p_type_name varchar2 ) return self as result,
   constructor function any_type( p_type_code number, p_type_name varchar2, p_fnc_suffix varchar2 ) return self as result
);
/

create or replace type body any_type as

   member function get_type_name return varchar2 is
      begin
         return type_name;
      end;

   member procedure set_type_name( self in out nocopy any_type, p_type_name varchar2 ) is
      begin
         type_name := p_type_name;
      end;

   member function get_type_def return varchar2 is
      begin
         return type_def;
      end;

   member procedure set_type_def( self in out nocopy any_type, p_type_def varchar2 ) is
      begin
         type_def := p_type_def;
      end;

   member procedure set_type_info( self in out nocopy any_type, p_type_name varchar2, p_type_def varchar2 ) is
      begin
         set_type_name( p_type_name );
         set_type_def( p_type_def );
      end;

   member function getter_func_name return varchar2 is
      begin
         return 'get'||mapping_fnc_suffix;
      end;

   member function converter_func_name return varchar2 is
      begin
         return 'convert'||mapping_fnc_suffix;
      end;

   constructor function any_type( p_type_code number, p_type_name varchar2) return self as result is
      begin
         self.type_code := p_type_code;
         self.type_name := p_type_name;
         self.mapping_fnc_suffix := p_type_name;
         return;
      end;

   constructor function any_type( p_type_code number, p_type_name varchar2, p_fnc_suffix varchar2) return self as result is
      begin
         self.type_code := p_type_code;
         self.type_name := p_type_name;
         self.mapping_fnc_suffix := p_fnc_suffix;
         return;
      end;
end;
/
