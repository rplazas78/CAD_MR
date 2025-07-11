/**********************************************************************      
$Archive  : FN_TOTAL_COSTOS_FICHA.sql
$Revision : $      
$Author   : CAD      
$Modtime  : $       
$History  : $   Metodo de Reposicion (MR)   
SELECT FN_TOTAL_COSTOS_FICHA(115, 'PRESUPUESTO RESIDENCIAL', 2025, 'HMEN_01') AS TOTAL FROM DUAL;
**********************************************************************/  
CREATE OR REPLACE FUNCTION FN_TOTAL_COSTOS_FICHA 
(
    p_codigo_ficha     IN NUMBER,
    p_tipo_presupuesto IN VARCHAR2,  -- 'PRESUPUESTO RESIDENCIAL' o 'PRESUPUESTO COMERCIAL'
    p_vigencia         IN NUMBER,
    p_material_ajuste  IN VARCHAR2   -- 'HMEN_01'
) RETURN NUMBER
IS
    v_total NUMBER := 0;
BEGIN
    IF p_tipo_presupuesto = 'PRESUPUESTO RESIDENCIAL' THEN
		SELECT 
		SUM
		(
			CASE 
				WHEN T.CANT_HMEN IS NOT NULL
				THEN T.SUBTOTAL + (T.SUBTOTAL * T.CANT_HMEN)
				ELSE T.SUBTOTAL
			END
		) 
        INTO v_total
        FROM 
		(
            SELECT CF.ID_ACTIVIDAD_OBRA, 
                   SUM(LM.COSTO_UNITARIO_MATERIAL * AOM.CANTIDAD_MATERIAL) AS SUBTOTAL, 
                   MAX(CASE WHEN AOM.ID_MATERIAL = P_material_ajuste THEN AOM.CANTIDAD_MATERIAL END) AS CANT_HMEN
            FROM MR_TB_LISTADO_MATERIAL_MANO_OBRA LM
            INNER JOIN MR_TB_ACTIVIDAD_OBRA_MATERIAL AOM ON LM.ID_MATERIAL = AOM.ID_MATERIAL
            INNER JOIN MR_TB_ACT_OBR_COD_FICHA_RES CF ON AOM.ID_ACTIVIDAD_OBRA = CF.ID_ACTIVIDAD_OBRA
            WHERE CF.CODIGO_FICHA = p_codigo_ficha AND CF.VIGENCIA = p_vigencia
            --AND CF.ID_ACTIVIDAD_OBRA = 'PRELIM_01'
            GROUP BY CF.ID_ACTIVIDAD_OBRA
        ) T;

    ELSIF p_tipo_presupuesto = 'PRESUPUESTO COMERCIAL' THEN
		SELECT 
		SUM
		(
			CASE 
				WHEN T.CANT_HMEN IS NOT NULL
				THEN T.SUBTOTAL + (T.SUBTOTAL * T.CANT_HMEN)
				ELSE T.SUBTOTAL
			END
		) 
        INTO v_total
        FROM 
		(
            SELECT CF.ID_ACTIVIDAD_OBRA, 
                   SUM(LM.COSTO_UNITARIO_MATERIAL * AOM.CANTIDAD_MATERIAL) AS SUBTOTAL, 
                   MAX(CASE WHEN AOM.ID_MATERIAL = p_material_ajuste THEN AOM.CANTIDAD_MATERIAL END) AS CANT_HMEN
            FROM MR_TB_LISTADO_MATERIAL_MANO_OBRA LM
            INNER JOIN MR_TB_ACTIVIDAD_OBRA_MATERIAL AOM ON LM.ID_MATERIAL = AOM.ID_MATERIAL
            INNER JOIN MR_TB_ACT_OBR_COD_FICHA_COM CF ON AOM.ID_ACTIVIDAD_OBRA = CF.ID_ACTIVIDAD_OBRA
            WHERE CF.CODIGO_FICHA = p_codigo_ficha AND CF.VIGENCIA = p_vigencia
            --AND CF.ID_ACTIVIDAD_OBRA = 'PRELIM_01'
            GROUP BY CF.ID_ACTIVIDAD_OBRA
        ) T;
    END IF;

    RETURN ROUND(NVL(v_total, 0), 2);

EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END;
/