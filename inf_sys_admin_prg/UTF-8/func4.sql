-- 
-- Вывод списка всех студентов из таблицы Students
--
CREATE OR REPLACE FUNCTION list_students()
  RETURNS TABLE( mark_book numeric( 5 ), name text, psp_ser numeric( 4 ),
                 psp_num numeric( 6 ) ) AS
$$
  SELECT * FROM students;
$$ LANGUAGE SQL;
