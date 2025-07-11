/**********************************************************************      
$Archive  : FN_TOTAL_COSTOS_FICHA.sql
$Revision : $      
$Author   : CAD      
$Modtime  : $       
$History  : $   Metodo de Reposicion (MR)   
**********************************************************************/  
CREATE OR REPLACE FUNCTION FN_TOTAL_COSTOS_FICHA 
(
    p_codigo_ficha 			 IN VARCHAR2,
	p_grupo_uso_presupuesto  IN VARCHAR2
) RETURN NUMBER IS
    v_total_costos           NUMBER := 0;
    v_sql                    VARCHAR2(4000);
BEGIN

    -- Construir SQL dinámico según el grupo
    IF p_grupo_uso_presupuesto = 'PRESUPUESTO RESIDENCIAL' THEN
        v_sql := '
            SELECT SUM(LM.COSTO_UNITARIO_MATERIALES * AOM.CANTIDAD_MATERIALES)
            FROM MR_TB_LISTADO_MATERIALES_MANO_OBRA LM
            INNER JOIN MR_TB_ACTIVIDAD_OBRA_MATERIALES AOM ON LM.ID_MATERIALES = AOM.ID_MATERIALES
            INNER JOIN MR_TB_ACT_OBR_COD_FICHA_RES CF ON AOM.ID_ACTIVIDAD_OBRA = CF.ID_ACTIVIDAD_OBRA
            WHERE CF.CODIGO_FICHA = :1';
    ELSIF p_grupo_uso_presupuesto = 'PRESUPUESTO COMERCIAL' THEN
        v_sql := '
            SELECT SUM(LM.COSTO_UNITARIO_MATERIALES * AOM.CANTIDAD_MATERIALES)
            FROM MR_TB_LISTADO_MATERIALES_MANO_OBRA LM
            INNER JOIN MR_TB_ACTIVIDAD_OBRA_MATERIALES AOM ON LM.ID_MATERIALES = AOM.ID_MATERIALES
            INNER JOIN MR_TB_ACT_OBR_COD_FICHA_COM CF ON AOM.ID_ACTIVIDAD_OBRA = CF.ID_ACTIVIDAD_OBRA
            WHERE CF.CODIGO_FICHA = :1';
    ELSE
        RETURN 0;
    END IF;

    -- Ejecutar SQL dinámico
    BEGIN
        EXECUTE IMMEDIATE v_sql INTO v_total_costos USING p_codigo_ficha;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al ejecutar la consulta dinámica: ' || SQLERRM);
            RETURN NULL;
    END;

    RETURN NVL(v_total_costos, 0);
END;
