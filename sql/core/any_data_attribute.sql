create or replace type any_data_attribute under any_data (
   name varchar2(400),
   data any_data,
   overriding member function to_string return varchar2,
   overriding member function get_type return any_type,
   constructor function any_data_attribute( p_name varchar2, p_data any_data ) return self as result
);
/

create or replace type body any_data_attribute is

   overriding member function to_string return varchar2 is
      begin
         return name||' => '||data.to_string();
      end;

   overriding member function get_type return any_type is
      begin
         return data.type_info;
      end;

   constructor function any_data_attribute( p_name varchar2, p_data any_data ) return self as result is
      begin
         self.name := p_name;
         self.data := p_data;
         return;
      end;

end;
/

