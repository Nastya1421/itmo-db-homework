CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE channels (
    id SERIAL PRIMARY KEY,
    account_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    avatar_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_channel_account FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE,
    CONSTRAINT chk_channel_name CHECK (length(trim(name)) > 0)
);

CREATE TABLE videos (
    id SERIAL PRIMARY KEY,
    channel_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    video_url VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_video_channel FOREIGN KEY (channel_id) REFERENCES channels(id) ON DELETE CASCADE
);

CREATE TABLE subscriptions (
    subscriber_channel_id INT NOT NULL,
    target_channel_id INT NOT NULL,
    subscribed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (subscriber_channel_id, target_channel_id),
    CONSTRAINT fk_sub_subscriber FOREIGN KEY (subscriber_channel_id) REFERENCES channels(id) ON DELETE CASCADE,
    CONSTRAINT fk_sub_target FOREIGN KEY (target_channel_id) REFERENCES channels(id) ON DELETE CASCADE,
    CONSTRAINT chk_no_self_sub CHECK (subscriber_channel_id != target_channel_id)
);

CREATE TABLE likes (
    video_id INT NOT NULL,
    channel_id INT NOT NULL,
    liked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (video_id, channel_id),
    CONSTRAINT fk_like_video FOREIGN KEY (video_id) REFERENCES videos(id) ON DELETE CASCADE,
    CONSTRAINT fk_like_channel FOREIGN KEY (channel_id) REFERENCES channels(id) ON DELETE CASCADE
);

CREATE TABLE comments (
    id SERIAL PRIMARY KEY,
    video_id INT NOT NULL,
    channel_id INT NOT NULL,
    text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comment_video FOREIGN KEY (video_id) REFERENCES videos(id) ON DELETE CASCADE,
    CONSTRAINT fk_comment_channel FOREIGN KEY (channel_id) REFERENCES channels(id) ON DELETE CASCADE
);

CREATE TYPE channel_role AS ENUM ('creator', 'moderator', 'user');

CREATE TABLE channel_members (
    id SERIAL PRIMARY KEY,
    channel_id INT NOT NULL,
    member_channel_id INT NOT NULL,
    role channel_role NOT NULL DEFAULT 'user',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_member_channel FOREIGN KEY (channel_id) REFERENCES channels(id) ON DELETE CASCADE,
    CONSTRAINT fk_member_member FOREIGN KEY (member_channel_id) REFERENCES channels(id) ON DELETE CASCADE,
    CONSTRAINT uq_channel_member UNIQUE (channel_id, member_channel_id)
);

CREATE UNIQUE INDEX unique_creator_per_channel ON channel_members (channel_id) WHERE role = 'creator';

SELECT * FROM videos WHERE channel_id = 1;

SELECT DISTINCT email FROM accounts;

SELECT v.title, c.name FROM videos v JOIN channels c ON v.channel_id = c.id;

SELECT channel_id FROM likes
UNION
SELECT channel_id FROM comments;

SELECT channel_id FROM likes
INTERSECT
SELECT channel_id FROM comments;

SELECT id FROM channels
EXCEPT
SELECT channel_id FROM videos;

SELECT s1.subscriber_channel_id, s1.target_channel_id
FROM subscriptions s1
JOIN subscriptions s2
  ON s1.subscriber_channel_id = s2.target_channel_id
 AND s1.target_channel_id = s2.subscriber_channel_id;

SELECT c.name, COUNT(v.id) AS videos_count
FROM channels c
LEFT JOIN videos v ON v.channel_id = c.id
GROUP BY c.id, c.name;

SELECT channel_id, member_channel_id
FROM channel_members
WHERE role = 'creator';