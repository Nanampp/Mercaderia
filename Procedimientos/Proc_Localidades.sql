USE [eva]
GO
/****** Object:  StoredProcedure [dbo].[Proc_Empresa]    Script Date: 13/08/2018 16:46:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Adriana Palacio P.
-- Create date: 03/08/2018
-- Description:	Obtiene las localidades
-- =============================================
ALTER PROCEDURE Proc_Localidades 
	-- Add the parameters for the stored procedure here
	@Ciudad varchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select	l.cod_localidad Codigo_Localidad, 
	l.cod_localidad + ' - ' + l.descrip CodLocalidad
	from dbo.localidad l 
	LEFT JOIN ciudad c ON c.id_ciudad = l.id_ciudad
	where tipo = 'LOCAL' and cerrada = 0 and cod_localidad <> 'C01'
		AND @Ciudad LIKE ('%' + c.id_ciudad + '%')
END
GO

