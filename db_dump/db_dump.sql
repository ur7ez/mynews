CREATE TABLE categories
(
  id                 SMALLINT(5) UNSIGNED AUTO_INCREMENT
    PRIMARY KEY,
  title              VARCHAR(50)                     NOT NULL,
  description        TEXT                            NULL,
  header             VARCHAR(100)                    NULL,
  restricted         TINYINT(1) UNSIGNED DEFAULT '0' NULL,
  comments_moderated TINYINT(1) UNSIGNED DEFAULT '0' NULL,
  active             TINYINT(1) UNSIGNED DEFAULT '1' NOT NULL,
  CONSTRAINT title
  UNIQUE (title)
)
  ENGINE = InnoDB;

CREATE TABLE comments
(
  id           BIGINT(10) UNSIGNED AUTO_INCREMENT
    PRIMARY KEY,
  user_id      INT(5) UNSIGNED                     NOT NULL,
  news_id      BIGINT(10) UNSIGNED                 NOT NULL,
  comment_id   BIGINT(10) UNSIGNED                 NULL,
  comment      TEXT                                NOT NULL,
  created      TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  likes_cnt    INT DEFAULT '0'                     NOT NULL,
  dislikes_cnt INT DEFAULT '0'                     NOT NULL,
  needs_mod    TINYINT DEFAULT '0'                 NOT NULL,
  CONSTRAINT comments_bind_fk
  FOREIGN KEY (comment_id) REFERENCES comments (id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
)
  ENGINE = InnoDB;

CREATE INDEX user_id
  ON comments (user_id);

CREATE INDEX news_id
  ON comments (news_id);

CREATE INDEX comments_bind_fk
  ON comments (comment_id);

CREATE TABLE news
(
  id           BIGINT(10) UNSIGNED AUTO_INCREMENT
    PRIMARY KEY,
  title        VARCHAR(400)                        NOT NULL,
  content      TEXT                                NOT NULL,
  date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  author       VARCHAR(200)                        NULL,
  source_ref   VARCHAR(200)                        NULL,
  image_cap    VARCHAR(200)                        NULL,
  hits_cnt     SMALLINT(6) DEFAULT '0'             NULL,
  active       TINYINT(1) UNSIGNED DEFAULT '0'     NOT NULL
)
  ENGINE = InnoDB;

CREATE INDEX news_date_created_idx
  ON news (date_created);

ALTER TABLE comments
  ADD CONSTRAINT comments_news_id_fk
FOREIGN KEY (news_id) REFERENCES news (id);

CREATE TABLE news_categories
(
  id          BIGINT(10) UNSIGNED AUTO_INCREMENT
    PRIMARY KEY,
  category_id SMALLINT(5) UNSIGNED NOT NULL,
  news_id     BIGINT(10) UNSIGNED  NOT NULL,
  CONSTRAINT news_categories_uid
  UNIQUE (category_id, news_id),
  CONSTRAINT news_categories_ibfk_2
  FOREIGN KEY (category_id) REFERENCES categories (id)
    ON UPDATE CASCADE,
  CONSTRAINT news_categories_news_id_fk
  FOREIGN KEY (news_id) REFERENCES news (id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
)
  ENGINE = InnoDB;

CREATE INDEX category_id
  ON news_categories (category_id);

CREATE INDEX news_categories_news_id_fk
  ON news_categories (news_id);

CREATE TABLE news_tags
(
  id      BIGINT(5) UNSIGNED AUTO_INCREMENT
    PRIMARY KEY,
  news_id BIGINT(10) UNSIGNED  NOT NULL,
  tag_id  SMALLINT(5) UNSIGNED NOT NULL,
  CONSTRAINT news_tags_id
  UNIQUE (news_id, tag_id),
  CONSTRAINT news_tags_ibfk_1
  FOREIGN KEY (news_id) REFERENCES news (id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
)
  ENGINE = InnoDB;

CREATE INDEX news_id
  ON news_tags (news_id);

CREATE INDEX tag_id
  ON news_tags (tag_id);

CREATE TABLE site_ads
(
  id          SMALLINT(5) UNSIGNED AUTO_INCREMENT
    PRIMARY KEY,
  product     VARCHAR(50)                     NOT NULL,
  description TEXT                            NULL,
  price       FLOAT DEFAULT '0'               NOT NULL,
  seller      VARCHAR(100)                    NULL,
  ref         VARCHAR(200)                    NULL,
  active      TINYINT(1) UNSIGNED DEFAULT '1' NULL
)
  ENGINE = InnoDB;

CREATE TABLE tags
(
  id  SMALLINT(5) UNSIGNED AUTO_INCREMENT
    PRIMARY KEY,
  tag VARCHAR(40) NOT NULL,
  CONSTRAINT tag
  UNIQUE (tag)
)
  ENGINE = InnoDB;

ALTER TABLE news_tags
  ADD CONSTRAINT news_tags_ibfk_2
FOREIGN KEY (tag_id) REFERENCES tags (id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

CREATE TABLE tinyint_asc
(
  value TINYINT UNSIGNED DEFAULT '0' NOT NULL
    PRIMARY KEY
)
  ENGINE = InnoDB;

CREATE TABLE url_rewrite
(
  id     INT UNSIGNED AUTO_INCREMENT
    PRIMARY KEY,
  alias  VARCHAR(100) NOT NULL,
  target VARCHAR(100) NOT NULL
)
  ENGINE = InnoDB;

CREATE TABLE users
(
  id       INT(5) UNSIGNED AUTO_INCREMENT
    PRIMARY KEY,
  name     VARCHAR(100)                          NOT NULL,
  login    VARCHAR(45)                           NOT NULL,
  email    VARCHAR(100)                          NOT NULL,
  role     ENUM ('user', 'admin') DEFAULT 'user' NOT NULL,
  password CHAR(32)                              NOT NULL,
  active   TINYINT(1) UNSIGNED DEFAULT '1'       NOT NULL,
  CONSTRAINT users_login_email_uindex
  UNIQUE (login, email)
)
  ENGINE = InnoDB;

ALTER TABLE comments
  ADD CONSTRAINT comments_users_id_fk
FOREIGN KEY (user_id) REFERENCES users (id);

CREATE VIEW news_in_categories AS
  SELECT
    `c`.`id`                 AS `category_id`,
    `c`.`title`              AS `category_title`,
    `c`.`description`        AS `category_description`,
    `c`.`header`             AS `category_header`,
    `c`.`restricted`         AS `category_restricted`,
    `c`.`comments_moderated` AS `category_comments_moderated`,
    `n`.`id`                 AS `news_id`,
    `n`.`title`              AS `title`,
    `n`.`content`            AS `content`,
    `n`.`date_created`       AS `news_date_created`,
    `n`.`author`             AS `author`,
    `n`.`source_ref`         AS `source_ref`,
    `n`.`image_cap`          AS `image_cap`,
    `n`.`hits_cnt`           AS `hits_cnt`,
    `n`.`active`             AS `active`
  FROM ((`mynews`.`news_categories`
    LEFT JOIN `mynews`.`news` `n` ON ((`mynews`.`news_categories`.`news_id` = `n`.`id`))) LEFT JOIN
    `mynews`.`categories` `c` ON ((`mynews`.`news_categories`.`category_id` = `c`.`id`)))
  WHERE (`c`.`active` = 1)
  ORDER BY `c`.`id`, `n`.`date_created` DESC;

CREATE VIEW tags_in_news AS
  SELECT
    `mynews`.`news`.`id`           AS `id`,
    `mynews`.`news`.`title`        AS `title`,
    `mynews`.`news`.`content`      AS `content`,
    `mynews`.`news`.`date_created` AS `date_created`,
    `mynews`.`news`.`author`       AS `author`,
    `mynews`.`news`.`source_ref`   AS `source_ref`,
    `mynews`.`news`.`image_cap`    AS `image_cap`,
    `mynews`.`news`.`hits_cnt`     AS `hits_cnt`,
    `mynews`.`news`.`active`       AS `active`,
    `n`.`tag_id`                   AS `tag_id`,
    `t`.`tag`                      AS `tag`
  FROM ((`mynews`.`news`
    JOIN `mynews`.`news_tags` `n` ON ((`mynews`.`news`.`id` = `n`.`news_id`))) LEFT JOIN `mynews`.`tags` `t`
      ON ((`n`.`tag_id` = `t`.`id`)))
  WHERE (`mynews`.`news`.`active` = 1)
  ORDER BY `t`.`tag`, `mynews`.`news`.`date_created` DESC;


