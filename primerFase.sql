-------------> verificar si dos tablas son iguales

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
$_$
------------->-------------> PRIMER FASE

-------------> Valida que exista el nombre de la exportación.

CREATE FUNCTION útil.existe_nombre_exportacion (text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$

DECLARE
  v_retorn BOOLEAN  ;
  v_conta  BIGINT   ;
  v_exportacion NAME     ;
  v_mensa  TEXT     ;
  
BEGIN
  v_retorn := FALSE      ;
  v_exportacion  := $1 :: NAME ;
  
  SELECT INTO  v_conta COUNT(0)  FROM information_schema.exportaciones 
                                WHERE exportaciones_nombre = v_exportacion
   
  CASE  v_conta
  WHEN  0       THEN 
    v_mensa  := CONCAT('No existe la exportacion ', v_table, ') ;
	PERFORM util.f_001(v_mensa) ;
  WHEN  1       THEN 
    v_retorn := TRUE ;
  ELSE
    v_mensa  := CONCAT('Existe la exportación ', v_table, ');
	PERFORM util.f_001(v_mensa) ;
  END CASE ;

  RETURN (v_retorn);
END;
$_$;

-------------> Valida que exista el nombre del schema y tabla que contiene los datos.

CREATE OR REPLACE FUNCTION util.f_existe_schema(
	text)
    RETURNS boolean
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE
  v_retorn BOOLEAN  ;
  v_conta  BIGINT   ;
  v_schem  NAME     ;
  v_mensa  TEXT     ;
  
BEGIN
  v_retorn := FALSE      ;
  v_schem  := $1 :: NAME ;
  
  SELECT INTO  v_conta COUNT(0) FROM information_schema.schemata
                                WHERE schema_name = v_schem;

if v_conta = 1 then v_retorn = True;
END if;
  RETURN (v_retorn);
END;
$BODY$;


-------------> Valida que exista la tabla en el schema.

CREATE FUNCTION util.f_existe_t_en_s(text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$

DECLARE
  v_retorn BOOLEAN  ;
  v_conta  BIGINT   ;
  v_table  NAME     ;
  v_schem  NAME     ;
  v_mensa  TEXT     ;
  
BEGIN
  v_retorn := FALSE      ;
  v_table  := $2 :: NAME ;
  v_schem  := $1 :: NAME ;
  
  SELECT INTO  v_conta COUNT(0)  FROM information_schema.tables 
                                WHERE table_schema = v_schem
		        AND table_name   = v_table   ;
   
  CASE  v_conta
  WHEN  0       THEN 
    v_mensa  := CONCAT('No existe la tabla ', v_table, ' en ', v_schem) ;
	PERFORM util.f_001(v_mensa) ;
  WHEN  1       THEN 
    v_retorn := TRUE ;
  ELSE
    v_mensa  := CONCAT('Existe la tabla ', v_table, ' en ', v_conta, ' schemas');
	PERFORM util.f_001(v_mensa) ;
  END CASE ;

  RETURN (v_retorn);
END;
$_$
-------------> Valida la modalidad

CREATE FUNCTION util.existe_modalidad (text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$

DECLARE
  v_retorn BOOLEAN  ;
  v_conta  BIGINT   ;
  v_modalidad NAME     ;
  v_mensa  TEXT     ;
  
BEGIN
  v_retorn := FALSE      ;
  v_modalidad  := $1 :: NAME ;
  
  SELECT INTO  v_conta COUNT(0)  FROM information_schema.modalidad
                                WHERE modalidad_nombre = v_modalidad
   
  CASE  v_conta
  WHEN  0       THEN 
    v_mensa  := CONCAT('No existe la modalidad ', v_modalidad, ') ;
	PERFORM util.f_001(v_mensa) ;
  WHEN  1       THEN 
    v_retorn := TRUE ;
  ELSE
    v_mensa  := CONCAT('Existe la modalidad ', v_modalidad, ');
	PERFORM util.f_001(v_mensa) ;
  END CASE ;

  RETURN (v_retorn);
END;
$_$
-------------> Si existe datos en nombre, schema y tabla, valida que la definición de la tabla sea similar a la definición de la tabla de exportación.
-------------> Crear tabla similar a la que vamos a exportar para copiar los datos, copiamos los datos necesarios.

CREATE FUNCTION util.f_crear_tabla_similar(text text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$

DECLARE
  v_schem  NAME     ;
  v_table  NAME     ;
  b_retorno   boolean  ;
v_table_copy NAME  ;
  
BEGIN
  v_table  := $2 :: NAME ;
  v_schem  := $1 :: NAME ;
  b_retorno   := False      ;

v_table_copy = CONCAT(tabla_fase_uno, table_seq NEXTVAL)
  
CREATE TABLE information.v_table_copy AS (SELECT * FROM v_schem.v_table);

RETURN True ;
END;
$_$
