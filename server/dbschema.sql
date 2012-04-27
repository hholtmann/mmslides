
CREATE TABLE t_user (username VARCHAR(50) UNIQUE,firstname VARCHAR(255),lastname VARCHAR(255),password VARCHAR(50),email VARCHAR(255), id INTEGER PRIMARY KEY,exportSettings BLOB,preferences BLOB,created DATETIME,lostpassword VARCHAR(255), organization VARCHAR(255), telephone VARCHAR(255), enabled INTEGER, confirmHash VARCHAR(255));
CREATE INDEX usernamePasswordIndex on t_user (username, password);


CREATE TABLE IF NOT EXISTS t_project (project VARCHAR(255),id INTEGER PRIMARY KEY,userid INTEGER,path VARCHAR(255),lastEditor INTEGER,lastchange DATETIME,created DATETIME,data BLOB);

CREATE TABLE IF NOT EXISTS t_projectuser (id INTEGER PRIMARY KEY,projectid INTEGER,userid INTEGER, created DATETIME);
CREATE INDEX projectIdUserIdIndex on t_projectuser (projectid, userid);

CREATE TABLE t_settings (id INTEGER PRIMARY KEY,key VARCHAR(255),value VARCHAR(255),created DATETIME);
CREATE INDEX settingsIdIndex on t_settings (id);
INSERT INTO t_settings(key,value) values ("auto_approve","true");
INSERT INTO t_settings(key,value) values ("user_agreement","User Agreement / License Placeholder");