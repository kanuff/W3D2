PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);


CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author INTEGER NOT NULL,

  FOREIGN KEY (author) REFERENCES users(id)
);


CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY, 
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);


CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  author INTEGER NOT NULL,
  parent INTEGER DEFAULT NULL,
  body TEXT NOT NULL,
  
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (author) REFERENCES users(id),
  FOREIGN KEY (parent) REFERENCES replies(id)
);


CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('John', 'Doe'),
  ('Jane', 'Doe');

INSERT INTO 
  questions (title, body, author)
VALUES  
  ('First Question', 'Why do we exist?', 2),
  ('Second Question', 'When is lunch?', 1);


INSERT INTO
  question_follows (question_id, user_id)
VALUES
   ( (SELECT id FROM questions WHERE title = 'First Question'), 2),
   ( (SELECT id FROM questions WHERE title = 'First Question'), 1),
   ( (SELECT id FROM questions WHERE title = 'Second Question'), 2);


INSERT INTO
  replies (question_id, author, parent, body)
VALUES
  ( (SELECT id FROM questions WHERE title = 'First Question'),
    1,
    NULL,
    'I don''t know'
   ),
  ( (SELECT id FROM questions WHERE title = 'First Question'),
    2,
    1,
    'Wow thanks'
   );

INSERT INTO
  question_likes (question_id, user_id)
VALUES
  (1, 2),
  (2, 2),
  (1, 1);