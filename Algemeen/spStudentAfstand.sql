/* Voorbeeld script bepalen afstand naar locatie
Oorspronkelijk auteur: Curio / Jurgen van Oorschot
*/


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   PROCEDURE [dbo].[sp_bepaal_afstanden_postcode_naar_locatie]
AS

DECLARE @l_json varchar(max)
	, @l_url varchar(500)
	, @l_url_type varchar(255) = 'GET'
	, @l_url_base varchar(500) = 'https://maps.googleapis.com/maps/api/distancematrix/json?mode=transit&transit_routing_preference=less_walking&key=<API-KEY>'
	, @l_key varchar(255) = ''
	, @l_status varchar(255)
	, @l_message varchar(255)
	, @l_origin varchar(255)
	, @l_destination varchar(255)
	, @l_woonplaats varchar(255)
	, @l_postcode varchar(255)
	, @l_land varchar(255)
	, @l_locatie varchar(255)


	DECLARE afstanden CURSOR LOCAL FAST_FORWARD FOR

		SELECT postcode
			, woonplaats
			, land
			, locatiePlaats
		FROM [dbo].[vw_List_google_afstanden]
	
		WHERE NULLIF(locatiePlaats, '') IS NOT NULL

		EXCEPT

		SELECT postcode
			, woonplaats
			, land
			, locatie
		FROM [dbo].[ds_afstanden_postcode_locatie]

	OPEN afstanden
	FETCH NEXT FROM afstanden
	INTO @l_postcode, @l_woonplaats, @l_land, @l_locatie

	WHILE @@FETCH_STATUS = 0
	BEGIN

		SET @l_destination = REPLACE(REPLACE(@l_locatie, ' ', '%20'), ',', '%2C')
		SET @l_origin = REPLACE(REPLACE(CONCAT(@l_postcode, '%20', @l_woonplaats, '%20', @l_land), ' ', '%20'), ',', '%2C')
		SET @l_url = @l_url_base + '&destinations='+@l_destination+'&origins='+@l_origin

		EXEC [config].[sp_GoogleMaps_api_distance]
				@p_url = @l_url,
				@p_url_type = 'GET',
				@p_json = @l_json OUTPUT,
				@p_status = @l_status OUTPUT,
				@p_message = @l_message OUTPUT

		INSERT INTO dbo.ds_afstanden_postcode_locatie
		(
			postcode
			, woonplaats
			, locatie
			, status_result
			, afstand_in_m
			, duur_in_seconden
			, json_response
		)
		SELECT @l_postcode
			, @l_woonplaats
			, @l_locatie
			, json_value(value, '$.elements[0].status')
			, json_value(value, '$.elements[0].distance.value')
			, json_value(value, '$.elements[0].duration.value')
			, @l_json
		FROM OPENJSON(@l_json, '$.rows')

	

		FETCH NEXT FROM afstanden
		INTO @l_postcode, @l_woonplaats, @l_land, @l_locatie
	END
	CLOSE afstanden
	DEALLOCATE afstanden
