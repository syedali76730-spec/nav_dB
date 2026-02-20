-- ============================================================
-- Sports Tournament Database
-- Student: Aptech Learning Center, 2nd Semester
-- Subject: Database Management Systems
-- Task: Large-Scale International Sports Tournament Database
-- ============================================================

-- First, create our database and tell MySQL to use it
CREATE DATABASE IF NOT EXISTS sports_tournament;
USE sports_tournament;


-- ============================================================
-- TABLE 1: Venues
-- This table stores information about all the places
-- where events will be held.
-- ============================================================

CREATE TABLE Venues (
    venue_id    INT PRIMARY KEY AUTO_INCREMENT,  -- unique ID for each venue
    name        VARCHAR(100) NOT NULL,            -- name of the stadium/arena
    location    VARCHAR(150) NOT NULL,            -- city and country
    capacity    INT NOT NULL                      -- how many people it can hold
);


-- ============================================================
-- TABLE 2: Participants
-- Stores all athletes/players who are taking part
-- in the tournament.
-- ============================================================

CREATE TABLE Participants (
    participant_id  INT PRIMARY KEY AUTO_INCREMENT,
    name            VARCHAR(100) NOT NULL,
    nationality     VARCHAR(60)  NOT NULL,   -- country the athlete represents
    age             INT          NOT NULL,
    gender          ENUM('Male', 'Female', 'Other') NOT NULL
);


-- ============================================================
-- TABLE 3: Events
-- Each row is one sporting event (e.g. 100m Sprint Final).
-- It links to Venues using a foreign key so we know
-- where each event originally takes place.
-- ============================================================

CREATE TABLE Events (
    event_id    INT PRIMARY KEY AUTO_INCREMENT,
    sport_type  VARCHAR(80)  NOT NULL,   -- e.g. Swimming, Athletics, Boxing
    event_date  DATE         NOT NULL,   -- the date the event is held
    event_time  TIME         NOT NULL,   -- the time the event starts
    venue_id    INT          NOT NULL,
    FOREIGN KEY (venue_id) REFERENCES Venues(venue_id)
);


-- ============================================================
-- TABLE 4: Schedules
-- This table is used for real-time schedule management.
-- If an event needs to be rescheduled (different date,
-- time, or venue) we UPDATE a row here instead of changing
-- the original Events table. That way we keep a clean
-- working schedule separate from the original plan.
-- ============================================================

CREATE TABLE Schedules (
    schedule_id     INT PRIMARY KEY AUTO_INCREMENT,
    event_id        INT  NOT NULL,
    venue_id        INT  NOT NULL,          -- can differ from Events.venue_id if relocated
    scheduled_date  DATE NOT NULL,
    scheduled_time  TIME NOT NULL,
    FOREIGN KEY (event_id)  REFERENCES Events(event_id),
    FOREIGN KEY (venue_id)  REFERENCES Venues(venue_id)
);


-- ============================================================
-- TABLE 5: Event_Participants  (Junction / Bridge Table)
-- One participant can join many events, and one event
-- can have many participants. This is a many-to-many
-- relationship so we need a junction table.
-- We also store score and ranking here because they belong
-- to a specific participant IN a specific event.
-- ============================================================

CREATE TABLE Event_Participants (
    event_id        INT NOT NULL,
    participant_id  INT NOT NULL,
    score           DECIMAL(7, 2),   -- numeric score (e.g. time in seconds, points)
    ranking         INT,             -- final position in that event
    PRIMARY KEY (event_id, participant_id),   -- composite primary key
    FOREIGN KEY (event_id)       REFERENCES Events(event_id),
    FOREIGN KEY (participant_id) REFERENCES Participants(participant_id)
);


-- ============================================================
-- INDEXES
-- Adding indexes on columns we will search/filter on often.
-- Without an index MySQL has to scan every row (slow on
-- large tables). An index works like a book's index --
-- it lets MySQL jump straight to the right rows.
-- ============================================================

-- We filter events by date a lot (Query 1), so index event_date
CREATE INDEX idx_event_date ON Events(event_date);

-- We search participants by country (Query 2), so index nationality
CREATE INDEX idx_nationality ON Participants(nationality);

-- We look up schedules by event often, so index event_id in Schedules
CREATE INDEX idx_schedule_event ON Schedules(event_id);


-- ============================================================
-- SAMPLE DATA -- VENUES (10 rows)
-- ============================================================

INSERT INTO Venues (name, location, capacity) VALUES
('National Stadium Karachi',   'Karachi, Pakistan',        55000),
('Qaddafi Stadium',            'Lahore, Pakistan',         45000),
('Dubai Sports City Arena',    'Dubai, UAE',               60000),
('London Olympic Stadium',     'London, England',          80000),
('Tokyo Aquatics Centre',      'Tokyo, Japan',             15000),
('Melbourne Cricket Ground',   'Melbourne, Australia',     100000),
('Khalifa International Stadium', 'Doha, Qatar',           40000),
('Wembley Stadium',            'London, England',          90000),
('Jawaharlal Nehru Stadium',   'New Delhi, India',         75000),
('Stade de France',            'Paris, France',            80000);


-- ============================================================
-- SAMPLE DATA -- PARTICIPANTS (10 rows)
-- ============================================================

INSERT INTO Participants (name, nationality, age, gender) VALUES
('Ali Raza',          'Pakistan',    22, 'Male'),
('Sara Ahmed',        'Pakistan',    19, 'Female'),
('Kenji Tanaka',      'Japan',       25, 'Male'),
('Maria Santos',      'Brazil',      21, 'Female'),
('James Okafor',      'Nigeria',     23, 'Male'),
('Fatima Al-Rashid',  'UAE',         20, 'Female'),
('Lucas Müller',      'Germany',     27, 'Male'),
('Priya Patel',       'India',       24, 'Female'),
('Omar Abdullah',     'Pakistan',    26, 'Male'),
('Sophie Dubois',     'France',      22, 'Female');


-- ============================================================
-- SAMPLE DATA -- EVENTS (10 rows)
-- Spread across different sports, dates, and venues
-- ============================================================

INSERT INTO Events (sport_type, event_date, event_time, venue_id) VALUES
('100m Sprint',         '2026-03-10', '09:00:00', 1),
('Swimming 200m',       '2026-03-10', '11:30:00', 5),
('Boxing Lightweight',  '2026-03-11', '15:00:00', 2),
('Long Jump',           '2026-03-11', '10:00:00', 4),
('Football Final',      '2026-03-12', '18:00:00', 8),
('Weightlifting 80kg',  '2026-03-12', '13:00:00', 7),
('Badminton Singles',   '2026-03-13', '09:30:00', 3),
('Swimming 100m',       '2026-03-13', '14:00:00', 5),
('Javelin Throw',       '2026-03-14', '11:00:00', 9),
('Tennis Singles',      '2026-03-14', '16:00:00', 10);


-- ============================================================
-- SAMPLE DATA -- SCHEDULES (10 rows)
-- Initially mirrors Events; rows get UPDATED when
-- a rescheduling happens (see Query 6).
-- ============================================================

INSERT INTO Schedules (event_id, venue_id, scheduled_date, scheduled_time) VALUES
(1,  1,  '2026-03-10', '09:00:00'),
(2,  5,  '2026-03-10', '11:30:00'),
(3,  2,  '2026-03-11', '15:00:00'),
(4,  4,  '2026-03-11', '10:00:00'),
(5,  8,  '2026-03-12', '18:00:00'),
(6,  7,  '2026-03-12', '13:00:00'),
(7,  3,  '2026-03-13', '09:30:00'),
(8,  5,  '2026-03-13', '14:00:00'),
(9,  9,  '2026-03-14', '11:00:00'),
(10, 10, '2026-03-14', '16:00:00');


-- ============================================================
-- SAMPLE DATA -- EVENT_PARTICIPANTS (10 rows)
-- Linking participants to events with scores and rankings
-- ============================================================

INSERT INTO Event_Participants (event_id, participant_id, score, ranking) VALUES
(1, 1,  9.85,  1),   -- Ali Raza, 100m Sprint, 1st place
(1, 3,  9.92,  2),   -- Kenji Tanaka, 100m Sprint, 2nd place
(2, 8,  107.45, 1),  -- Priya Patel, Swimming 200m, 1st
(2, 4,  109.20, 2),  -- Maria Santos, Swimming 200m, 2nd
(3, 5,  NULL,   1),  -- James Okafor, Boxing (score = points in match)
(4, 7,  8.23,   1),  -- Lucas Müller, Long Jump (meters)
(5, 1,  NULL,   NULL), -- Ali Raza, Football (team event, individual score N/A)
(6, 9,  180.50, 1),  -- Omar Abdullah, Weightlifting
(7, 6,  21.00,  1),  -- Fatima Al-Rashid, Badminton (21 points)
(8, 2,  54.33,  1);  -- Sara Ahmed, Swimming 100m, 1st place

-- ============================================================
-- End of setup script
-- Run this file first, then open sports_tournament_queries.sql
-- ============================================================
