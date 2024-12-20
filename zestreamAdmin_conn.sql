CREATE TABLE users (
    id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    role VARCHAR2(20) CHECK (role IN ('admin', 'regular')) NOT NULL,
    email VARCHAR2(255) UNIQUE NOT NULL,
    username VARCHAR2(50) UNIQUE NOT NULL,
    signup_date DATE DEFAULT SYSDATE NOT NULL
);

grant select on c##zestreamadmin.RecommendationResults to c##zestream;
grant connect to c##zestream;

INSERT INTO users (role, email, username, signup_date) 
VALUES ('regular', 'john.doe@example.com', 'johndoe', SYSDATE);

INSERT INTO users (role, email, username, signup_date) 
VALUES ('regular', 'sarah.smith@example.com', 'sarahsmith', SYSDATE);

INSERT INTO users (role, email, username, signup_date) 
VALUES ('regular', 'michael.jones@example.com', 'michaeljones', SYSDATE);

INSERT INTO users (role, email, username, signup_date) 
VALUES ('regular', 'emily.white@example.com', 'emilywhite', SYSDATE);

INSERT INTO users (role, email, username, signup_date) 
VALUES ('regular', 'lisa.green@example.com', 'lisagreen', SYSDATE);

select * from users;


CREATE TABLE videos (
    id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    title VARCHAR2(255) NOT NULL,
    category VARCHAR2(100),
    abstract CLOB,
    content VARCHAR2(255),  
    length NUMBER,         
    posted_by VARCHAR2(100),
    publish_date DATE DEFAULT SYSDATE,
    rating NUMBER(3, 2),   
    thumbnail BLOB       
);


create TABLE UserInteractions (
    interaction_id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    user_id NUMBER REFERENCES users(id),
    video_id NUMBER REFERENCES videos(id),
    watch_time NUMBER, 
    interactions NUMBER,  
    watched_date DATE DEFAULT SYSDATE
);

describe UserInteractions;


INSERT INTO UserInteractions (user_id,video_id,watch_time,interactions,watched_date) 
values (4, 7, 120, 2, TO_DATE('2024-12-05', 'YYYY-MM-DD'));

select * from trainingdata;

create TABLE TrainingData (
    user_id NUMBER REFERENCES users(id),
    video_category VARCHAR2(100),
    watch_time NUMBER,
    video_id NUMBER REFERENCES videos(id),  
    rating NUMBER 
);

desc TrainingData;

CREATE TABLE RecommendationResults (
    user_id NUMBER REFERENCES users(id),  
    predicted_video_id NUMBER REFERENCES videos(id),  
    probability NUMBER
);

desc RecommendationResults;

INSERT INTO TrainingData
SELECT
    ui.user_id,
    v.category AS video_category,
    ui.watch_time,
    ui.video_id,
    ui.interactions
FROM UserInteractions ui
JOIN videos v ON ui.video_id = v.id;

select * from TrainingData;
rollaback;


CREATE TABLE DM_SETTINGS (
    setting_name VARCHAR2(50),
    setting_value VARCHAR2(4000)
);

INSERT INTO DM_SETTINGS (setting_name, setting_value) 
VALUES ('ALGO_NAME', 'ALGO_SVM'); -- Use an appropriate algorithm (e.g., SVM)

INSERT INTO DM_SETTINGS (setting_name, setting_value) 
VALUES ('PREP_AUTO', 'ON'); -- Enable automatic data preparation


SELECT MODEL_NAME 
FROM USER_MINING_MODELS;

BEGIN
   DBMS_DATA_MINING.DROP_MODEL('VIDEO_RECOMMENDATION_MODEL');
END;

BEGIN
   DBMS_DATA_MINING.CREATE_MODEL(
      model_name          => 'VIDEO_RECOMMENDATION_MODEL',
      mining_function     => 'CLASSIFICATION',
      data_table_name     => 'TrainingData',
      case_id_column_name => 'user_id',
      target_column_name  => 'video_id',
      settings_table_name => NULL
   );
END;


DECLARE
    CURSOR c1 IS
        SELECT DISTINCT user_id FROM TrainingData;
BEGIN
    FOR user_rec IN c1 LOOP
        -- Insert predictions for each user into RecommendationResults
        INSERT INTO RecommendationResults (user_id, predicted_video_id, probability)
        SELECT 
            user_rec.user_id,
            PREDICTION(VIDEO_RECOMMENDATION_MODEL USING 
                user_id, video_category, watch_time) AS predicted_video_id,
            PREDICTION_PROBABILITY(VIDEO_RECOMMENDATION_MODEL USING 
                user_id, video_category, watch_time) AS probability
        FROM TrainingData
        WHERE user_id = user_rec.user_id;
    END LOOP;
    COMMIT;
END;
/


SELECT 
    MODEL_NAME,
    MINING_FUNCTION,
    BUILD_STATUS,
    MODEL_SIZE,
    ALGORITHM
FROM USER_MINING_MODELS
WHERE MODEL_NAME = 'VIDEO_RECOMMENDATION_MODEL';


select * from TrainingData;

CREATE OR REPLACE TRIGGER UpdateTrainingData
AFTER INSERT OR UPDATE ON UserInteractions
FOR EACH ROW
BEGIN
    MERGE INTO TrainingData td
    USING (SELECT :NEW.user_id AS user_id, :NEW.video_id AS video_id FROM dual) src
    ON (td.user_id = src.user_id AND td.video_id = src.video_id)
    WHEN MATCHED THEN
        UPDATE SET td.watch_time = :NEW.watch_time, td.interactions = :NEW.interactions
    WHEN NOT MATCHED THEN
        INSERT (user_id, video_category, watch_time, interactions, video_id)
        VALUES (
            :NEW.user_id,
            (SELECT category FROM Videos WHERE video_id = :NEW.video_id),
            :NEW.watch_time,
            :NEW.interactions,
            :NEW.video_id
        );
END;
/

CREATE INDEX idx_user_interactions_user ON UserInteractions(user_id);
CREATE INDEX idx_training_data_user ON TrainingData(user_id);
CREATE INDEX idx_training_data_video ON TrainingData(video_id);


SELECT *
FROM RecommendationResults
WHERE user_id = 1
ORDER BY probability DESC;

truncate table RecommendationResults

SELECT video_id, COUNT(*) AS views
FROM UserInteractions
GROUP BY video_id
ORDER BY views DESC;

-- data insertion -- 

CREATE DIRECTORY V_CONTENT_DIR AS 'C:\Users\rizd\Desktop\content';
SELECT DIRECTORY_NAME, DIRECTORY_PATH
FROM ALL_DIRECTORIES
WHERE DIRECTORY_NAME = 'V_CONTENT_DIR';


DECLARE
    l_blob BLOB;
    l_bfile BFILE;
BEGIN
    
    INSERT INTO videos (title, category, abstract, content, length, posted_by, publish_date, rating, thumbnail)
    VALUES (
        'Playing With Time', 
        'science',
        TO_CLOB('This is a sample abstract content for the video Playing With Time'),  
        '1zpES1oLQNBj6FJpq8XTlrbr34TZZdVUg',  
        200, 
        'lomba akuna', 
        SYSDATE,  
        3.5,  
        EMPTY_BLOB() 
    )
    RETURN thumbnail INTO l_blob;


    l_bfile := BFILENAME('V_CONTENT_DIR', 'science2.jpg'); 
    DBMS_LOB.FILEOPEN(l_bfile, DBMS_LOB.FILE_READONLY);  


    DBMS_LOB.LOADFROMFILE(l_blob, l_bfile, DBMS_LOB.GETLENGTH(l_bfile));
    
    DBMS_LOB.FILECLOSE(l_bfile);

    
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Video and thumbnail inserted successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;

select * from videos;

SELECT * 
FROM TrainingData 
WHERE user_id IS NULL OR video_category IS NULL OR watch_time IS NULL;
