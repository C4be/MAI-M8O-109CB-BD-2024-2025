-- ----------------------------------------------------------------------------------
-- Простые примеры триггеров (2 часть)
-- (см. документацию по СУБД PostgreSQL, п. 39.9 "Trigger Procedures")
-- ----------------------------------------------------------------------------------

-- основная таблица базы данных
DROP TABLE IF EXISTS progress;
CREATE TABLE progress
( mark_book numeric(5) NOT NULL,
  subject text NOT NULL,
  acad_year text NOT NULL,
  term numeric( 1 ) NOT NULL CHECK ( term = 1 OR term = 2 ),
  mark numeric( 1 ) NOT NULL CHECK ( mark >= 3 AND mark <= 5 ) DEFAULT 5,
  FOREIGN KEY ( mark_book )
    REFERENCES students ( mark_book )
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- журнальная таблица БД (она содержит все те же поля, что и основная таблица,
-- а также дополнительные поля)
-- в этой таблице фиксируются ВСЕ операции, выполненные над основной таблицей
DROP TABLE IF EXISTS progress_2;
CREATE TABLE progress_2 
( mark_book numeric(5),
  subject text,
  acad_year text,
  term numeric( 1 ),
  mark numeric( 1 ),
  -- служебные атрибуты (поля)
  operation text,    -- тип операции (INSERT, UPDATE, DELETE)
  person text,       -- пользователь, выполнивший операцию
  moment timestamp   -- момент времени, когда была выполнена операция
);
  
-- триггерная функция (если она уже существет, то будет пересоздана заново)
CREATE OR REPLACE FUNCTION log_progress() RETURNS TRIGGER 
AS $log_progress_oper$
  BEGIN
    -- TG_OP -- встроенная переменная языка PL/pgSQL, в ней хранится
    -- имя операции с БД
    IF TG_OP = 'INSERT' THEN
      -- NEW -- значения полей, вставляемые в таблицу students
      -- user -- функция, возвращающая имя пользователя БД, выполняющего
      --         операцию
      -- current_timestamp -- функция, возвращающая дату и время
      INSERT INTO progress_2 VALUES ( NEW.*, TG_OP, user, current_timestamp );
      RETURN NEW;  -- при вставке записи возвращается значение NEW
    ELSIF TG_OP = 'UPDATE' THEN
      INSERT INTO progress_2 VALUES ( NEW.*, TG_OP, user, current_timestamp );
      RETURN NEW;  -- при обновлении записи возвращается значение NEW
    ELSIF TG_OP = 'DELETE' THEN
      INSERT INTO progress_2 VALUES ( OLD.*, TG_OP, user, current_timestamp );
      RETURN OLD;  -- при удалении записи возвращается значение OLD
    END IF;
    RETURN NULL;   -- результат игнорируется, т.к. этот триггер выполняется
                   -- ПОСЛЕ выполнения операции с таблицей students
                   -- (AFTER trigger)
  END;
$log_progress_oper$ LANGUAGE plpgsql;   -- язык PL/pgSQL 

-- непосредственное создание триггера с функцией log_progress()
-- триггер выполняется для КАЖДОЙ ставляемой, обновляемой или удаляемой строки
-- (FOR EACH ROW)
CREATE TRIGGER log_progress_oper 
  AFTER INSERT OR UPDATE OR DELETE ON progress 
  FOR EACH ROW EXECUTE PROCEDURE log_progress();

-- функция для проверки того, не превышает ли число записей для конкретного
-- студента трех штук (считаем для конкретности ситуации, что во время сессии
-- у студента не может быть больше трех экзаменов)
CREATE OR REPLACE FUNCTION check_subject_count() RETURNS TRIGGER AS $check_subj_cnt$
  DECLARE
    exams_count integer;   -- счетчик числа экзаменов, сданных студентом
  BEGIN
    SELECT count( subject ) INTO exams_count FROM progress
    WHERE mark_book = NEW.mark_book AND
          acad_year = NEW.acad_year AND
          term = NEW.term; 

    -- если число сданных экзаменов равно трем или больше трех ...
    IF exams_count >= 3 THEN
      -- ... СУБД выведет сообщение и не позволит выполнить операцию INSERT
      -- или UPDATE
      RAISE EXCEPTION 'Этот студент уже сдал три экзамена';
    END IF;

    -- все в порядке, поэтому возвратим новые значения полей вставляемой или 
    -- обновляемой записи
    RETURN NEW;
  END;
$check_subj_cnt$ LANGUAGE plpgsql;

-- непосредственное создание триггера с функцией check_subject_count()
CREATE TRIGGER check_subj_cnt
  BEFORE INSERT OR UPDATE ON progress 
  FOR EACH ROW EXECUTE PROCEDURE check_subject_count();
