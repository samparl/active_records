CREATE TABLE houses (
  id INTEGER PRIMARY KEY,
  address TEXT NOT NULL,
  owner_id INTEGER NOT NULL,

  FOREIGN KEY (owner_id) REFERENCES owners(id)
);

CREATE TABLE owners (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  family_id NOT NULL,

  FOREIGN KEY (family_id) REFERENCES families(id)
);

CREATE TABLE families (
  id INTEGER PRIMARY KEY,
  surname TEXT NOT NULL
);


INSERT INTO
families (surname)
VALUES
('Macdougal'),
('Grant');


INSERT INTO
owners (name, family_id)
VALUES
('John Macdougal', (SELECT id FROM families WHERE surname = 'Macdougal')),
('Cary Grant', (SELECT id FROM families WHERE surname = 'Grant'));


INSERT INTO
  houses (address, owner_id)
VALUES
  ('5 Elm Street', (SELECT id FROM owners WHERE name = 'John Macdougal')),
  ('1 Maple Road', (SELECT id FROM owners WHERE name = 'Cary Grant'));
