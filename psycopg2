SELECT * FROM vendors;
select * from parts;
select * from vendor_parts;

CREATE OR REPLACE FUNCTION get_parts_by_vendor(id integer)
  RETURNS TABLE(part_id INTEGER, part_name VARCHAR) AS
$$
BEGIN
 RETURN QUERY

 SELECT parts.part_id, parts.part_name
 FROM parts
 INNER JOIN vendor_parts on vendor_parts.part_id = parts.part_id
 WHERE vendor_id = id;

END; $$

LANGUAGE plpgsql;

Create or Replace procedure add_new_part(new_part_name varchar, new_vendor_name varchar) as
$$
Declare 
		v_part_id int;
		v_vendor_id int;
Begin
Insert into parts(part_name) values(new_part_name) returning part_id into v_part_id;
Insert into vendors(vendor_name) values(new_vendor_name) returning vendor_id into v_vendor_id;
Insert into vendor_parts(part_id, vendor_id) values(v_part_id, v_vendor_id);
End;
$$
Language plpgsql;









