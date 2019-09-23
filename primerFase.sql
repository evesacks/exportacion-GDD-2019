
--      VER SI DOS TABLAS SON IGUALES       --

CREATE FUNCTION util.f_son_iguales(text text text text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$

DECLARE
  v_table_01  NAME     ;
  v_schem_01  NAME     ;
  v_table_02  NAME     ;
  v_schem_02  NAME     ;
  b_retorno   boolean  ;
  b_aux_01    bigint   ;
  
-- Para Probar
-- SELECT * FROM util.f_son_iguales('public', 'tabla_a', 'public', 'tabla_b')
  
BEGIN
  v_table_01  := $2 :: NAME ;
  v_schem_01  := $1 :: NAME ;
  v_table_02  := $4 :: NAME ;
  v_schem_02  := $3 :: NAME ;
  b_retorno   := False      ;
  
  SELECT INTO b_aux_01 COUNT(0) 
  	FROM information_schema.columns a
	INNER JOIN information_schema.columns b
		ON a.table_schema = v_schem_01
			AND a.table_name   = v_table_01
			AND b.table_schema = v_schem_02
			AND b.table_name   = v_table_02
			AND a.ordinal_position = b.ordinal_position
			AND a.data_type <> b.data_type ;
  IF b_aux_01 = 0 THEN b_retorno = True ;
  END IF ;
  RETURN(b_retorno) ; 
END;
