-- ----------------------------------------------------------------------------
-- Таблица "Студенты"
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS students CASCADE;

CREATE TABLE students
( mark_book numeric( 5 ) NOT NULL,
  name text NOT NULL,
  psp_ser numeric( 4 ),
  psp_num numeric( 6 ),
  PRIMARY KEY ( mark_book )
);

INSERT INTO students VALUES
  ( 12300, 'Иванов Иван Иванович', 0402, 543281 ),
  ( 12700, 'Климов Андрей Николаевич', 0204, 123281 ),
  ( 13200, 'Павлов Павел Павлович', 0604, 121256 );

-- ----------------------------------------------------------------------------
-- Таблица "Успеваемость"
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS progress CASCADE;

CREATE TABLE progress
( mark_book numeric( 5 ) NOT NULL,
  subject text NOT NULL,
  acad_year text NOT NULL,
  term numeric( 1 ) NOT NULL CHECK ( term = 1 or term = 2 ),
  mark numeric( 1 ) NOT NULL CHECK ( mark >= 3 and mark <= 5 ) DEFAULT 5,
  FOREIGN KEY ( mark_book )
  REFERENCES students ( mark_book )
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

INSERT INTO progress VALUES
  ( 12700, 'Математика', '2013/2014', 1, 5 ),
  ( 12300, 'Математика', '2013/2014', 1, 4 ),
  ( 13200, 'Математика', '2013/2014', 1, 3 ),
  ( 12700, 'Физика', '2013/2014', 1, 3 ),
  ( 12300, 'Физика', '2013/2014', 1, 4 ),
  ( 13200, 'Физика', '2013/2014', 1, 5 ),
  ( 12700, 'Химия', '2013/2014', 1, 4 ),
  ( 12300, 'Химия', '2013/2014', 1, 4 ),
  ( 13200, 'Химия', '2013/2014', 1, 3 );
