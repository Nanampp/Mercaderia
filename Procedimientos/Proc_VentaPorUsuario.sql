-- =============================================
-- Author:		Adriana Palacio P.
-- Create date: 23/08/2018
-- Description: El reporte visualiza por localidad, terminal, día y usuario, la cantidad de clientes y el valor de la venta bruta, la venta neta, las anulaciones, las devoluciones, las cancelaciones, los préstamos y las recogidas para un rango de fechas específico y para un conjunto de localidades dadas.
-- =============================================
CREATE PROCEDURE [dbo].[Proc_VentaPorUsuario]
	-- Add the parameters for the stored procedure here
	@FechaInicial date, 
	@FechaFinal date,
	@Localidades varchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT  l.cod_localidad as codigo,
			l.descrip as localidad,
			v.cod_terminal, 
			v.id_usuario,
			u.nombre + ' ' + u.apellido AS usuario,
			CONVERT(date, v.date_created) AS fecha,
			"cod_tipo_transac"=
			--cambiar las ventas 0 con valor negativo por devoluciones
			CASE 
				WHEN v.cod_tipo_transac = '0' AND v.bruto_pstv = 0 AND v.bruto_ngtv <> 0 THEN '20' 
				ELSE v.cod_tipo_transac
			END,  
			vr.descrip, 
			"pstv" = 
			CASE 
				WHEN v.cod_tipo_transac = '3' THEN isnull(SUM(vmp.valor), 0) 
				ELSE v.bruto_pstv 
			END,
			 "ngtv" = 
			CASE 
				WHEN v.cod_tipo_transac = '4' THEN isnull(SUM(vmp.valor), 0) 
				ELSE v.bruto_ngtv 
			END, 
			"valormp" = 
			CASE 
				WHEN v.cod_tipo_transac = '0' THEN isnull(SUM(vmp.valor), 0) 
				ELSE 0 
			END, 
			1 AS nro
	FROM    venta AS v
	INNER JOIN localidad l ON l.cod_localidad = SUBSTRING(v.cod_terminal,1,3)
	INNER JOIN usuario u ON u.id_usuario = v.id_usuario
	LEFT JOIN ventas_recogida AS vr ON vr.id_venta = v.id_venta
	--tipo 3 y 4 en eva1 no tenían info en pstv y negtv sino solo en medios pago
	--solo obtener el pago con tarjeta (excluir el efectivo)
	LEFT JOIN ventas_medios_pago AS vmp ON vmp.id_venta = v.id_venta AND (v.id_tipo_transac IN ('3', '4') OR vmp.id_medio_pago <> '1') 
	WHERE   v.date_created BETWEEN DATEADD(dd,0,@fechaInicial)  AND DATEADD(dd,1,@fechaFinal)
			AND @Localidades LIKE ('%' + l.cod_localidad + '%') 
	GROUP BY l.cod_localidad, l.descrip, v.id_usuario, u.nombre + ' ' + u.apellido, v.id_venta, v.cod_terminal, CONVERT(date, v.date_created), v.cod_tipo_transac, CASE WHEN v.cod_tipo_transac = '0' AND v.bruto_pstv = 0 AND v.bruto_ngtv <> 0 THEN '20' ELSE v.cod_tipo_transac END, vr.descrip, v.bruto_pstv, v.bruto_ngtv
END
