-- ============================================================
-- Sports Tournament Database -- Query File
-- Student: Aptech Learning Center, 2nd Semester
-- NOTE: Run sports_tournament_setup.sql first before
--       running any of the queries below.
-- ============================================================

USE sports_tournament;


-- ============================================================
-- QUERY 1: Find all events scheduled on a specific date
-- We filter the Schedules table (not Events) because
-- Schedules holds the most up-to-date timing info.
-- Change the date value to search a different day.
-- ============================================================

SELECT
    s.schedule_id,
    e.sport_type,
    s.scheduled_date,
    s.scheduled_time,
    v.name       AS venue_name,
    v.location   AS venue_location
FROM Schedules s
JOIN Events  e ON s.event_id  = e.event_id
JOIN Venues  v ON s.venue_id  = v.venue_id
WHERE s.scheduled_date = '2026-03-10';   -- change this date as needed


-- ============================================================
-- QUERY 2: Find all participants from a specific country
-- The idx_nationality index we created makes this fast
-- because MySQL doesn't have to check every single row.
-- Change 'Pakistan' to any other country to filter by it.
-- ============================================================

SELECT
    participant_id,
    name,
    nationality,
    age,
    gender
FROM Participants
WHERE nationality = 'Pakistan';   -- change country name here


-- ============================================================
-- QUERY 3: List all participants in a specific event
-- We join Event_Participants with Participants to get
-- the actual names. Change event_id = 1 to any event.
-- ============================================================

SELECT
    p.participant_id,
    p.name            AS participant_name,
    p.nationality,
    ep.score,
    ep.ranking
FROM Event_Participants ep
JOIN Participants p ON ep.participant_id = p.participant_id
WHERE ep.event_id = 1    -- change this to the event you want
ORDER BY ep.ranking ASC;


-- ============================================================
-- QUERY 4: Show the full schedule for each event
--          with venue details
-- This gives us a combined view of all scheduled events
-- along with where they are being held.
-- ============================================================

SELECT
    s.schedule_id,
    e.event_id,
    e.sport_type,
    s.scheduled_date,
    s.scheduled_time,
    v.name       AS venue_name,
    v.location   AS venue_location,
    v.capacity   AS venue_capacity
FROM Schedules s
JOIN Events e ON s.event_id = e.event_id
JOIN Venues v ON s.venue_id = v.venue_id
ORDER BY s.scheduled_date, s.scheduled_time;


-- ============================================================
-- QUERY 5: Show overall standings/rankings for a specific sport
-- We filter by sport_type in Events, then join to get
-- participant details and their scores in that sport.
-- ============================================================

SELECT
    p.name            AS participant_name,
    p.nationality,
    ep.score,
    ep.ranking,
    e.sport_type,
    e.event_date
FROM Event_Participants ep
JOIN Participants p ON ep.participant_id = p.participant_id
JOIN Events       e ON ep.event_id       = e.event_id
WHERE e.sport_type = '100m Sprint'   -- change sport name here
ORDER BY ep.ranking ASC;


-- ============================================================
-- QUERY 6: Update an event's schedule (real-time update)
-- This is how we handle last-minute changes to timing
-- or venue. We UPDATE the Schedules table only --
-- the original Events table stays the same.
--
-- Example: Event 3 (Boxing) is moved from March 11 to
-- March 15, time changed, and venue changed to venue 6.
-- ============================================================

UPDATE Schedules
SET
    scheduled_date = '2026-03-15',
    scheduled_time = '17:00:00',
    venue_id       = 6             -- moved to a different venue
WHERE event_id = 3;

-- After running the update, let's verify the change:
SELECT
    s.schedule_id,
    e.sport_type,
    s.scheduled_date,
    s.scheduled_time,
    v.name     AS venue_name
FROM Schedules s
JOIN Events e ON s.event_id = e.event_id
JOIN Venues v ON s.venue_id = v.venue_id
WHERE s.event_id = 3;


-- ============================================================
-- QUERY 7: Generate a report of all participants with
--          their scores and rankings per event
-- This is a full report -- it shows every participant,
-- every event they entered, their score, and ranking.
-- Sorted by event then ranking so it's easy to read.
-- ============================================================

SELECT
    e.event_id,
    e.sport_type,
    e.event_date,
    p.name            AS participant_name,
    p.nationality,
    p.gender,
    ep.score,
    ep.ranking
FROM Event_Participants ep
JOIN Events       e ON ep.event_id       = e.event_id
JOIN Participants p ON ep.participant_id = p.participant_id
ORDER BY e.event_id ASC, ep.ranking ASC;


-- ============================================================
-- End of query file
-- ============================================================
