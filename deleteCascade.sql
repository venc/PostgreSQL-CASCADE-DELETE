CREATE OR REPLACE FUNCTION deletecascade(tableschema character varying, tablename character varying, columnname character varying, id integer)
  RETURNS text AS
$BODY$
DECLARE
    strresult character varying(2000);
    idSelect character varying(2000);
    newId integer;
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

		idSelect = 'select ' || row_data.foreign_column_name || ' from ' || tableSchema || '.' || tableName || ' where ' || columnName || ' = ' || id;
                RAISE NOTICE '%', idSelect;
		EXECUTE idSelect INTO newId;
                FOR newId IN EXECUTE idSelect LOOP
			PERFORM deleteCascade(row_data.table_schema, row_data.table_name, row_data.column_name, newId);
		END LOOP;
	END LOOP;
	strresult := 'delete from ' || tableSchema || '.' || tableName || ' where ' || columnName || ' = ' || id;
	EXECUTE strresult;
	RAISE NOTICE '%', strresult;	
	return 'OK';
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  COST 10;

