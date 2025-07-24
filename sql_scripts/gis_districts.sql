select
	comm_d
,	area
,	commission
,	shape_wkt = [SHAPE].STAsText()

from [GIS].[gisadmin].[DISTRICTS]
