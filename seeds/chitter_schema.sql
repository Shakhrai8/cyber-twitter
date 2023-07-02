DROP TABLE IF EXISTS users, peeps, replies, tags, peep_tags, notifications;

-- Create the users table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  username VARCHAR(255) UNIQUE NOT NULL,
  profile_photo_url (TEXT DEFAULT '/images/default.svg.png'),
  bio (TEXT)
);

-- Create the peeps table
CREATE TABLE peeps (
  id SERIAL PRIMARY KEY,
  content TEXT NOT NULL,
  timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
  user_id INTEGER,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Create the replies table
CREATE TABLE replies (
  id SERIAL PRIMARY KEY,
  content TEXT NOT NULL,
  timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
  user_id INTEGER,
  peep_id INTEGER,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (peep_id) REFERENCES peeps(id)
);

-- Create the tags table
CREATE TABLE tags (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

-- Create the peep_tags table
CREATE TABLE peep_tags (
  peep_id INTEGER,
  tag_id INTEGER,
  FOREIGN KEY (peep_id) REFERENCES peeps(id),
  FOREIGN KEY (tag_id) REFERENCES tags(id),
  PRIMARY KEY (peep_id, tag_id)
);

CREATE TABLE notifications (
  id SERIAL PRIMARY KEY,
  event_type VARCHAR(255) NOT NULL,
  peep_id INTEGER,
  user_id INTEGER,
  content TEXT,
  FOREIGN KEY (peep_id) REFERENCES peeps(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  timestamp TIMESTAMP NOT NULL DEFAULT NOW()
);
