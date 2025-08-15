/**********************************************************************      
$Archive  : FN_TOTAL_COSTOS_FICHA.sql
$Revision : $      
$Author   : CAD      
$Modtime  : $       
$History  : $   Metodo de Reposicion (MR)   
SET SERVEROUTPUT ON;
---
--1:Presupuesto Independiente
SELECT FN_EJECUTAR_REGLA_CALCULO('AREA_PRIMER_PISO',1, 1, NULL, NULL, 120, 2) AS AREA_PRIMER_PISO FROM DUAL;
SELECT FN_EJECUTAR_REGLA_CALCULO('FRENTE',1, 1, NULL, NULL, 120, 2) AS FRENTE FROM DUAL;
SELECT FN_EJECUTAR_REGLA_CALCULO('FONDO',1, 1, NULL, NULL, 120, 2) AS FRENTE FROM DUAL;
SELECT FN_EJECUTAR_REGLA_CALCULO('N_UNIDADES_USO_PRINCIPAL',1, 1, NULL, NULL, 120, 2) AS N_UNIDADES_USO_PRINCIPAL FROM DUAL;
SELECT FN_EJECUTAR_REGLA_CALCULO('N_UNIDADES_USO_PRINCIPAL',1, 1, '001', '1', 501, 2) AS N_UNIDADES_USO_PRINCIPAL FROM DUAL;
SELECT FN_EJECUTAR_REGLA_CALCULO('AREA_TIPO_UNIDAD_USO',1, 1, NULL, NULL, 120, 2) AS AREA_TIPO_UNIDAD_USO FROM DUAL;
SELECT FN_EJECUTAR_REGLA_CALCULO('N_UNIDADES_USO',1, 1, NULL, NULL, 120, 2) AS N_UNIDADES_USO FROM DUAL;
SELECT FN_EJECUTAR_REGLA_CALCULO('N_ESPACIOS',1, 1, NULL, NULL, 120, 2) AS N_ESPACIOS FROM DUAL;
SELECT FN_EJECUTAR_REGLA_CALCULO('N_BAÑOS',1, 1, NULL, NULL, 120, 2) AS N_BAÑOS FROM DUAL;
SELECT FN_EJECUTAR_REGLA_CALCULO('N_COCINAS',1, 1, NULL, NULL, 120, 2) AS N_COCINAS FROM DUAL;
SELECT FN_EJECUTAR_REGLA_CALCULO('N_PISOS',1, 1, '014', NULL, 120, 2) AS N_PISOS FROM DUAL;


--2:Presupuesto Predominante
SELECT FN_EJECUTAR_REGLA_CALCULO('AREA_PRIMER_PISO',2, 1, NULL, NULL, 120, 2) AS AREA_PRIMER_PISO FROM DUAL;
SELECT FN_EJECUTAR_REGLA_CALCULO('FRENTE',2, 1, NULL, NULL, 120, 2) AS FRENTE FROM DUAL;
SELECT FN_EJECUTAR_REGLA_CALCULO('FONDO',2, 1, NULL, NULL, 120, 2) AS FRENTE FROM DUAL;
SELECT FN_EJECUTAR_REGLA_CALCULO('N_UNIDADES_USO_PRINCIPAL',2, 1, NULL, NULL, 120, 2) AS N_UNIDADES_USO_PRINCIPAL FROM DUAL;
SELECT FN_EJECUTAR_REGLA_CALCULO('N_UNIDADES_USO_PRINCIPAL',2, 1, '001', '1', 501, 2) AS N_UNIDADES_USO_PRINCIPAL FROM DUAL;
SELECT FN_EJECUTAR_REGLA_CALCULO('AREA_TIPO_UNIDAD_USO',2, 1, NULL, NULL, 120, 2) AS AREA_TIPO_UNIDAD_USO FROM DUAL;
SELECT FN_EJECUTAR_REGLA_CALCULO('N_UNIDADES_USO',2, 1, NULL, NULL, 120, 2) AS N_UNIDADES_USO FROM DUAL;
SELECT FN_EJECUTAR_REGLA_CALCULO('N_ESPACIOS',2, 1, NULL, NULL, 120, 2) AS N_ESPACIOS FROM DUAL;
SELECT FN_EJECUTAR_REGLA_CALCULO('N_BAÑOS',1, 2, NULL, NULL, 120, 2) AS N_BAÑOS FROM DUAL;
SELECT FN_EJECUTAR_REGLA_CALCULO('N_COCINAS',1, 2, NULL, NULL, 120, 2) AS N_COCINAS FROM DUAL;
SELECT FN_EJECUTAR_REGLA_CALCULO('N_PISOS',1, 2, '014', NULL, 120, 2) AS N_PISOS FROM DUAL;

**********************************************************************/  

CREATE OR REPLACE FUNCTION FN_EJECUTAR_REGLA_CALCULO 
(
    p_variable              	IN VARCHAR2,										--AREA_PRIMER_PISO
	p_tipo_presupuesto       	IN NUMBER,     										--1:Presupuesto Independiente, 2:Presupuesto Predominante 
    p_grupo_uso_cantidades  	IN NUMBER,											--
    p_codigo_uso            	IN VARCHAR2,
    p_codigo_estrato        	IN NUMBER,
    p_area_uso              	IN NUMBER,
    p_n_pisos               	IN NUMBER DEFAULT 1
) RETURN NUMBER
IS
    v_area_primer_piso        	NUMBER;
    v_frente                  	NUMBER;
    v_fondo                   	NUMBER;
    v_resultado               	NUMBER;
    v_unidades_uso_principal  	NUMBER;
BEGIN
    -- 1. AREA_PRIMER_PISO => 1:PRESUPUESTO INDEPENDIENTE
    IF p_variable = 'AREA_PRIMER_PISO' AND p_tipo_presupuesto = 1 THEN
        IF p_grupo_uso_cantidades IN (1,2,6,7,8,9) THEN
            RETURN ROUND(p_area_uso / NULLIF(p_n_pisos, 0),2);
        ELSE
            RETURN ROUND(p_area_uso,2);
        END IF;

    -- 1. AREA_PRIMER_PISO => 2:PRESUPUESTO PREDOMINANTE
    ELSIF p_variable = 'AREA_PRIMER_PISO' AND p_tipo_presupuesto = 2 THEN
        IF p_grupo_uso_cantidades IN (1,2,6,7,8,9) THEN
            RETURN ROUND(p_area_uso / NULLIF(p_n_pisos, 0),2);
        ELSE
            RETURN ROUND(p_area_uso,2);
        END IF;

    -- 2. FRENTE => 1:PRESUPUESTO INDEPENDIENTE
    ELSIF p_variable = 'FRENTE' AND p_tipo_presupuesto = 1 THEN
        v_area_primer_piso := FN_EJECUTAR_REGLA_CALCULO('AREA_PRIMER_PISO',p_tipo_presupuesto ,p_grupo_uso_cantidades, p_codigo_uso, p_codigo_estrato, p_area_uso, p_n_pisos);
        IF p_grupo_uso_cantidades IN (3,4,5) THEN
            RETURN ROUND(SQRT(v_area_primer_piso / 2),2);
        ELSE
            RETURN ROUND(SQRT(v_area_primer_piso / 3),2);
        END IF;

    -- 2. FRENTE => 2:PRESUPUESTO PREDOMINANTE
    ELSIF p_variable = 'FRENTE' AND p_tipo_presupuesto = 2 THEN
        v_area_primer_piso := FN_EJECUTAR_REGLA_CALCULO('AREA_PRIMER_PISO',p_tipo_presupuesto ,p_grupo_uso_cantidades, p_codigo_uso, p_codigo_estrato, p_area_uso, p_n_pisos);
        IF p_grupo_uso_cantidades IN (3,4,5) THEN
            RETURN ROUND(SQRT(v_area_primer_piso / 2),2);
        ELSE
            RETURN ROUND(SQRT(v_area_primer_piso / 3),2);
        END IF;

    -- 3. FONDO => 1:PRESUPUESTO INDEPENDIENTE
    ELSIF p_variable = 'FONDO' AND p_tipo_presupuesto = 1 THEN
        v_area_primer_piso := FN_EJECUTAR_REGLA_CALCULO('AREA_PRIMER_PISO',p_tipo_presupuesto ,p_grupo_uso_cantidades, p_codigo_uso, p_codigo_estrato, p_area_uso, p_n_pisos);
        v_frente := FN_EJECUTAR_REGLA_CALCULO('FRENTE',p_tipo_presupuesto, p_grupo_uso_cantidades, p_codigo_uso, p_codigo_estrato, p_area_uso, p_n_pisos);
        RETURN ROUND(v_area_primer_piso / NULLIF(v_frente, 0),2);

    -- 3. FONDO => 2:PRESUPUESTO PREDOMINANTE
    ELSIF p_variable = 'FONDO' AND p_tipo_presupuesto = 1 THEN
        v_area_primer_piso := FN_EJECUTAR_REGLA_CALCULO('AREA_PRIMER_PISO',p_tipo_presupuesto ,p_grupo_uso_cantidades, p_codigo_uso, p_codigo_estrato, p_area_uso, p_n_pisos);
        v_frente := FN_EJECUTAR_REGLA_CALCULO('FRENTE',p_tipo_presupuesto, p_grupo_uso_cantidades, p_codigo_uso, p_codigo_estrato, p_area_uso, p_n_pisos);
        RETURN ROUND(v_area_primer_piso / NULLIF(v_frente, 0),2);

    -- 4. N_UNIDADES_USO_PRINCIPAL => 1:PRESUPUESTO INDEPENDIENTE
    ELSIF p_variable = 'N_UNIDADES_USO_PRINCIPAL' AND p_tipo_presupuesto = 1  THEN
        IF p_grupo_uso_cantidades = 2 AND p_codigo_uso IN ('003', '004') THEN
            RETURN ROUND(CEIL(p_area_uso / 41),2);
        ELSIF p_grupo_uso_cantidades = 2 AND p_codigo_uso NOT IN ('003', '004') THEN
            RETURN 1;
        ELSIF p_grupo_uso_cantidades = 3 THEN
            RETURN ROUND(CEIL(p_area_uso / 1000),2);
        ELSIF p_grupo_uso_cantidades = 4 THEN
            RETURN ROUND(CEIL(p_area_uso / 1500),2);
        ELSIF p_grupo_uso_cantidades = 5 THEN
            RETURN ROUND(CEIL(p_area_uso / 2000),2);
        ELSIF p_grupo_uso_cantidades = 6 THEN
            RETURN ROUND(CEIL(p_area_uso / 15),2);
        ELSIF p_grupo_uso_cantidades = 8 THEN
            RETURN ROUND(CEIL((p_area_uso / 65) + 1),2);
        ELSIF p_grupo_uso_cantidades = 7 AND p_area_uso > 500 THEN
            RETURN ROUND(CEIL(p_area_uso / 69),2);
        ELSIF p_grupo_uso_cantidades = 9 AND p_area_uso > 500 THEN
            RETURN ROUND(CEIL(p_area_uso / 24),2);
		ELSIF p_area_uso = 0 THEN
			RETURN 0;
		ELSIF p_area_uso <= 35 THEN
			RETURN 1;
		ELSIF p_area_uso > 35 AND p_area_uso <= 50 THEN
			RETURN 2;
		ELSIF p_area_uso > 50 AND p_area_uso <= 150 THEN
			RETURN 3;
		ELSIF p_area_uso > 150 AND p_area_uso <= 200 THEN
			RETURN 4;
		ELSIF p_area_uso > 200 AND p_area_uso <= 300 THEN
			RETURN 5;
		ELSIF p_area_uso > 300 AND p_area_uso <= 400 THEN
			RETURN 6;
		ELSIF p_area_uso > 400 AND p_area_uso <= 500 THEN
			RETURN 7;
		ELSIF p_area_uso > 500 AND p_codigo_uso IN ('001','002') AND p_codigo_estrato IN (1,2) THEN
			RETURN ROUND(p_area_uso / 45, 2);
		ELSIF p_area_uso > 500 AND p_codigo_uso IN ('001','002') AND p_codigo_estrato = 3 THEN
			RETURN ROUND(p_area_uso / 48, 2);
		ELSIF p_area_uso > 500 AND p_codigo_uso IN ('001','002') AND p_codigo_estrato = 4 THEN
			RETURN ROUND(p_area_uso / 64, 2);
		ELSIF p_area_uso > 500 AND p_codigo_uso IN ('001','002') AND p_codigo_estrato = 5 THEN
			RETURN ROUND(p_area_uso / 80, 2);
		ELSIF p_area_uso > 500 AND p_codigo_uso IN ('001','002') AND p_codigo_estrato = 6 THEN
			RETURN ROUND(p_area_uso / 110, 2);
        ELSE
            RETURN ROUND(p_n_pisos,2);
        END IF;

   -- 4. N_UNIDADES_USO_PRINCIPAL => 2:PRESUPUESTO PREDOMINANTE
    ELSIF p_variable = 'N_UNIDADES_USO_PRINCIPAL' AND p_tipo_presupuesto = 2  THEN
        IF p_grupo_uso_cantidades = 2 AND p_codigo_uso IN ('003', '004') THEN
            RETURN ROUND(CEIL(p_area_uso / 41),2);
        ELSIF p_grupo_uso_cantidades = 2 AND p_codigo_uso NOT IN ('003', '004') THEN
            RETURN 1;
        ELSIF p_grupo_uso_cantidades = 3 THEN
            RETURN ROUND(CEIL(p_area_uso / 1000),2);
        ELSIF p_grupo_uso_cantidades = 4 THEN
            RETURN ROUND(CEIL(p_area_uso / 1500),2);
        ELSIF p_grupo_uso_cantidades = 5 THEN
            RETURN ROUND(CEIL(p_area_uso / 2000),2);
        ELSIF p_grupo_uso_cantidades = 6 THEN
            RETURN ROUND(CEIL(p_area_uso / 15),2);
        ELSIF p_grupo_uso_cantidades = 8 THEN
            RETURN ROUND(CEIL((p_area_uso / 65) + 1),2);
        ELSIF p_grupo_uso_cantidades = 7 AND p_area_uso > 500 THEN
            RETURN ROUND(CEIL(p_area_uso / 69),2);
        ELSIF p_grupo_uso_cantidades = 9 AND p_area_uso > 500 THEN
            RETURN ROUND(CEIL(p_area_uso / 24),2);
		ELSIF p_area_uso = 0 THEN
			RETURN 0;
		ELSIF p_area_uso <= 35 THEN
			RETURN 1;
		ELSIF p_area_uso > 35 AND p_area_uso <= 50 THEN
			RETURN 2;
		ELSIF p_area_uso > 50 AND p_area_uso <= 150 THEN
			RETURN 3;
		ELSIF p_area_uso > 150 AND p_area_uso <= 200 THEN
			RETURN 4;
		ELSIF p_area_uso > 200 AND p_area_uso <= 300 THEN
			RETURN 5;
		ELSIF p_area_uso > 300 AND p_area_uso <= 400 THEN
			RETURN 6;
		ELSIF p_area_uso > 400 AND p_area_uso <= 500 THEN
			RETURN 7;
		ELSIF p_area_uso > 500 AND p_codigo_uso IN ('001','002') AND p_codigo_estrato IN (1,2) THEN
			RETURN ROUND(p_area_uso / 45, 2);
		ELSIF p_area_uso > 500 AND p_codigo_uso IN ('001','002') AND p_codigo_estrato = 3 THEN
			RETURN ROUND(p_area_uso / 48, 2);
		ELSIF p_area_uso > 500 AND p_codigo_uso IN ('001','002') AND p_codigo_estrato = 4 THEN
			RETURN ROUND(p_area_uso / 64, 2);
		ELSIF p_area_uso > 500 AND p_codigo_uso IN ('001','002') AND p_codigo_estrato = 5 THEN
			RETURN ROUND(p_area_uso / 80, 2);
		ELSIF p_area_uso > 500 AND p_codigo_uso IN ('001','002') AND p_codigo_estrato = 6 THEN
			RETURN ROUND(p_area_uso / 110, 2);
        ELSE
            RETURN ROUND(p_n_pisos,2);
        END IF;

    -- 5. AREA_TIPO_UNIDAD_USO => 1:PRESUPUESTO INDEPENDIENTE
    ELSIF p_variable = 'AREA_TIPO_UNIDAD_USO' AND p_tipo_presupuesto = 1 THEN
        IF p_area_uso <= 500 THEN
            v_unidades_uso_principal := FN_EJECUTAR_REGLA_CALCULO('N_UNIDADES_USO_PRINCIPAL',p_tipo_presupuesto ,p_grupo_uso_cantidades, p_codigo_uso, p_codigo_estrato, p_area_uso, p_n_pisos);
            RETURN ROUND(p_area_uso / NULLIF(v_unidades_uso_principal, 0), 2);
        ELSIF p_codigo_uso IN ('001','002') THEN
            CASE p_codigo_estrato
                WHEN 1 THEN RETURN 45;
                WHEN 2 THEN RETURN 45;
                WHEN 3 THEN RETURN 48;
                WHEN 4 THEN RETURN 64;
                WHEN 5 THEN RETURN 80;
                WHEN 6 THEN RETURN 110;
            END CASE;
        ELSIF p_codigo_uso IN ('003','004') THEN RETURN 41;
        ELSIF p_grupo_uso_cantidades = 9 	THEN RETURN 24;
        ELSIF p_codigo_uso = '017' 			THEN RETURN 10;
        ELSIF p_codigo_uso IN ('026','027') THEN RETURN 25;
        ELSIF p_codigo_uso = '021' 			THEN RETURN 65;
        ELSIF p_grupo_uso_cantidades = 7 	THEN RETURN 69;
        ELSE RETURN p_area_uso;
        END IF;

    -- 5. AREA_TIPO_UNIDAD_USO => 2:PRESUPUESTO PREDOMINANTE
    ELSIF p_variable = 'AREA_TIPO_UNIDAD_USO' AND p_tipo_presupuesto = 2 THEN
        IF p_area_uso <= 500 THEN
            v_unidades_uso_principal := FN_EJECUTAR_REGLA_CALCULO('N_UNIDADES_USO_PRINCIPAL',p_tipo_presupuesto ,p_grupo_uso_cantidades, p_codigo_uso, p_codigo_estrato, p_area_uso, p_n_pisos);
            RETURN ROUND(p_area_uso / NULLIF(v_unidades_uso_principal, 0), 2);
        ELSIF p_codigo_uso IN ('001','002') THEN
            CASE p_codigo_estrato
                WHEN 1 THEN RETURN 45;
                WHEN 2 THEN RETURN 45;
                WHEN 3 THEN RETURN 48;
                WHEN 4 THEN RETURN 64;
                WHEN 5 THEN RETURN 80;
                WHEN 6 THEN RETURN 110;
            END CASE;
        ELSIF p_codigo_uso IN ('003','004') THEN RETURN 41;
        ELSIF p_grupo_uso_cantidades = 9 	THEN RETURN 24;
        ELSIF p_codigo_uso = '017' 			THEN RETURN 10;
        ELSIF p_codigo_uso IN ('026','027') THEN RETURN 25;
        ELSIF p_codigo_uso = '021' 			THEN RETURN 65;
        ELSIF p_grupo_uso_cantidades = 7 	THEN RETURN 69;
        ELSE RETURN p_area_uso;
        END IF;    
	
	-- 6. N_UNIDADES_USO  => 1:PRESUPUESTO INDEPENDIENTE
    ELSIF p_variable = 'N_UNIDADES_USO' AND p_tipo_presupuesto = 1 THEN
        v_area_primer_piso := FN_EJECUTAR_REGLA_CALCULO('AREA_PRIMER_PISO',p_tipo_presupuesto ,p_grupo_uso_cantidades, p_codigo_uso, p_codigo_estrato, p_area_uso, p_n_pisos);
        v_resultado := FN_EJECUTAR_REGLA_CALCULO('AREA_TIPO_UNIDAD_USO',p_tipo_presupuesto ,p_grupo_uso_cantidades, p_codigo_uso, p_codigo_estrato, p_area_uso, p_n_pisos);
        RETURN FLOOR(v_area_primer_piso / NULLIF(v_resultado, 0));

	-- 6. N_UNIDADES_USO  => 2:PRESUPUESTO PREDOMINANTE
    ELSIF p_variable = 'N_UNIDADES_USO' AND p_tipo_presupuesto = 2 THEN
        v_area_primer_piso := FN_EJECUTAR_REGLA_CALCULO('AREA_PRIMER_PISO',p_tipo_presupuesto ,p_grupo_uso_cantidades, p_codigo_uso, p_codigo_estrato, p_area_uso, p_n_pisos);
        v_resultado := FN_EJECUTAR_REGLA_CALCULO('AREA_TIPO_UNIDAD_USO',p_tipo_presupuesto ,p_grupo_uso_cantidades, p_codigo_uso, p_codigo_estrato, p_area_uso, p_n_pisos);
        RETURN FLOOR(v_area_primer_piso / NULLIF(v_resultado, 0));


    -- 7. N_ESPACIOS   => 1:PRESUPUESTO INDEPENDIENTE
    ELSIF p_variable = 'N_ESPACIOS' AND p_tipo_presupuesto = 1  THEN
        IF p_grupo_uso_cantidades = 2 AND p_codigo_uso IN ('003', '004') THEN
            RETURN ROUND(CEIL(p_area_uso / 41),2);
        ELSIF p_grupo_uso_cantidades = 2 AND p_codigo_uso NOT IN ('003', '004') THEN
            RETURN 1;
        ELSIF p_grupo_uso_cantidades = 3 THEN RETURN ROUND(CEIL(p_area_uso / 1000),2);
        ELSIF p_grupo_uso_cantidades = 4 THEN RETURN ROUND(CEIL(p_area_uso / 1500),2);
        ELSIF p_grupo_uso_cantidades = 5 THEN RETURN ROUND(CEIL(p_area_uso / 2000),2);
        ELSIF p_grupo_uso_cantidades = 6 THEN RETURN ROUND(p_area_uso / 15);
        ELSIF p_grupo_uso_cantidades = 8 THEN RETURN FLOOR(p_area_uso / 65) + 1;
        ELSIF p_grupo_uso_cantidades = 7 AND p_area_uso > 500 THEN RETURN ROUND(CEIL(p_area_uso / 69),2);
        ELSIF p_grupo_uso_cantidades = 9 AND p_area_uso > 500 THEN RETURN ROUND(CEIL(p_area_uso / 24),2);
        ELSIF p_area_uso = 0 	THEN RETURN 0;
        ELSIF p_area_uso <= 35 	THEN RETURN 1;
        ELSIF p_area_uso <= 50 	THEN RETURN 2;
        ELSIF p_area_uso <= 150 THEN RETURN 3;
        ELSIF p_area_uso <= 200 THEN RETURN 4;
        ELSIF p_area_uso <= 300 THEN RETURN 5;
        ELSIF p_area_uso <= 400 THEN RETURN 6;
        ELSIF p_area_uso <= 500 THEN RETURN 7;
        ELSE
            v_unidades_uso_principal := FN_EJECUTAR_REGLA_CALCULO('N_UNIDADES_USO_PRINCIPAL',p_tipo_presupuesto ,p_grupo_uso_cantidades, p_codigo_uso, p_codigo_estrato, p_area_uso, p_n_pisos);
            IF p_codigo_estrato IN (1, 2) THEN RETURN 2 * v_unidades_uso_principal;
            ELSIF p_codigo_estrato IN (3, 4) THEN RETURN 3 * v_unidades_uso_principal;
            ELSE RETURN 4 * v_unidades_uso_principal;
            END IF;
        END IF;

    -- 7. N_ESPACIOS   => 2:PRESUPUESTO PREDOMINANTE
    ELSIF p_variable = 'N_ESPACIOS' AND p_tipo_presupuesto = 2  THEN
        IF p_grupo_uso_cantidades = 2 AND p_codigo_uso IN ('003', '004') THEN
            RETURN ROUND(CEIL(p_area_uso / 41),2);
        ELSIF p_grupo_uso_cantidades = 2 AND p_codigo_uso NOT IN ('003', '004') THEN
            RETURN 1;
        ELSIF p_grupo_uso_cantidades = 3 THEN RETURN ROUND(CEIL(p_area_uso / 1000),2);
        ELSIF p_grupo_uso_cantidades = 4 THEN RETURN ROUND(CEIL(p_area_uso / 1500),2);
        ELSIF p_grupo_uso_cantidades = 5 THEN RETURN ROUND(CEIL(p_area_uso / 2000),2);
        ELSIF p_grupo_uso_cantidades = 6 THEN RETURN ROUND(p_area_uso / 15);
        ELSIF p_grupo_uso_cantidades = 8 THEN RETURN FLOOR(p_area_uso / 65) + 1;
        ELSIF p_grupo_uso_cantidades = 7 AND p_area_uso > 500 THEN RETURN ROUND(CEIL(p_area_uso / 69),2);
        ELSIF p_grupo_uso_cantidades = 9 AND p_area_uso > 500 THEN RETURN ROUND(CEIL(p_area_uso / 24),2);
        ELSIF p_area_uso = 0 	THEN RETURN 0;
        ELSIF p_area_uso <= 35 	THEN RETURN 1;
        ELSIF p_area_uso <= 50 	THEN RETURN 2;
        ELSIF p_area_uso <= 150 THEN RETURN 3;
        ELSIF p_area_uso <= 200 THEN RETURN 4;
        ELSIF p_area_uso <= 300 THEN RETURN 5;
        ELSIF p_area_uso <= 400 THEN RETURN 6;
        ELSIF p_area_uso <= 500 THEN RETURN 7;
        ELSE
            v_unidades_uso_principal := FN_EJECUTAR_REGLA_CALCULO('N_UNIDADES_USO_PRINCIPAL',p_tipo_presupuesto ,p_grupo_uso_cantidades, p_codigo_uso, p_codigo_estrato, p_area_uso, p_n_pisos);
            IF p_codigo_estrato IN (1, 2) THEN RETURN 2 * v_unidades_uso_principal;
            ELSIF p_codigo_estrato IN (3, 4) THEN RETURN 3 * v_unidades_uso_principal;
            ELSE RETURN 4 * v_unidades_uso_principal;
            END IF;
        END IF;

    -- 8. N_BAÑOS => 1:PRESUPUESTO INDEPENDIENTE
    ELSIF p_variable = 'N_BAÑOS' AND p_tipo_presupuesto = 1  THEN
        IF p_grupo_uso_cantidades = 6 		THEN RETURN ROUND(p_area_uso / 15);
        ELSIF p_grupo_uso_cantidades = 8 	THEN RETURN FLOOR(p_area_uso / 65) + 1;
		ELSIF p_grupo_uso_cantidades = 2    THEN RETURN FN_EJECUTAR_REGLA_CALCULO('N_UNIDADES_USO_PRINCIPAL', p_grupo_uso_cantidades, p_codigo_uso, p_codigo_estrato, p_area_uso, p_n_pisos);
        ELSIF p_grupo_uso_cantidades IN (3,4,5) THEN RETURN 1;
        ELSIF p_grupo_uso_cantidades IN (7,9) THEN
            v_resultado := FN_EJECUTAR_REGLA_CALCULO('N_UNIDADES_USO',p_tipo_presupuesto, p_grupo_uso_cantidades, p_codigo_uso, p_codigo_estrato, p_area_uso, p_n_pisos);
            IF v_resultado / 30 > 1 THEN
                RETURN ROUND(v_resultado / 30) * p_n_pisos;
            ELSE
                RETURN 1 * p_n_pisos;
            END IF;
        ELSIF p_codigo_uso IN ('311','0') OR p_codigo_uso IS NULL THEN
            RETURN 0;
        ELSIF p_area_uso <= 500 AND p_codigo_uso <> '311' THEN
            RETURN p_n_pisos ;
        ELSE
            v_unidades_uso_principal := FN_EJECUTAR_REGLA_CALCULO('N_UNIDADES_USO_PRINCIPAL',p_tipo_presupuesto ,p_grupo_uso_cantidades, p_codigo_uso, p_codigo_estrato, p_area_uso, p_n_pisos);
            IF p_codigo_estrato IN (1,2) THEN RETURN 1 * v_unidades_uso_principal;
            ELSIF p_codigo_estrato IN (3,4) THEN RETURN 2 * v_unidades_uso_principal;
            ELSE RETURN 3 * v_unidades_uso_principal;
            END IF;
        END IF;
		

    -- 8. N_BAÑOS => 2:PRESUPUESTO PREDOMINANTE
    ELSIF p_variable = 'N_BAÑOS' AND p_tipo_presupuesto = 2  THEN
        IF p_grupo_uso_cantidades = 6 		THEN RETURN ROUND(p_area_uso / 15);
        ELSIF p_grupo_uso_cantidades = 8 	THEN RETURN FLOOR(p_area_uso / 65) + 1;
        ELSIF p_grupo_uso_cantidades = 2    THEN RETURN FN_EJECUTAR_REGLA_CALCULO('N_UNIDADES_USO_PRINCIPAL', p_grupo_uso_cantidades, p_codigo_uso, p_codigo_estrato, p_area_uso, p_n_pisos);
        ELSIF p_grupo_uso_cantidades IN (3,4,5) THEN RETURN 1;
        ELSIF p_grupo_uso_cantidades IN (7,9) THEN
            v_resultado := FN_EJECUTAR_REGLA_CALCULO('N_UNIDADES_USO',p_tipo_presupuesto, p_grupo_uso_cantidades, p_codigo_uso, p_codigo_estrato, p_area_uso, p_n_pisos);
            IF v_resultado / 30 > 1 THEN
                RETURN ROUND(v_resultado / 30) * p_n_pisos;
            ELSE
                RETURN 1 * p_n_pisos;
            END IF;
        ELSIF p_codigo_uso IN ('311','0') OR p_codigo_uso IS NULL THEN
            RETURN 0;
        ELSIF p_area_uso <= 500 AND p_codigo_uso <> '311' THEN
            RETURN p_n_pisos ;
        ELSE
            v_unidades_uso_principal := FN_EJECUTAR_REGLA_CALCULO('N_UNIDADES_USO_PRINCIPAL',p_tipo_presupuesto ,p_grupo_uso_cantidades, p_codigo_uso, p_codigo_estrato, p_area_uso, p_n_pisos);
            IF p_codigo_estrato IN (1,2) THEN RETURN 1 * v_unidades_uso_principal;
            ELSIF p_codigo_estrato IN (3,4) THEN RETURN 2 * v_unidades_uso_principal;
            ELSE RETURN 3 * v_unidades_uso_principal;
            END IF;
        END IF;

    -- 9. N_COCINAS => 1:PRESUPUESTO INDEPENDIENTE
    ELSIF p_variable = 'N_COCINAS' AND p_tipo_presupuesto = 1  THEN
        IF p_codigo_uso IN ('021','029','030','056','065','017') THEN
            RETURN 1;
        ELSIF p_codigo_estrato IN (411, 0) OR p_codigo_estrato IS NULL THEN
            RETURN 0;
        ELSIF p_area_uso < 500 THEN
            RETURN 1;
        ELSE
            RETURN FN_EJECUTAR_REGLA_CALCULO('N_UNIDADES_USO_PRINCIPAL',p_tipo_presupuesto ,p_grupo_uso_cantidades, p_codigo_uso, p_codigo_estrato, p_area_uso, p_n_pisos);
        END IF;

	-- 9. N_COCINAS => 2:PRESUPUESTO PREDOMINANTE
    ELSIF p_variable = 'N_COCINAS' AND p_tipo_presupuesto = 2  THEN
        IF p_codigo_uso IN ('021','029','030','056','065','017') THEN
            RETURN 1;
        ELSIF p_codigo_estrato IN (411, 0) OR p_codigo_estrato IS NULL THEN
            RETURN 0;
        ELSIF p_area_uso < 500 THEN
            RETURN 1;
        ELSE
            RETURN FN_EJECUTAR_REGLA_CALCULO('N_UNIDADES_USO_PRINCIPAL',p_tipo_presupuesto ,p_grupo_uso_cantidades, p_codigo_uso, p_codigo_estrato, p_area_uso, p_n_pisos);
        END IF;

	-- 10. N_COCINAS => 1:PRESUPUESTO INDEPENDIENTE
    ELSIF p_variable = 'N_PISOS' AND p_tipo_presupuesto = 1  THEN
		IF p_n_pisos > 3 AND p_codigo_uso IN ('014', '025', '032', '033', '064', '070', '071', '072', '074', '075', '076') THEN
			RETURN 1;
		ELSE
			RETURN p_n_pisos;
		END IF;

	-- 10. N_COCINAS => 2:PRESUPUESTO PREDOMINANTE
    ELSIF p_variable = 'N_PISOS' AND p_tipo_presupuesto = 2  THEN
		IF p_n_pisos > 3 AND p_codigo_uso IN ('014', '025', '032', '033', '064', '070', '071', '072', '074', '075', '076') THEN
			RETURN 1;
		ELSE
			RETURN p_n_pisos;
		END IF;
    END IF;

    RETURN NULL;
END;
/
