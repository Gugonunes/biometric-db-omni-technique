CREATE OR REPLACE FUNCTION OMNI1PvRangeQuery(qc float[][], radius float,
max_score float)
returns table (id integer, distance float) as $$
DECLARE
    distance_id1 FLOAT;
    distance_id2 FLOAT;
    distance_id3 FLOAT;
    calc_dist FLOAT;
BEGIN
    -- Calcule as distancias dos pivos
    SELECT 
        calc_dist_between_two_maps(
            (qc),
            (SELECT vetor_minucias FROM pivots WHERE pivots.id = 1)
        ) INTO distance_id1;

    SELECT 
        calc_dist_between_two_maps(
            (qc),
            (SELECT vetor_minucias FROM pivots WHERE pivots.id = 2)
        ) INTO distance_id2;
    
    SELECT 
        calc_dist_between_two_maps(
            (qc),
            (SELECT vetor_minucias FROM pivots WHERE pivots.id = 3)
        ) INTO distance_id3;

	RETURN QUERY
	SELECT falsepositives.id, calc_dist_between_two_maps(
			(qc),
			(falsepositives.vetor_minucias)
		)
	FROM (
		SELECT minucias.id, minucias.vetor_minucias
		FROM minucias
		WHERE distancepivot1 BETWEEN distance_id1 - radius AND distance_id1 + radius
		  AND distancepivot2 BETWEEN distance_id2 - radius AND distance_id2 + radius
		  AND distancepivot3 BETWEEN distance_id3 - radius AND distance_id3 + radius
		GROUP BY minucias.id
	) AS falsepositives
	WHERE calc_dist_between_two_maps(
		(qc),
		(falsepositives.vetor_minucias)
	) <= max_score
	ORDER BY calc_dist_between_two_maps(
		(qc),
		(falsepositives.vetor_minucias)
	);
END $$