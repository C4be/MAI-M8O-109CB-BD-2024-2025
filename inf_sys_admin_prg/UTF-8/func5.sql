-- 
-- Формирование данных для заполнения таблицы Progress
--
-- Команда для заполнения таблицы Students
-- INSERT INTO progress SELECT * FROM generate_progress_data( '2014-2015', 1 );
--
CREATE OR REPLACE FUNCTION generate_progress_data( IN ay text, 
                                                   IN t numeric( 1 ))
  -- параметры
  -- ay -- учебный год
  -- t -- семестр
  RETURNS TABLE( mark_book numeric( 5 ), subject text, acad_year text,
                 term numeric( 1 ), mark numeric( 1 ) ) AS
$$
DECLARE
  mark_books CURSOR FOR SELECT s.mark_book FROM Students s;
  mb NUMERIC( 5 );   -- номер зачетной книжки 
BEGIN
  OPEN mark_books;

  -- выбираем все записи из таблицы students в цикле while, хотя можно
  -- было использовать и специальный цикл for для курсора, тогда не пришлось
  -- бы делать проверку с помощью функции FOUND
  WHILE ( 1 )
  LOOP
    -- берем следующую запись из таблицы
    FETCH NEXT FROM mark_books INTO mb;
    
    -- если записей больше нет 
    IF NOT FOUND THEN
      RETURN;
    END IF;
  
    -- сформируем очередные три строки, которые пойдут в итоговый результат
    RETURN QUERY
    SELECT mb, 'математика'::text, ay, t,
           -- функция random() дает число X в диапазоне 0.0 <= X < 1.0;
           -- умножая его на 3, переводим число в диапазон 0.0 <= X < 3.0;
           -- функция floor() дает наибольшее целое, не превышающее числа X,
           -- т. е. 0, 1 или 2;
           -- прибавляя 3, сдвигаем целое число на 3, получая итог: 3, 4 или 5
           floor( random() * 3 )::numeric( 1 ) + 3;

    RETURN QUERY
    SELECT mb, 'физика'::text, ay, t, 
           floor( random() * 3 )::numeric( 1 ) + 3;

    RETURN QUERY
    SELECT mb, 'химия'::text, ay, t,
           floor( random() * 3 )::numeric( 1 ) + 3;
  END LOOP;
  
  CLOSE mark_books;
END
$$ LANGUAGE plpgsql;
