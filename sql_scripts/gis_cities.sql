select
	name
,	shape_wkt = [SHAPE].STAsText()

from [gisadmin].[COBBCITIES]