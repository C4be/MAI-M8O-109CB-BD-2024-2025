-- ----------------------------------------------------------------------------------
-- Простые примеры триггеров
-- (см. документацию по СУБД PostgreSQL, п. 39.9 "Trigger Procedures")
-- ----------------------------------------------------------------------------------

-- основная таблица базы данных
DROP TABLE IF EXISTS students ;
CREATE TABLE students 
( mark_book numeric(5) NOT NULL,
  name text NOT NULL,
  psp_ser numeric(4),
  psp_num numeric(6),
  PRIMARY KEY ( mark_book )
);

-- журнальная таблица БД (она содержит все те же поля, что и основная таблица,
-- а также дополнительные поля)
-- в этой таблице фиксируются ВСЕ операции, выполненные над основной таблицей
DROP TABLE IF EXISTS students_2;
CREATE TABLE students_2 
( mark_book numeric(5),
  name text,
  psp_ser numeric(4),
  psp_num numeric(6),
  -- служебные атрибуты (поля)
  operation text,    -- тип операции (INSERT, UPDATE, DELETE)
  person text,       -- пользователь, выполнивший операцию
  moment timestamp   -- момент времени, когда была выполнена операция
);
  
-- триггерная функция (если она уже существет, то будет пересоздана заново)
CREATE OR REPLACE FUNCTION log_students() RETURNS TRIGGER 
AS $log_students_oper$
  BEGIN
    -- TG_OP -- встроенная переменная языка PL/pgSQL, 
    -- в ней хранится имя операции с БД
    IF TG_OP = 'INSERT' THEN
      -- NEW -- значения полей, вставляемые в таблицу students
      -- user -- функция, возвращающая имя пользователя БД, выполняющего 
      --         операцию
      -- current_timestamp -- функция, возвращающая дату и время
      INSERT INTO students_2 VALUES ( NEW.*, TG_OP, user, current_timestamp );
      RETURN NEW;  -- при вставке записи возвращается значение NEW
    ELSIF TG_OP = 'UPDATE' THEN
      INSERT INTO students_2 VALUES ( NEW.*, TG_OP, user, current_timestamp );
      RETURN NEW;  -- при обновлении записи возвращается значение NEW
    ELSIF TG_OP = 'DELETE' THEN
      INSERT INTO students_2 VALUES ( OLD.*, TG_OP, user, current_timestamp );
      RETURN OLD;  -- при удалении записи возвращается значение OLD
    END IF;
    RETURN NULL;   -- результат игнорируется, т.к. этот триггер выполняется
                   -- ПОСЛЕ выполнения операции с таблицей students
                   -- (AFTER trigger)
  END;
$log_students_oper$ LANGUAGE plpgsql;   -- язык PL/pgSQL 

-- непосредственное создание триггера с функцией log_students()
-- триггер выполняется для КАЖДОЙ ставляемой, обновляемой или удаляемой строки
-- (FOR EACH ROW)
CREATE TRIGGER log_students_oper 
  AFTER INSERT OR UPDATE OR DELETE ON students 
  FOR EACH ROW EXECUTE PROCEDURE log_students();

-- функция для проверки того, соответствует ли номер зачетной книжки текущему
-- году поступления (для упрощения будем считать год поступления 2013, хотя
-- можно было бы использовать функцию date_part, чтобы получить текущую
-- системную дату)
CREATE OR REPLACE FUNCTION check_mark_book() RETURNS TRIGGER AS $check_mb$
  BEGIN

    -- номер зачетной книжки должен быть пятизначным
    IF NEW.mark_book < 10000 THEN
      -- СУБД выведет сообщение и не позволит выполнить операцию INSERT 
      -- или UPDATE
      RAISE EXCEPTION 'Номер зачетной книжки должен быть пятизначным';
    END IF;

    -- если две последние цифры номера зачетной книжки не равны 13
    -- (год поступления -- текущий год)
    -- функция mod() дает остаток от деления первого параметра на второй
    -- при делении на 100 в остатке получается двузначное число
    IF mod( NEW.mark_book, 100 ) <> 13 THEN
      -- СУБД выведет сообщение и не позволит выполнить операцию INSERT
      -- или UPDATE
      RAISE EXCEPTION 'Неправильный шифр года поступления ' ||
                      'в номере зачетной книжки';
    END IF;

    -- все в порядке, поэтому возвратим новые значения полей вставляемой или 
    -- обновляемой записи
    RETURN NEW;
  END;
$check_mb$ LANGUAGE plpgsql;

-- непосредственное создание триггера с функцией check_mark_book()
CREATE TRIGGER check_mb
  BEFORE INSERT OR UPDATE ON students 
  FOR EACH ROW EXECUTE PROCEDURE check_mark_book();
