drop type any_data_attribute force;
/

create or replace type any_data_attribute as object (
   name varchar2(400),
   data any_data,
   member function to_string return varchar2
);
/

create or replace type body any_data_attribute is

   member function to_string return varchar2 is
      begin
         return name||' => '||data.to_string();
      end;

end;
/

