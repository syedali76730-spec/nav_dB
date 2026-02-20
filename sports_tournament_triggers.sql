-- ============================================================
-- Sports Tournament Database -- Triggers File
-- Student: Aptech Learning Center, 2nd Semester
-- NOTE: Run sports_tournament_setup.sql FIRST, then this file.
--
-- What is a trigger?
-- A trigger is a piece of SQL code that runs automatically
-- when something happens to a table (INSERT, UPDATE, DELETE).
-- You don't call it yourself -- MySQL fires it on its own.
-- ============================================================

USE sports_tournament;


-- ============================================================
-- AUDIT TABLE for Trigger 3
-- Before we write Trigger 3, we need a table to store the
-- log of schedule changes. This is called an "audit table"
-- -- it keeps a history of every change that was made.
-- ============================================================

CREATE TABLE IF NOT EXISTS Schedule_Changes (
    change_id       INT      PRIMARY KEY AUTO_INCREMENT,
    schedule_id     INT      NOT NULL,
    event_id        INT      NOT NULL,
    old_date        DATE,                            -- what the date was before
    new_date        DATE,                            -- what the date changed to
    old_time        TIME,                            -- what the time was before
    new_time        TIME,                            -- what the time changed to
    old_venue_id    INT,                             -- venue before the change
    new_venue_id    INT,                             -- venue after the change
    changed_at      DATETIME DEFAULT CURRENT_TIMESTAMP  -- when the change happened
);


-- ============================================================
-- IMPORTANT: DELIMITER
-- Normally MySQL treats a semicolon (;) as "end of command".
-- But inside a trigger there are multiple semicolons.
-- We temporarily change the delimiter to $$ so MySQL knows
-- the whole trigger is one command, not many small ones.
-- We change it back to ; at the end.
-- ============================================================

DELIMITER $$


-- ============================================================
-- TRIGGER 1: trg_validate_participant_age
-- Table  : Participants
-- Timing : BEFORE INSERT
--
-- Simple explanation:
-- Before a new participant is saved, this trigger checks
-- that their age is at least 1. If someone accidentally
-- types age = 0 or a negative number, MySQL will reject
-- the insert and show an error message. It acts like a
-- guard at the door of the Participants table.
-- ============================================================

CREATE TRIGGER trg_validate_participant_age
BEFORE INSERT ON Participants
FOR EACH ROW
BEGIN

    -- NEW.age refers to the age value that is about to be inserted
    IF NEW.age < 1 THEN

        -- SIGNAL is how we throw an error in MySQL triggers.
        -- SQLSTATE '45000' is the standard code for a custom error.
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: Age must be a positive number (1 or above). Please check the participant details.';

    END IF;

END$$


-- ============================================================
-- TRIGGER 2: trg_check_min_age_for_event
-- Table  : Event_Participants
-- Timing : BEFORE INSERT
--
-- Simple explanation:
-- Before we register a participant for an event, this trigger
-- looks up that participant's age in the Participants table.
-- If they are younger than 16, the registration is blocked
-- and an error is shown. This enforces a minimum age rule
-- for competing in the tournament.
-- ============================================================

CREATE TRIGGER trg_check_min_age_for_event
BEFORE INSERT ON Event_Participants
FOR EACH ROW
BEGIN

    -- We declare a variable to hold the age we look up
    DECLARE v_age INT;

    -- Look up the age of the participant being registered
    SELECT age INTO v_age
    FROM   Participants
    WHERE  participant_id = NEW.participant_id;

    -- Now check if they meet the minimum age requirement
    IF v_age < 16 THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: Participant must be at least 16 years old to enter an event.';

    END IF;

END$$


-- ============================================================
-- TRIGGER 3: trg_log_schedule_change
-- Table  : Schedules
-- Timing : AFTER UPDATE
--
-- Simple explanation:
-- Whenever someone updates a row in the Schedules table
-- (e.g. changes the date, time, or venue of an event),
-- this trigger automatically saves a record of what changed
-- into the Schedule_Changes audit table.
-- OLD.column = the value BEFORE the update
-- NEW.column = the value AFTER the update
-- This way we always have a history of every schedule change.
-- ============================================================

CREATE TRIGGER trg_log_schedule_change
AFTER UPDATE ON Schedules
FOR EACH ROW
BEGIN

    -- Insert one row into our audit table recording the change
    INSERT INTO Schedule_Changes (
        schedule_id,
        event_id,
        old_date,
        new_date,
        old_time,
        new_time,
        old_venue_id,
        new_venue_id
    )
    VALUES (
        OLD.schedule_id,       -- which schedule row was changed
        OLD.event_id,          -- which event it belongs to
        OLD.scheduled_date,    -- date before the update
        NEW.scheduled_date,    -- date after the update
        OLD.scheduled_time,    -- time before the update
        NEW.scheduled_time,    -- time after the update
        OLD.venue_id,          -- venue before the update
        NEW.venue_id           -- venue after the update
    );

END$$


-- ============================================================
-- TRIGGER 4: trg_auto_create_schedule
-- Table  : Events
-- Timing : AFTER INSERT
--
-- Simple explanation:
-- Every event needs a matching row in the Schedules table.
-- Without this trigger, we would have to do two INSERT
-- statements every time we add a new event -- one into
-- Events and one into Schedules. This trigger handles the
-- second INSERT automatically. As soon as a new event is
-- added to the Events table, MySQL fires this trigger and
-- creates the matching schedule row using the same date,
-- time, and venue. Less work, less chance of forgetting!
-- ============================================================

CREATE TRIGGER trg_auto_create_schedule
AFTER INSERT ON Events
FOR EACH ROW
BEGIN

    -- Automatically create a schedule entry for the new event.
    -- NEW.event_id, NEW.venue_id etc. refer to the row just inserted.
    INSERT INTO Schedules (event_id, venue_id, scheduled_date, scheduled_time)
    VALUES (NEW.event_id, NEW.venue_id, NEW.event_date, NEW.event_time);

END$$


-- ============================================================
-- Switch the delimiter back to normal semicolon
-- ============================================================

DELIMITER ;


-- ============================================================
-- HOW TO TEST THE TRIGGERS
-- ============================================================

-- TEST Trigger 1: try inserting a participant with age = 0
-- This should FAIL with our custom error message.
-- INSERT INTO Participants (name, nationality, age, gender)
-- VALUES ('Test Person', 'Pakistan', 0, 'Male');

-- TEST Trigger 2: try registering participant_id = 2 (Sara Ahmed, age 19)
-- for an event -- this should SUCCEED (age >= 16).
-- INSERT INTO Event_Participants (event_id, participant_id, score, ranking)
-- VALUES (3, 2, NULL, NULL);

-- TEST Trigger 3: update a schedule and then check the log table.
-- UPDATE Schedules SET scheduled_date = '2026-04-01' WHERE schedule_id = 1;
-- SELECT * FROM Schedule_Changes;

-- TEST Trigger 4: insert a new event and check that Schedules
-- gets a new row automatically.
-- INSERT INTO Events (sport_type, event_date, event_time, venue_id)
-- VALUES ('Table Tennis', '2026-03-20', '10:00:00', 3);
-- SELECT * FROM Schedules WHERE event_id = (SELECT MAX(event_id) FROM Events);

-- ============================================================
-- End of triggers file
-- ============================================================
