-- 
-- Формирование данных для заполнения таблицы Students
--
-- Команда для заполнения таблицы Students
-- INSERT INTO students SELECT * FROM generate_students_data();
--
CREATE OR REPLACE FUNCTION generate_students_data()
  RETURNS TABLE( mark_book numeric( 5 ), name text, psp_ser numeric( 4 ),
                 psp_num numeric( 6 ) ) AS
$$
BEGIN
  -- Создадим последовательности для полей mark_book, psp_ser, psp_num.

  -- Значения поля "Номер зачетной книжки" должны быть пятизначными.
  CREATE TEMP SEQUENCE New_mark_book START WITH 10000;

  -- Значения поля "Серия паспорта" должны быть четырехзначными.
  CREATE TEMP SEQUENCE New_psp_ser START WITH 1000;

  -- Значения поля "Номер паспорта" должны быть шестизначными.
  CREATE TEMP SEQUENCE New_psp_num START WITH 100000;

  RETURN QUERY
  SELECT NEXTVAL( 'New_mark_book' )::numeric( 5 ),
         lname_base || lname_suffix || ' ' || fname || ' ' || pname,
         NEXTVAL( 'New_psp_ser' )::numeric( 4 ),
         NEXTVAL( 'New_psp_num' )::numeric( 6 )
  -- Формируем декартово произведение фрагментов фамилии, имени и отчества,
  -- т. е. комбинации каждого значения из каждой виртуальной таблицы 
  -- с каждым значением из других виртуальных таблиц.
  FROM ( VALUES ( 'Логин' ), ( 'Перл' ), ( 'Программ' ), ( 'Дебаг' ) )
           AS lname_bases ( lname_base ) NATURAL JOIN 
       ( VALUES ( 'ов' ), ( 'овых' ), ( 'овский' ), ( 'овичев' ), ( 'енко' ) )
           AS lname_suffixes ( lname_suffix ) NATURAL JOIN 
       ( VALUES ( 'Андрей' ), ( 'Иван' ), ( 'Николай' ), ( 'Петр' ) )
           AS fnames ( fname ) NATURAL JOIN
       ( VALUES ( 'Анатольевич' ), ( 'Кириллович' ), ( 'Павлович' ),
                ( 'Тихонович' ) ) 
           AS pnames ( pname );

  -- Удалим врЕменные последовательности.
  DROP SEQUENCE New_mark_book;
  DROP SEQUENCE New_psp_ser;
  DROP SEQUENCE New_psp_num;
END
$$ LANGUAGE plpgsql;
