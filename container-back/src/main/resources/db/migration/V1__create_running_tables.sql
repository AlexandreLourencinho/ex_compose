
CREATE TABLE running_session (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    session_date DATE NOT NULL,
    session_type VARCHAR(30) NOT NULL,
    distance_km NUMERIC(5,2) NOT NULL,
    duration_seconds INTEGER NOT NULL,
    average_heart_rate INTEGER,
    max_heart_rate INTEGER,
    elevation_gain_m INTEGER,
    notes TEXT,

    CONSTRAINT chk_session_type
        CHECK (session_type IN (
            'EASY',
            'INTERVAL',
            'LONG_RUN',
            'RECOVERY',
            'RACE',
            'TEST_10K',
            'OTHER'
        )),

    CONSTRAINT chk_distance
        CHECK (distance_km > 0),

    CONSTRAINT chk_duration
        CHECK (duration_seconds > 0),

    CONSTRAINT chk_average_hr
        CHECK (average_heart_rate IS NULL OR average_heart_rate > 0),

    CONSTRAINT chk_max_hr
        CHECK (max_heart_rate IS NULL OR max_heart_rate > 0),

    CONSTRAINT chk_elevation
        CHECK (elevation_gain_m IS NULL OR elevation_gain_m >= 0),

    CONSTRAINT chk_heart_rates
        CHECK (
            average_heart_rate IS NULL
            OR max_heart_rate IS NULL
            OR max_heart_rate >= average_heart_rate
        ),

    CONSTRAINT chk_test_10k_distance
        CHECK (session_type <> 'TEST_10K' OR distance_km = 10)
);


CREATE TABLE weekly_review (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    week_start_date DATE NOT NULL UNIQUE,
    sleep_quality VARCHAR(20),
    fatigue_level INTEGER,
    general_feeling VARCHAR(20),
    notes TEXT,

    CONSTRAINT chk_sleep_quality
        CHECK (sleep_quality IN (
            'VERY_BAD',
            'BAD',
            'AVERAGE',
            'GOOD',
            'VERY_GOOD'
        ) OR sleep_quality IS NULL),

    CONSTRAINT chk_fatigue_level
        CHECK (fatigue_level BETWEEN 1 AND 5
            OR fatigue_level IS NULL),

    CONSTRAINT chk_general_feeling
        CHECK (general_feeling IN (
            'VERY_BAD',
            'BAD',
            'AVERAGE',
            'GOOD',
            'VERY_GOOD'
        ) OR general_feeling IS NULL)
);


CREATE TABLE running_goal (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    goal_type VARCHAR(30) NOT NULL,
    target_distance_km NUMERIC(5,2),
    target_duration_seconds INTEGER,
    target_pace_seconds INTEGER,
    start_date DATE NOT NULL,
    target_date DATE,
    achieved_date DATE,
    notes TEXT,

    CONSTRAINT chk_goal_type
        CHECK (goal_type IN (
            'DISTANCE',
            'DURATION',
            'PACE',
            'FREQUENCY',
            'OTHER'
        )),

    CONSTRAINT chk_goal_dates
        CHECK (target_date IS NULL OR target_date >= start_date),

    CONSTRAINT chk_achieved_date
        CHECK (achieved_date IS NULL OR achieved_date >= start_date),

    CONSTRAINT chk_goal_distance
        CHECK (target_distance_km IS NULL OR target_distance_km > 0),

    CONSTRAINT chk_goal_duration
        CHECK (target_duration_seconds IS NULL OR target_duration_seconds > 0),

    CONSTRAINT chk_goal_pace
        CHECK (target_pace_seconds IS NULL OR target_pace_seconds > 0)
);
