-- 
-- Вывод количества фамилий в таблице students, начинающихся с каждой буквы
-- алфавита, в том числе, и в случае отсутствия фамилий на конкретную букву
--
CREATE OR REPLACE FUNCTION count_letters_all()
  RETURNS TABLE( letter char( 1 ), num bigint ) AS
$$
  -- если использовать count( * ), то вместо нулевых количеств будет 1
  SELECT letters.letter, count( s.name ) 
  -- сформируем виртуальную таблицу
  FROM ( VALUES ( 'А' ), ( 'Б' ), ( 'В' ), ( 'Г' ), ( 'Д' ), ( 'Е' ),
                ( 'Ё' ), ( 'Ж' ), ( 'З' ), ( 'И' ), ( 'К' ), ( 'Л' ),
                ( 'М' ), ( 'Н' ), ( 'О' ), ( 'П' ), ( 'Р' ), ( 'С' ),
                ( 'Т' ), ( 'У' ), ( 'Ф' ), ( 'Х' ), ( 'Ц' ), ( 'Ч' ),
                ( 'Ш' ), ( 'Щ' ), ( 'Ы' ), ( 'Э' ), ( 'Ю' ), ( 'Я' )  
       ) AS letters ( letter )
       -- без LEFT OUTER будут выведены только ненулевые количества
       LEFT OUTER JOIN students s ON letters.letter = substr( s.name, 1, 1 )
--       JOIN students s ON letters.letter = substr( s.name, 1, 1 )
  GROUP BY letter ORDER BY letter;
$$ LANGUAGE SQL;
