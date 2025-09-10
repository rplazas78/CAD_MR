/**********************************************************************      
$Archive  : FN_TOTAL_COSTOS_FICHA.sql
$Revision : $      
$Author   : CAD      
$Modtime  : $       
$History  : $   Metodo de Reposicion (MR)   
SET SERVEROUTPUT ON;
CLEAR SCREEN;
SELECT FN_EJECUTAR_REGLA_DINAMICA('PRELIM_01',1,1,2025,113, 21) as R FROM DUAL
SELECT FN_EJECUTAR_REGLA_DINAMICA('PRELIM_04',1,1,2025,115,NULL,NULL,5,5) as FONDO FROM DUAL
**********************************************************************/  


CREATE OR REPLACE FUNCTION FN_EJECUTAR_REGLA_DINAMICA (
    p_codigo_actividad          VARCHAR2,					-- Codigo de Actividad PRELIM_01
    p_tipo_actividad			NUMBER,						-- 0:Otro , 1: Comercial , 2: Residencial
	p_tipo_presupuesto          NUMBER, 					-- 1:presupuesto es independiente, 2: presupuesto predominante
    p_vigencia                  NUMBER,						-- vigencia
    p_armazon                   NUMBER,         			-- parametro
    p_area_uso                  NUMBER 		DEFAULT NULL,	-- parametro
	p_area_total_construida     NUMBER 		DEFAULT NULL,	-- parametro
	p_frente               		NUMBER 		DEFAULT NULL,	-- parametro
    p_fondo                		NUMBER 		DEFAULT NULL,	-- parametro
	p_grupo_uso_cantidades      NUMBER 		DEFAULT NULL,   -- parametro	
    p_pisos_acabados            NUMBER 		DEFAULT NULL,   -- parametro
    p_area_tipo_unidad_uso      NUMBER 		DEFAULT NULL,   -- parametro
    p_n_unidades_uso_principal  NUMBER   	DEFAULT NULL,   -- parametro
    p_n_pisos                   NUMBER   	DEFAULT NULL,   -- parametro
    p_codigo_uso                VARCHAR2 	DEFAULT NULL,   -- parametro
    p_n_sotanos                 NUMBER   	DEFAULT NULL,   -- parametro
    p_n_baños                   NUMBER   	DEFAULT NULL,   -- parametro
    p_n_cocinas                 NUMBER   	DEFAULT NULL,   -- parametro
    p_n_espacios                NUMBER   	DEFAULT NULL,   -- parametro
    p_m_muros                   NUMBER   	DEFAULT NULL,   -- parametro
    p_codigo_estrato            NUMBER   	DEFAULT NULL,   -- parametro
    p_cubierta_muros_acabados   NUMBER   	DEFAULT NULL,   -- parametro
    p_fachada_acabados          NUMBER   	DEFAULT NULL,   -- parametro
    p_mobiliario_baño           NUMBER   	DEFAULT NULL,   -- parametro
    p_mobiliario_cocina         NUMBER   	DEFAULT NULL,   -- parametro
    p_complemento_industria     NUMBER      DEFAULT NULL,   -- parametro	
    p_cubierta_estructura       NUMBER      DEFAULT NULL,   -- parametro	
	p_area_primer_piso          NUMBER      DEFAULT NULL,   -- parametro
	p_tamaño_baño               NUMBER      DEFAULT NULL,   -- parametro
	p_tamaño_cocina				NUMBER      DEFAULT NULL    -- parametro
	
) RETURN NUMBER
IS
    v_formula                   VARCHAR2(4000);
    v_condicion                 VARCHAR2(4000);
    v_resultado                 NUMBER;
    v_sql                       CLOB;
    -----
    v_area_uso                  NUMBER;
    v_area_total_construida     NUMBER; 
    v_frente                    NUMBER;
    v_fondo                     NUMBER;
	v_grupo_uso_cantidades      NUMBER;
BEGIN


    -- Obtener fórmula y condición desde la tabla
    SELECT T.FORMULA, T.CONDICION
    INTO v_formula, v_condicion
    FROM MR_TB_REGLA_PRELIMINAR T
    WHERE T.ID_ACTIVIDAD_OBRA = p_codigo_actividad AND TIPO_ACTIVIDAD = p_tipo_actividad
    AND T.TIPO_PRESUPUESTO = p_tipo_presupuesto AND T.VIGENCIA = p_vigencia
	AND ROWNUM = 1;

    -- Mostrar valores de entrada
    DBMS_OUTPUT.PUT_LINE('--- VARIABLES DE ENTRADA (1) ---');
    DBMS_OUTPUT.PUT_LINE('p_codigo_actividad: ' || p_codigo_actividad);
    DBMS_OUTPUT.PUT_LINE('p_tipo_actividad: ' || p_tipo_actividad);
    DBMS_OUTPUT.PUT_LINE('p_tipo_presupuesto: ' || p_tipo_presupuesto);
    DBMS_OUTPUT.PUT_LINE('p_vigencia: ' || p_vigencia);
    DBMS_OUTPUT.PUT_LINE('p_armazon: ' || p_armazon);
    DBMS_OUTPUT.PUT_LINE('p_area_uso: ' || p_area_uso);
    DBMS_OUTPUT.PUT_LINE('p_area_total_construida: ' || p_area_total_construida);
    DBMS_OUTPUT.PUT_LINE('p_frente: ' || p_frente);
    DBMS_OUTPUT.PUT_LINE('p_fondo: ' || p_fondo);
    DBMS_OUTPUT.PUT_LINE('p_grupo_uso_cantidades: ' || p_grupo_uso_cantidades);
    DBMS_OUTPUT.PUT_LINE('p_pisos_acabados: ' || p_pisos_acabados);
    DBMS_OUTPUT.PUT_LINE('p_area_tipo_unidad_uso: ' || p_area_tipo_unidad_uso);
    DBMS_OUTPUT.PUT_LINE('p_n_unidades_uso_principal: ' || p_n_unidades_uso_principal);
    DBMS_OUTPUT.PUT_LINE('p_n_pisos: ' || p_n_pisos);
    DBMS_OUTPUT.PUT_LINE('p_codigo_uso: ' || p_codigo_uso);
    DBMS_OUTPUT.PUT_LINE('p_n_sotanos: ' || p_n_sotanos);
    DBMS_OUTPUT.PUT_LINE('p_n_baños: ' || p_n_baños);
    DBMS_OUTPUT.PUT_LINE('p_n_cocinas: ' || p_n_cocinas);
    DBMS_OUTPUT.PUT_LINE('p_n_espacios: ' || p_n_espacios);
    DBMS_OUTPUT.PUT_LINE('p_m_muros: ' || p_m_muros);
    DBMS_OUTPUT.PUT_LINE('p_codigo_estrato: ' || p_codigo_estrato);
    DBMS_OUTPUT.PUT_LINE('p_cubierta_muros_acabados: ' || p_cubierta_muros_acabados);
    DBMS_OUTPUT.PUT_LINE('p_fachada_acabados: ' || p_fachada_acabados);
    DBMS_OUTPUT.PUT_LINE('p_mobiliario_baño: ' || p_mobiliario_baño);
    DBMS_OUTPUT.PUT_LINE('p_mobiliario_cocina: ' || p_mobiliario_cocina);
	DBMS_OUTPUT.PUT_LINE('p_complemento_industria: ' || p_complemento_industria);
	DBMS_OUTPUT.PUT_LINE('p_cubierta_estructura: ' || p_cubierta_estructura);
	DBMS_OUTPUT.PUT_LINE('p_area_primer_piso: ' || p_area_primer_piso);
	DBMS_OUTPUT.PUT_LINE('p_tamaño_baño: ' || p_tamaño_baño);
    DBMS_OUTPUT.PUT_LINE('p_tamaño_cocina: ' || p_tamaño_cocina);

	
    
    --DBMS_OUTPUT.PUT_LINE('--- VARIABLES DE ENTRADA (2) ---');
    /*
	IF p_codigo_actividad IN ('PRELIM_01', 'PRELIM_02', 'PRELIM_12')  THEN
        IF p_tipo_presupuesto = 1 THEN
            v_area_uso := p_valor;
            DBMS_OUTPUT.PUT_LINE('AREA_USO = ' || v_area_uso);
        ELSIF p_tipo_presupuesto = 2 THEN
            v_area_total_construida := p_valor;
            DBMS_OUTPUT.PUT_LINE('AREA_TOTAL_CONSTRUIDA = ' || v_area_total_construida);
        END IF;
    END IF;
	*/

    ---DBMS_OUTPUT.PUT_LINE('FRENTE             = ' || p_frente);
    ---DBMS_OUTPUT.PUT_LINE('FONDO              = ' || p_fondo);

    -- Mostrar fórmula y condición
    DBMS_OUTPUT.PUT_LINE('--- CONDICIÓN Y FÓRMULA ---');
    DBMS_OUTPUT.PUT_LINE('Condición: ' || v_condicion);
    DBMS_OUTPUT.PUT_LINE('Fórmula  : ' || v_formula);

    -- Construcción del bloque dinámico
    v_sql := '
        DECLARE
            ARMAZON_ESTRUCTURA          NUMBER := :1;
            AREA_USO                    NUMBER := :2;
            AREA_TOTAL_CONSTRUIDA       NUMBER := :3;
			FRENTE                    	NUMBER := :4;
            FONDO                     	NUMBER := :5;
            GRUPO_USO_CANTIDADES        NUMBER := :6;
            PISOS_ACABADOS              NUMBER := :7;   
            AREA_TIPO_UNIDAD_USO        NUMBER := :8;
            N_UNIDADES_USO_PRINCIPAL    NUMBER := :9;
            N_PISOS                     NUMBER := :10;
            CODIGO_USO                  VARCHAR2(3) := :11;
            N_SOTANOS                   NUMBER := :12;       
            N_BAÑOS                     NUMBER := :13;
            N_COCINAS                   NUMBER := :14;
            N_ESPACIOS                  NUMBER := :15;
            MUROS_ESTRUCTURA            NUMBER := :16;
            CODIGO_ESTRATO              NUMBER := :17;
            CUBIERTA_MUROS_ACABADOS     NUMBER := :18;
            FACHADA_ACABADOS            NUMBER := :19;
            MOBILIARIO_BAÑO             NUMBER := :20;
            MOBILIARIO_COCINA           NUMBER := :21;
			COMPLEMENTO_INDUSTRIA       NUMBER := :22;
			CUBIERTA_ESTRUCTURA         NUMBER := :23;
			AREA_PRIMER_PISO            NUMBER := :24;
            TAMAÑO_BAÑO                 NUMBER := :25;
            TAMAÑO_COCINA               NUMBER := :26;
			RESULTADO                   NUMBER;
			
        BEGIN
            IF ' || v_condicion || ' THEN
                RESULTADO := ' || v_formula || ';
            ELSE
                RESULTADO := NULL;
            END IF;
            :5000 := RESULTADO;
        END;';

    -- Mostrar bloque generado
    DBMS_OUTPUT.PUT_LINE('--- BLOQUE PL/SQL GENERADO ---');
    DBMS_OUTPUT.PUT_LINE(v_sql);

    -- Ejecutar el bloque
    EXECUTE IMMEDIATE v_sql
    USING p_armazon, p_area_uso, p_area_total_construida, p_frente, p_fondo, p_grupo_uso_cantidades, p_pisos_acabados, 
     p_area_tipo_unidad_uso, p_n_unidades_uso_principal, p_n_pisos, p_codigo_uso, p_n_sotanos, p_n_baños, p_n_cocinas, p_n_espacios,
     p_m_muros, p_codigo_estrato, p_cubierta_muros_acabados, p_fachada_acabados, p_mobiliario_baño, p_mobiliario_cocina, 
	 p_complemento_industria, p_cubierta_estructura,p_area_primer_piso, p_tamaño_baño, p_tamaño_cocina,
     OUT v_resultado;


    -- Mostrar resultado
    DBMS_OUTPUT.PUT_LINE('--- RESULTADO FINAL ---');
    DBMS_OUTPUT.PUT_LINE('Resultado: ' || NVL(TO_CHAR(v_resultado), 'NULL'));

    RETURN NVL(v_resultado,0);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al evaluar: ' || SQLERRM);
        RETURN NULL;
END;
/

/**********************************************************************      
$Archive  : FN_TOTAL_COSTOS_FICHA.sql
$Revision : $      
$Author   : CAD      
$Modtime  : $       
$History  : $   Metodo de Reposicion (MR)   
SELECT FN_TOTAL_COSTOS_FICHA(115, 'PRESUPUESTO RESIDENCIAL', 2025, 'HMEN_01') AS TOTAL FROM DUAL;
SELECT FN_TOTAL_COSTOS_FICHA(115, 'PRESUPUESTO COMERCIAL', 2025, 'HMEN_01') AS TOTAL FROM DUAL;

SELECT NVL(FN_TOTAL_COSTOS_FICHA(NULL,1,1,'2026',100,115,15,0,10,11,0,0,30,25,10,'055'),0) AS CANTIDAD_OBRA FROM DUAL;
SELECT NVL(FN_TOTAL_COSTOS_FICHA(NULL,2,1,'2026',100,115,15,0,10,11,0,0,30,25,10,'055'),0) AS CANTIDAD_OBRA FROM DUAL;

TRUNCATE TABLE MR_TB_COSTO_DIRECTO_DETALLE;
TRUNCATE TABLE MR_TB_TMP_LIQ_CAPITULOS;

SELECT * FROM MR_TB_TMP_LIQ_CAPITULOS;
SELECT * FROM MR_TB_COSTO_DIRECTO_DETALLE;

DECLARE
  v NUMBER;
BEGIN
  v := FN_TOTAL_COSTOS_FICHA(
         p_codigo_actividad => NULL,
         p_tipo_actividad   => 1,
         p_tipo_presupuesto => 2,
         p_vigencia         => 2025,
         p_id_liquidacion   => 1001,
         p_armazon          => 115,
         p_area_uso         => 15
         -- ...otros params...
       );
  DBMS_OUTPUT.PUT_LINE('Total = '||v);
END;


**********************************************************************/  
CREATE OR REPLACE FUNCTION FN_TOTAL_COSTOS_FICHA 
(
 
    p_codigo_actividad          VARCHAR2,					-- Codigo de Actividad PRELIM_01
    p_tipo_actividad			NUMBER,						-- 0:Otro , 1: Comercial , 2: Residencial
	p_tipo_presupuesto          NUMBER, 					-- 1:presupuesto es independiente, 2: presupuesto predominante
    p_vigencia                  NUMBER,						-- vigencia
	p_id_liquidacion            NUMBER		DEFAULT NULL,	-- id_liquidacion
    p_armazon                   NUMBER 		DEFAULT NULL,   -- parametro
    p_area_uso                  NUMBER 		DEFAULT NULL,	-- parametro
	p_area_total_construida     NUMBER 		DEFAULT NULL,	-- parametro
	p_frente               		NUMBER 		DEFAULT NULL,	-- parametro
    p_fondo                		NUMBER 		DEFAULT NULL,	-- parametro
	p_grupo_uso_cantidades      NUMBER 		DEFAULT NULL,   -- parametro	
    p_pisos_acabados            NUMBER 		DEFAULT NULL,   -- parametro
    p_area_tipo_unidad_uso      NUMBER 		DEFAULT NULL,   -- parametro
    p_n_unidades_uso_principal  NUMBER   	DEFAULT NULL,   -- parametro
    p_n_pisos                   NUMBER   	DEFAULT NULL,   -- parametro
    p_codigo_uso                VARCHAR2 	DEFAULT NULL,   -- parametro
    p_n_sotanos                 NUMBER   	DEFAULT NULL,   -- parametro
    p_n_baños                   NUMBER   	DEFAULT NULL,   -- parametro
    p_n_cocinas                 NUMBER   	DEFAULT NULL,   -- parametro
    p_n_espacios                NUMBER   	DEFAULT NULL,   -- parametro
    p_m_muros                   NUMBER   	DEFAULT NULL,   -- parametro
    p_codigo_estrato            NUMBER   	DEFAULT NULL,   -- parametro
    p_cubierta_muros_acabados   NUMBER   	DEFAULT NULL,   -- parametro
    p_fachada_acabados          NUMBER   	DEFAULT NULL,   -- parametro
    p_mobiliario_baño           NUMBER   	DEFAULT NULL,   -- parametro
    p_mobiliario_cocina         NUMBER   	DEFAULT NULL,   -- parametro	
	p_complemento_industria     NUMBER      DEFAULT NULL,   -- parametro
    p_cubierta_estructura       NUMBER      DEFAULT NULL,   -- parametro	
	p_area_primer_piso          NUMBER      DEFAULT NULL,   -- parametro
	p_tamaño_baño               NUMBER      DEFAULT NULL,   -- parametro
	p_tamaño_cocina				NUMBER      DEFAULT NULL,   -- parametro
    p_enchape_bano				NUMBER      DEFAULT NULL,   -- parametro
    p_enchape_cocina			NUMBER      DEFAULT NULL    -- parametro

) RETURN NUMBER
IS
    v_total 					NUMBER := 0;
	v_material_ajuste   		VARCHAR2(20) :='HMEN_01';   -- 'HMEN_01'
	v_codigos_ficha             VARCHAR2(4000);
	
BEGIN

	EXECUTE IMMEDIATE 'TRUNCATE TABLE MR_TB_TMP_LIQ_CAPITULOS';
	
	v_codigos_ficha := p_armazon || ',' || p_m_muros || ',' || p_cubierta_estructura || ',' || p_fachada_acabados || ',' 
                        || p_cubierta_muros_acabados || ',' || p_pisos_acabados || ',' || p_tamaño_baño || ',' || p_enchape_bano || ',' 
                        || p_mobiliario_baño || ',' || p_tamaño_cocina || ',' || p_enchape_cocina || ',' || p_mobiliario_cocina || ',' 
                        || p_complemento_industria;
	
	DBMS_OUTPUT.PUT_LINE('v_codigos_ficha = '|| v_codigos_ficha);

    IF p_tipo_actividad = 1 THEN --1: COMERCIAL , 2: RESIDENCIAL
	    
		INSERT INTO MR_TB_TMP_LIQ_CAPITULOS (ID_LIQUIDACION,CODIGO_FICHA,TIPO_ACTIVIDAD,TIPO_PRESUPUESTO,CAPITULO_OBRA,ID_ACTIVIDAD_OBRA, SUBTOTAL_CAPITULO, CANTIDAD_OBRA)
		SELECT
		p_id_liquidacion,		
		v_codigos_ficha,
		p_tipo_actividad,
		TTT.TIPO_PRESUPUESTO,
		TTT.CAPITULO_OBRA,
		TTT.ID_ACTIVIDAD_OBRA,
		NVL(SUM(TTT.SUBTOTAL_ACT_OBRA),0) AS SUBTOTAL_ACT_OBRA,
		NVL(SUM(TTT.CANTIDAD_OBRA),0) AS CANTIDAD_OBRA
		FROM 
		(
			SELECT 
			TT.CAPITULO_OBRA, 
			TT.ID_ACTIVIDAD_OBRA, 
			SUM
			(
				CASE 
					WHEN TT.CANT_HMEN IS NOT NULL THEN ROUND(TT.SUBTOTAL + (TT.SUBTOTAL * TT.CANT_HMEN),14)
					ELSE ROUND(TT.SUBTOTAL,14)
				END
			) AS COSTO_UNITARIO_ACT_OBRA,
			SUM 
			(
				TT.CANTIDAD_OBRA
			) AS CANTIDAD_OBRA,

			ROUND
			(
				SUM
				(
					CASE 
						WHEN TT.CANT_HMEN IS NOT NULL THEN ROUND(TT.SUBTOTAL + (TT.SUBTOTAL * TT.CANT_HMEN),14)
						ELSE ROUND(TT.SUBTOTAL,14)
					END
				) *
				SUM 
				(
					TT.CANTIDAD_OBRA
				)
			,14) AS SUBTOTAL_ACT_OBRA,
			TT.TIPO_PRESUPUESTO
			FROM 
			(
				SELECT 
				T.CAPITULO_OBRA, 
				T.ID_ACTIVIDAD_OBRA, 
				T.CODIGO_FICHA, 
				T.SUBTOTAL, 
				T.CANT_HMEN,
				FN_EJECUTAR_REGLA_DINAMICA
				(
					T.ID_ACTIVIDAD_OBRA,p_tipo_actividad,p_tipo_presupuesto,
					p_vigencia,p_armazon,p_area_uso,p_area_total_construida,
					p_frente,p_fondo,p_grupo_uso_cantidades,					   
					p_pisos_acabados, p_area_tipo_unidad_uso, p_n_unidades_uso_principal,
					p_n_pisos, p_codigo_uso, p_n_sotanos, p_n_baños, p_n_cocinas, p_n_espacios,
					p_m_muros, p_codigo_estrato, p_cubierta_muros_acabados, p_fachada_acabados, p_mobiliario_baño, p_mobiliario_cocina,
					p_complemento_industria,p_cubierta_estructura,p_area_primer_piso,p_tamaño_baño,p_tamaño_cocina
				) AS CANTIDAD_OBRA,
				p_tipo_presupuesto AS TIPO_PRESUPUESTO
				FROM 
				(
					SELECT AOM.CAPITULO_OBRA,
						   CF.ID_ACTIVIDAD_OBRA, 
						   CF.VIGENCIA, 
						   CF.CODIGO_FICHA,
						   SUM(LM.COSTO_UNITARIO_MATERIAL * AOM.CANTIDAD_MATERIAL) AS SUBTOTAL, 
						   MAX(CASE WHEN AOM.ID_MATERIAL = v_material_ajuste THEN AOM.CANTIDAD_MATERIAL END) AS CANT_HMEN
					FROM MR_TB_LISTADO_MATERIAL_MANO_OBRA LM
					INNER JOIN MR_TB_ACTIVIDAD_OBRA_MATERIAL AOM ON LM.ID_MATERIAL = AOM.ID_MATERIAL
					INNER JOIN MR_TB_ACT_OBR_COD_FICHA_COM CF ON AOM.ID_ACTIVIDAD_OBRA = CF.ID_ACTIVIDAD_OBRA
					WHERE CF.CODIGO_FICHA IN 
					(
                        SELECT
                            TRIM(REGEXP_SUBSTR(v_codigos_ficha, '[^,]+', 1, LEVEL))
                        FROM
                            DUAL
                        CONNECT BY
                            LEVEL <= LENGTH(REGEXP_REPLACE(v_codigos_ficha, '[^,]+')) + 1
                    ) AND CF.VIGENCIA = p_vigencia
					--AND CF.ID_ACTIVIDAD_OBRA = 'PRELIM_01'
					GROUP BY AOM.CAPITULO_OBRA,CF.ID_ACTIVIDAD_OBRA, CF.VIGENCIA, CF.CODIGO_FICHA
				) T
			 ) TT
				GROUP BY  TT.ID_ACTIVIDAD_OBRA,TT.CAPITULO_OBRA,TT.TIPO_PRESUPUESTO
			) TTT
			GROUP BY TTT.CAPITULO_OBRA,TTT.ID_ACTIVIDAD_OBRA,TTT.TIPO_PRESUPUESTO;			
		

    ELSIF p_tipo_actividad = 2 THEN --1: COMERCIAL , 2: RESIDENCIAL

		INSERT INTO MR_TB_TMP_LIQ_CAPITULOS (ID_LIQUIDACION,CODIGO_FICHA,TIPO_ACTIVIDAD,TIPO_PRESUPUESTO,CAPITULO_OBRA,ID_ACTIVIDAD_OBRA, SUBTOTAL_CAPITULO, CANTIDAD_OBRA)
		SELECT
		p_id_liquidacion,		
		v_codigos_ficha,
		p_tipo_actividad,
		TTT.TIPO_PRESUPUESTO,
		TTT.CAPITULO_OBRA,
		TTT.ID_ACTIVIDAD_OBRA,
		NVL(SUM(TTT.SUBTOTAL_ACT_OBRA),0) AS SUBTOTAL_ACT_OBRA,
		NVL(SUM(TTT.CANTIDAD_OBRA),0) AS CANTIDAD_OBRA
		FROM 
		(
			SELECT 
			TT.CAPITULO_OBRA, 
			TT.ID_ACTIVIDAD_OBRA, 
			SUM
			(
				CASE 
					WHEN TT.CANT_HMEN IS NOT NULL THEN ROUND(TT.SUBTOTAL + (TT.SUBTOTAL * TT.CANT_HMEN),14)
					ELSE ROUND(TT.SUBTOTAL,14)
				END
			) AS COSTO_UNITARIO_ACT_OBRA,
			SUM 
			(
				TT.CANTIDAD_OBRA
			) AS CANTIDAD_OBRA,

			ROUND
			(
				SUM
				(
					CASE 
						WHEN TT.CANT_HMEN IS NOT NULL THEN ROUND(TT.SUBTOTAL + (TT.SUBTOTAL * TT.CANT_HMEN),14)
						ELSE ROUND(TT.SUBTOTAL,14)
					END
				) *
				SUM 
				(
					TT.CANTIDAD_OBRA
				)
			,14) AS SUBTOTAL_ACT_OBRA,
			TT.TIPO_PRESUPUESTO
			FROM 
			(
				SELECT 
				T.CAPITULO_OBRA, 
				T.ID_ACTIVIDAD_OBRA, 
				T.CODIGO_FICHA, 
				T.SUBTOTAL, 
				T.CANT_HMEN,
				FN_EJECUTAR_REGLA_DINAMICA
				(
					T.ID_ACTIVIDAD_OBRA,p_tipo_actividad,p_tipo_presupuesto,
					p_vigencia,p_armazon,p_area_uso,p_area_total_construida,
					p_frente,p_fondo,p_grupo_uso_cantidades,					   
					p_pisos_acabados, p_area_tipo_unidad_uso, p_n_unidades_uso_principal,
					p_n_pisos, p_codigo_uso, p_n_sotanos, p_n_baños, p_n_cocinas, p_n_espacios,
					p_m_muros, p_codigo_estrato, p_cubierta_muros_acabados, p_fachada_acabados, p_mobiliario_baño, p_mobiliario_cocina,
					p_complemento_industria,p_cubierta_estructura,p_area_primer_piso,p_tamaño_baño,p_tamaño_cocina
				) AS CANTIDAD_OBRA,
				p_tipo_presupuesto AS TIPO_PRESUPUESTO
				FROM 
				(
					SELECT AOM.CAPITULO_OBRA,
						   CF.ID_ACTIVIDAD_OBRA, 
						   CF.VIGENCIA, 
						   CF.CODIGO_FICHA,
						   SUM(LM.COSTO_UNITARIO_MATERIAL * AOM.CANTIDAD_MATERIAL) AS SUBTOTAL, 
						   MAX(CASE WHEN AOM.ID_MATERIAL = v_material_ajuste THEN AOM.CANTIDAD_MATERIAL END) AS CANT_HMEN
					FROM MR_TB_LISTADO_MATERIAL_MANO_OBRA LM
					INNER JOIN MR_TB_ACTIVIDAD_OBRA_MATERIAL AOM ON LM.ID_MATERIAL = AOM.ID_MATERIAL
					INNER JOIN MR_TB_ACT_OBR_COD_FICHA_RES CF ON AOM.ID_ACTIVIDAD_OBRA = CF.ID_ACTIVIDAD_OBRA
					WHERE CF.CODIGO_FICHA IN 
					(
                        SELECT
                            TRIM(REGEXP_SUBSTR(v_codigos_ficha, '[^,]+', 1, LEVEL))
                        FROM
                            DUAL
                        CONNECT BY
                            LEVEL <= LENGTH(REGEXP_REPLACE(v_codigos_ficha, '[^,]+')) + 1
                    ) AND CF.VIGENCIA = p_vigencia
					--AND CF.ID_ACTIVIDAD_OBRA = 'PRELIM_01'
					GROUP BY AOM.CAPITULO_OBRA,CF.ID_ACTIVIDAD_OBRA, CF.VIGENCIA, CF.CODIGO_FICHA
				) T
			 ) TT
				GROUP BY  TT.ID_ACTIVIDAD_OBRA,TT.CAPITULO_OBRA,TT.TIPO_PRESUPUESTO
			) TTT
			GROUP BY TTT.CAPITULO_OBRA,TTT.ID_ACTIVIDAD_OBRA,TTT.TIPO_PRESUPUESTO;			
			
    END IF;
	
	SELECT ROUND(NVL(SUM(SUBTOTAL_CAPITULO),0),14) INTO v_total
	FROM MR_TB_TMP_LIQ_CAPITULOS;
	
	INSERT INTO MR_TB_COSTO_DIRECTO_DETALLE (ID_LIQUIDACION,CODIGO_FICHA,TIPO_ACTIVIDAD,TIPO_PRESUPUESTO,CAPITULO_OBRA,ID_ACTIVIDAD_OBRA, SUBTOTAL_CAPITULO, CANTIDAD_OBRA)
	SELECT ID_LIQUIDACION,CODIGO_FICHA,TIPO_ACTIVIDAD,TIPO_PRESUPUESTO,CAPITULO_OBRA,ID_ACTIVIDAD_OBRA, SUBTOTAL_CAPITULO, CANTIDAD_OBRA
	FROM MR_TB_TMP_LIQ_CAPITULOS;

	COMMIT; 

    RETURN v_total;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END;
/