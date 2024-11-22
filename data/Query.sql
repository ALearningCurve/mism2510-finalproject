WITH
  sampleUsers
  AS
  (
    SELECT id, reputation, creationDate, lastAccessDate, views, upVotes, downVotes
    FROM users
    TABLESAMPLE(50000 ROWS) 
    REPEATABLE(205)
  )
  -- Alternative way to sample users
--   AS
-- (
--   SELECT
--   id, reputation, creationDate, lastAccessDate, views, upVotes, downVotes
-- FROM users
-- WHERE .1 > CAST(CHECKSUM(NEWID(), id) & 0x7fffffff AS float) / CAST (0x7fffffff AS int)
-- )
  ,
  postCount
  AS
  (
    SELECT users.id, COUNT(posts.owneruserid) AS num
    FROM sampleUsers AS users
      LEFT JOIN posts ON posts.owneruserid = users.id
    GROUP BY users.id
  )
  ,
  commentCount
  AS
  (
    SELECT users.id, COUNT(comments.userid) AS num
    FROM sampleUsers AS users
      LEFT JOIN comments ON comments.userid = users.id
    GROUP BY users.id
  )
  ,
  voteCount
  AS
  (
    SELECT users.id, COUNT(votes.userid) AS num
    FROM sampleUsers AS users
      LEFT JOIN votes ON votes.userid = users.id
    GROUP BY users.id
  )
  ,
  editCount
  AS
  (
    SELECT users.id, COUNT(postHistory.userid) AS num
    FROM sampleUsers AS users
      LEFT JOIN postHistory ON users.id = postHistory.userid
    GROUP BY users.id
  )
  ,
  suggestedEditsCount
  as
  (
    SELECT users.id, COUNT(suggestedEdits.owneruserid) AS num
    FROM sampleUsers AS users
      LEFT JOIN suggestedEdits ON users.id = suggestedEdits.owneruserid
    GROUP BY users.id
  )
SELECT
  sampleUsers.*,
  postCount.num AS postCount,
  commentCount.num AS commentCount,
  voteCount.num AS voteCount,
  editCount.num AS editCount,
  suggestedEditsCount.num AS suggestedEditCount
FROM sampleUsers
  LEFT JOIN postCount ON sampleUsers.id = postCount.id
  LEFT JOIN commentCount ON sampleUsers.id = commentCount.id
  LEFT JOIN voteCount ON sampleUsers.id = voteCount.id
  LEFT JOIN editCount ON sampleUsers.id = editCount.id
  LEFT JOIN suggestedEditsCount ON sampleUsers.id = suggestedEditsCount.id

