select
	address
,	url
,	abbrev
,	name
,	dept
,	shape_wkt = [SHAPE].STAsText()

from [FIRE].[gisadmin].[FIRESTATIONS]
