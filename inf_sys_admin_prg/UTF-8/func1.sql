CREATE OR REPLACE FUNCTION count_letters()
  RETURNS TABLE( letter char( 1 ), num bigint ) AS
$$
  SELECT substr( name, 1, 1 ) AS letter, count( * ) 
  FROM students GROUP BY letter ORDER BY letter;
$$ LANGUAGE SQL;
