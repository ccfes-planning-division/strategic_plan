select
	battalion
,	station_number
,	shape_wkt = [SHAPE].STAsText()

from [FIRE].[gisadmin].[STATIONTERRITORIES]
