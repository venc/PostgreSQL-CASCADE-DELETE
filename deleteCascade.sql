CREATE OR REPLACE FUNCTION deleteCascade(tableSchema character varying(200), tableName character varying(200), columnName character varying(200), id integer)
    RETURNS text AS
$$
DECLARE
    strresult character varying(2000);
    row_data RECORD;
BEGIN

	FOR row_data IN SELECT
	    tc.constraint_name, tc.table_name, kcu.column_name, tc.table_schema,
	    ccu.table_name AS foreign_table_name,
	    ccu.column_name AS foreign_column_name 
	FROM 
	    information_schema.table_constraints AS tc 
	    JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name
	    JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name
		WHERE constraint_type = 'FOREIGN KEY' AND ccu.table_name= tableName LOOP

		PERFORM deleteCascade(row_data.table_schema, row_data.table_name, row_data.column_name, id);
	END LOOP;
	strresult := 'delete from ' || tableSchema || '.' || tableName || ' where ' || columnName || ' = ' || id;
	EXECUTE strresult;
	RAISE NOTICE '%', strresult;	
	return 'OK';
END;
$$
LANGUAGE 'plpgsql' VOLATILE
SECURITY DEFINER
  COST 10;

