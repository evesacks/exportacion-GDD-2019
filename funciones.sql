CREATE FUNCTION util.f_001(text) RETURNS void
    LANGUAGE plpgsql
    AS $_$

DECLARE
  v_pid    INTEGER ;
  v_msg    TEXT    ;

BEGIN
  v_pid    := pg_backend_pid() ;
  v_msg    := CONCAT ('( pid = ', v_pid, ' ) - ', TRIM($1), '.') ;
 
  RAISE LOG '%', v_msg ;
  RETURN ;
END;
$_$;


--
--
CREATE FUNCTION util.f_002(text, text) RETURNS boolean
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
$_$;


--
--
CREATE FUNCTION util.f_003(text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$

DECLARE
  b_retorn BOOLEAN  ;
  
  b_001    BPCHAR[] ;
  b_len    BIGINT   ;
  b_a01    BIGINT   ;
  t_mensa  TEXT     ;
   
-- Para probar select util.f_003('I,,,,,F')
-- Retorna true
  
BEGIN
  b_retorn   := False ;
  b_001      := string_to_array($1, ',', 'NULL')     ;
  b_len      := COALESCE(array_length(b_001, 1) , 0) ;

  IF  b_len = 0  THEN
    t_mensa  := CONCAT('No es un array -', $1, '-')  ;	
	PERFORM util.f_001(t_mensa) ;
  ELSE 
    IF b_len = 1 THEN
      t_mensa  := CONCAT('Array -', $1, '- de un solo elemento')  ;	
	  PERFORM util.f_001(t_mensa) ;
    ELSE 
      IF TRIM(b_001[01]   ) = 'I'  AND
	     TRIM(b_001[b_len]) = 'F'  THEN
        b_retorn := TRUE ;
	  END IF ;
	END IF ;
  END IF ;
  
  RETURN (b_retorn) ;
END;

$_$;


--
--
CREATE FUNCTION util.f_004(date) RETURNS text
    LANGUAGE plpgsql
    AS $_$

DECLARE
  t_retorn TEXT   ;
    
  t_a01    TEXT   ;
  t_001    TEXT[] ;
   
-- Para probar select util.f_004('04/12/2019')
-- Retorna true
  
BEGIN
  t_retorn   := NULL ;
  t_a01      := 'Lun,Mar,Mie,Jue,Vie,Sab,Dom' :: TEXT  ;
  t_001      := string_to_array(t_a01, ',', 'NULL')    ;
  
  IF  $1 IS NOT NULL  
  THEN
    t_retorn := t_001[extract(dow from $1)]            ;
  END IF ;
 
  RETURN (t_retorn) ;
END;

$_$;


--
--
CREATE FUNCTION util.f_004(timestamp with time zone) RETURNS text
    LANGUAGE plpgsql
    AS $_$

DECLARE
  t_retorn TEXT   ;
  d_a01    DATE   ;
   
-- Para probar select util.f_004(current_timestamp)
-- Retorna true
  
BEGIN
  t_retorn   := NULL ;
  
  IF  $1 IS NOT NULL  
  THEN
    d_a01    := $1 :: DATE        ;
    t_retorn := util.f_004(d_a01) ;
  END IF ;
 
  RETURN (t_retorn) ;
END;

$_$;


--
--
CREATE FUNCTION util.f_005(text) RETURNS void
    LANGUAGE plpgsql
    AS $_$

DECLARE

  r_01   logs.tlogs%ROWTYPE ; 
   
-- Para probar select util.f_005('algo')
-- Retorna true
  
BEGIN
  r_01.lpid  := pg_backend_pid()  ;
  r_01.lfec  := current_timestamp ;
  
  SELECT INTO r_01.lseq COUNT(1) + 1 FROM  logs.tlogs
                                    WHERE  lpid = r_01.lpid
									  AND  lfec = r_01.lfec ;
									  
  r_01.ltex  := $1 ;
  
  INSERT INTO logs.tlogs(     lseq,      lpid,      lfec,      ltex)
	             VALUES (r_01.lseq, r_01.lpid, r_01.lfec, r_01.ltex) ;
END ;

$_$;


--
--
CREATE FUNCTION util.f_006(text, text) RETURNS bigint
    LANGUAGE plpgsql
    AS $_$

DECLARE
  b_retorn BIGINT   ;
  v_table  NAME     ;
  v_schem  NAME     ;
  t_a01    TEXT     ;
 
BEGIN
  b_retorn := 0          ;
  v_table  := $2 :: NAME ;
  v_schem  := $1 :: NAME ;
  
  t_a01    := CONCAT('SELECT count(1) FROM ', TRIM(v_schem), '.', TRIM(v_table)) ; 
  
  FOR b_retorn IN EXECUTE t_a01
  LOOP
  END LOOP;
  
  RETURN (b_retorn) ;
END;
$_$;


--
--
CREATE FUNCTION util.f_007(text, text) RETURNS SETOF information_schema.columns
    LANGUAGE plpgsql
    AS $_$

DECLARE
  v_table  NAME     ;
  v_schem  NAME     ;
  r_01     information_schema.columns%ROWTYPE ;
  
-- Para Probar
-- SELECT * FROM util.f_007('public', 'tabla_b')
  
BEGIN
  v_table  := $2 :: NAME ;
  v_schem  := $1 :: NAME ;
  
  FOR  r_01  IN SELECT  *   FROM information_schema.columns
                           WHERE table_schema = v_schem
                             AND table_name   = v_table
						ORDER BY ordinal_position
  LOOP
    RETURN NEXT (r_01) ;
  END LOOP;
  
END;
$_$;


--
--
CREATE FUNCTION util.f_008(text, text) RETURNS SETOF text
    LANGUAGE plpgsql
    AS $_$

DECLARE
  v_table  NAME          ;
  v_schem  NAME          ;
  
  t_a01    TEXT          ;
  t_a02    TEXT          ;
  
  c_a01    character(01) ;
  c_a02    character(01) ;
  c_a03    character(01) ;
  
  q_q01    character(01) ;
  q_q02    character(01) ;
  
  r_01     information_schema.columns%ROWTYPE ;
  
-- Para Probar
-- SELECT * FROM util.f_008('public', 'tabla_b')
  
BEGIN
  v_table  := $2 :: NAME ;
  v_schem  := $1 :: NAME ;
  
  c_a01    := '/'        ;
  c_a02    := ' '        ;
  c_a03    := ' '        ;
  
  q_q01    := ''''       ;
  q_q02    := ' '        ;
  
  t_a01    := 'CONCAT('  ;
  
  FOR  r_01  IN SELECT  *   FROM information_schema.columns
                           WHERE table_schema = v_schem
                             AND table_name   = v_table
						ORDER BY ordinal_position
  LOOP
    t_a02  := CONCAT( TRIM(c_a03), TRIM(q_q02), TRIM(c_a02), TRIM(q_q02), TRIM(c_a03) ) ;
	
    IF  r_01.data_type = 'text'              OR
	    r_01.data_type = 'character'         OR 
		r_01.data_type = 'character varyng' 
	THEN 
		t_a01  := CONCAT(TRIM(t_a01), TRIM(t_a02), ' TRIM(', TRIM(r_01.column_name), ')' ) ;
	ELSE
	    t_a01  := CONCAT(TRIM(t_a01), TRIM(t_a02), TRIM(r_01.column_name) );
	END IF ;
	
	c_a02  := c_a01 ;
	c_a03  := ','   ;
	q_q02  := q_q01 ;
  END LOOP;
  
  t_a01    := CONCAT(TRIM(t_a01), ')' ) ;
  t_a02    := CONCAT('SELECT ', TRIM(t_a01), ' FROM ', TRIM(v_schem), '.', TRIM(v_table) ) ;
  
  FOR  t_a01  IN EXECUTE t_a02
  LOOP
    RETURN NEXT (t_a01) ;
  END LOOP;
  
END;
$_$;


--
--
CREATE FUNCTION util.f_009(text, text, text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$

DECLARE
  v_tab_or  NAME          ;
  v_sch_or  NAME          ;
  v_tab_de  NAME          ;
  v_sch_de  NAME          ;
  v_retorn  BOOLEAN       ;
  
  b_conta   BIGINT        ;
  b_len     BIGINT        ;
  b_pos     BIGINT        ;
  b_rel     BIGINT        ;
  
  t_fn      TEXT[]        ;
  t_ft      TEXT[]        ;
  
  t_a01     TEXT          ;
  t_a02     TEXT          ;
  t_a03     TEXT          ;
  t_a04     TEXT          ;
  t_a05     TEXT          ;
  
  t_vo      TEXT[]        ;
  t_vf      TEXT[]        ;
  t_vv      TEXT[]        ;
  
  q_q01    character(01)  ;
  
  r_01     information_schema.columns%ROWTYPE ;
  
-- Para Probar
-- SELECT util.f_009('public', 'tabla_t', 'public', 'tabla_bb')
  
BEGIN
  v_tab_or  := $2 :: NAME ;
  v_sch_or  := $1 :: NAME ;
  v_tab_de  := $4 :: NAME ;
  v_sch_de  := $3 :: NAME ;
  
  v_retorn  := FALSE      ;
  
  q_q01     := ''''       ;


--
--
  SELECT INTO  b_conta COUNT(0)  FROM information_schema.tables 
                                WHERE table_schema = v_sch_or
								  AND table_name   = v_tab_or   ;
								  
  IF  b_conta = 1  
  THEN
    SELECT INTO  b_conta COUNT(0)  FROM information_schema.tables 
                                  WHERE table_schema = v_sch_de
						            AND table_name   = v_tab_de ;
	IF  b_conta = 1
	THEN
	  v_retorn := TRUE       ;
	END IF ;
  END IF ;
  
  IF  v_retorn  =  FALSE  THEN
    RETURN (v_retorn) ;
  END IF ;
  v_retorn     := FALSE      ;


--
-- 
  b_conta      := 0         ;
  
  FOR  r_01  IN SELECT  *   FROM information_schema.columns
                           WHERE table_schema = v_sch_or
                             AND table_name   = v_tab_or
						ORDER BY ordinal_position   
  LOOP
    b_conta       := b_conta + 1       ;
	
	IF  r_01.data_type <> 'text' 
    THEN
	  b_conta     := b_conta + 1       ;
	END IF ;
      
  END LOOP ;

  IF  b_conta > 1  THEN
    RETURN (v_retorn) ;
  END IF ;


--
-- 
  b_conta      := 0         ;
  
  FOR  r_01  IN SELECT  *   FROM information_schema.columns
                           WHERE table_schema = v_sch_de
                             AND table_name   = v_tab_de
						ORDER BY ordinal_position   
  LOOP
    b_conta       := b_conta + 1       ;
	t_fn[b_conta] := r_01.column_name  ;
    t_ft[b_conta] := r_01.data_type    ;
  END LOOP ;

  IF  b_conta < 1  THEN
    RETURN (v_retorn) ;
  END IF ;


--
--
  t_a01        := CONCAT( 'TRUNCATE ', TRIM(v_sch_de), '.', TRIM(v_tab_de)      );
  EXECUTE( t_a01) ;
  

  t_a01        := CONCAT( 'SELECT * FROM ', TRIM(v_sch_or), '.', TRIM(v_tab_OR) ) ;
  
  FOR  t_a02  IN EXECUTE t_a01
  LOOP
    
	t_vo       := string_to_array(t_a02, '/', '')    ;
	b_len      := array_length(t_vo, 1)              ;
	
	b_pos      := 0   ;
	b_rel      := 0   ;
	WHILE  b_pos < b_len
    LOOP
	  b_pos    := b_pos + 1 ;
	  
	  IF  t_vo[b_pos] IS NOT NULL
	  THEN
	    b_rel        := b_rel + 1    ;
	    t_vf[b_rel]  := t_fn[b_pos]  ;
		
		IF  t_ft[b_pos] = 'text'              OR
	        t_ft[b_pos] = 'character'         OR 
		    t_ft[b_pos] = 'character varyng' 
	    THEN 
		  t_vv[b_rel]:= CONCAT( q_q01, TRIM(t_vo[b_pos]), q_q01 ) ;
	    ELSE
	      t_vv[b_rel]:= t_vo[b_pos] ;
	    END IF ;
      END IF ;
	END LOOP ;
	
	IF  b_rel > 0
	THEN 
	  v_retorn:= TRUE                           ;
	  t_a03   := array_to_string(t_vf, ',', '') ;
	  t_a04   := array_to_string(t_vv, ',', '') ; 
	  t_a05   := CONCAT( 'INSERT INTO ', TRIM(v_sch_de), '.', TRIM(v_tab_de) , ' (' ) ;
	  t_a05   := CONCAT( TRIM(t_a05), TRIM(t_a03), ') VALUES (' )                     ;
	  t_a05   := CONCAT( TRIM(t_a05), TRIM(t_a04), ') '         )                     ;
	  EXECUTE t_a05 ;
	END IF ;
	
	t_vf  := string_to_array(' ', ',', '') ;
	t_vv  := string_to_array(' ', ',', '') ;
	
  END LOOP ;
		
  RETURN (v_retorn) ;		
END;
$_$;


--
--
CREATE FUNCTION util.f_010(text, text, text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$

DECLARE
  v_tab_or  NAME          ;
  v_sch_or  NAME          ;
  v_fil_de  NAME          ;

  v_retorn  BOOLEAN       ;
  
  t_a01     TEXT          ;
  t_a02     TEXT          ;
  
  q_q01     character(01) ;

  
-- Para Probar
-- SELECT util.f_010('public', 'tabla_t', 'nemo20190901.001.txt')
  
BEGIN
  v_tab_or  := $2 :: NAME ;
  v_sch_or  := $1 :: NAME ;
  v_fil_de  := $3 :: NAME ;
  
  v_retorn  := TRUE       ;
  
  q_q01     := ''''       ;


--
--
  t_a01     := CONCAT(q_q01, 'c:/pepe/', TRIM(v_fil_de), q_q01) ;
  t_a02     := CONCAT('COPY ', TRIM(v_sch_or), '.', TRIM(v_tab_or), ' to ', trim(t_a01) ) ;
  
  BEGIN
    execute t_a02 ;
  EXCEPTION when others then 
    v_retorn := False ;
  END ;	
 
  RETURN (v_retorn) ;		
END;
$_$;
