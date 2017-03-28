CREATE TABLE person(
  person_id  INTEGER PRIMARY KEY NOT NULL,
  first_name VARCHAR(20),
  last_name  VARCHAR(20),
  age        INTEGER  
);

INSERT INTO person (first_name, last_name, age)
  VALUES ('John', 'Smith', '30');

INSERT INTO person (first_name, last_name, age)
  VALUES ('David', 'Gray', '25');
 
INSERT INTO person (first_name, last_name, age)
  VALUES ('David', 'Smith', '35');