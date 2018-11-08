BEGIN TRANSACTION;

-- Enable UUID plugin
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tables Creations
CREATE TABLE IF NOT EXISTS "item" (
  "id"          INTEGER   PRIMARY KEY,
  "title"       VARCHAR   NOT NULL,
  "description" VARCHAR   NULL,
  "url"         VARCHAR   NOT NULL,
  "item_type"   VARCHAR   NOT NULL,
  "created_at"  DATE      NULL      DEFAULT NULL,
  "uuid"        UUID      NOT NULL  DEFAULT UUID_GENERATE_V4()
);

CREATE TABLE IF NOT EXISTS "author" (
  "id"         INTEGER PRIMARY KEY,
  "first_name" VARCHAR NOT NULL,
  "last_name"  VARCHAR NOT NULL,
  "uuid"       UUID    NOT NULL DEFAULT UUID_GENERATE_V4()
);

CREATE TABLE IF NOT EXISTS "item_author" (
  "id"        INTEGER PRIMARY KEY,
  "item_id"   INTEGER NOT NULL REFERENCES "item",
  "author_id" INTEGER NOT NULL REFERENCES "author",
  CONSTRAINT  "unique_item_author" UNIQUE ("item_id","author_id")
);

CREATE TABLE IF NOT EXISTS "tag" (
  "id"   INTEGER PRIMARY KEY,
  "name" VARCHAR NOT NULL
);

CREATE TABLE IF NOT EXISTS "item_tag" (
  "id"       INTEGER PRIMARY KEY,
  "item_id"  INTEGER NOT NULL REFERENCES "item",
  "tag_id"   INTEGER NOT NULL REFERENCES "tag",
  CONSTRAINT "unique_item_tag" UNIQUE ("item_id","tag_id")
);

-- Data Insertion
INSERT INTO "item" (id, title, description, url, item_type, created_at) VALUES
    (1, 'Escape from the ivory tower: the Haskell journey', 'In this talk Simon discusses Haskell’s birth and evolution, including some of the research and engineering challenges he faced in design and implementation.', 'https://www.youtube.com/watch?v=re96UgMk6GQ', 'Video', '2017-03-01')
  , (2, 'Adventure with Types in Haskell', 'Recorded at Oregon Programming Languages Summer School 2013', 'https://www.youtube.com/watch?v=6COvD8oynmI', 'Video', '2013-07-01')
  , (3, 'Haskell Design Patterns: The Handle Pattern', 'A neat and simple way to build services in Haskell', 'https://jaspervdj.be/posts/2018-03-08-handle-pattern.html', 'Tutorial', '2018-03-08')
  , (4, 'The Design and Use of QuickCheck', 'QuickCheck is the grandfather of property-based testing libraries. Despite being imitated in over thirty languages, the original implementation remains pre-eminent due to the type system and consistent logic of the Haskell language in which it is written.', 'https://begriffs.com/posts/2017-01-14-design-use-quickcheck.html', 'Tutorial', '2017-01-14')
  , (5, 'Lenses', 'Lens tour and tutorial', 'http://www.haskellforall.com/2012/01/haskell-for-mainstream-programmers_28.html', 'Tutorial', '2012-01-28')
  , (6, 'Lens Over Tea #1', 'lenses 101, traversals 101, and some implementation details', 'https://artyom.me/lens-over-tea-1', 'Tutorial', '2016-01-01')
  , (7, 'Lenses and functional references', 'This chapter is about functional references. By "references", we mean they point at parts of values, allowing us to access and modify them. By "functional", we mean they do so in a way that provides the flexibility and composability we came to expect from functions. We will study functional references as implemented by the powerful lens library. lens is named after lenses, a particularly well known kind of functional reference. Beyond being very interesting from a conceptual point of view, lenses and other functional references allow for several convenient and increasingly common idioms, put into use by a number of useful libraries.', 'https://en.wikibooks.org/wiki/Haskell/Lenses_and_functional_references', 'Book', '2018-06-19')
  ;

INSERT INTO "tag" (id, name) VALUES
    (1, 'type class')
  , (2, 'functor')
  , (3, 'applicative')
  , (4, 'monad')
  , (5, 'category theory')
  , (6, 'type inference')
  , (7, 'free monad')
  , (8, 'effect')
  , (9, 'extensible effect')
  , (10, 'quickcheck')
  , (11, 'testing')
  , (12, 'property based testing')
  , (13, 'design pattern')
  , (14, 'dependency injection')
  , (15, 'lens')
  ;

-- TODO: add a nickname or handle?
-- , (10, 'jaspervdj')
-- , (11, 'begriffs')
INSERT INTO "author" (id, first_name, last_name) VALUES
    (1, 'Simon', 'Peyton Jones')
  , (2, 'Edward', 'Kmett')
  , (3, 'Jasper', 'Van der Jeugt')
  , (4, 'Joe', 'Nelson')
  , (5, 'Gabriel', 'Gonzales')
  , (6, 'Artyom', 'Kazak')
  ;

INSERT INTO "item_author" (id, item_id, author_id) VALUES
    (1, 1, 1)
  , (2, 2, 1)
  , (3, 3, 3)
  , (4, 4, 4)
  , (5, 5, 5)
  , (6, 6, 6)
  ;

INSERT INTO "item_tag" (id, item_id, tag_id) VALUES
    (1, 1, 1)
  , (2, 1, 4)
  , (3, 2, 6)
  , (4, 3, 13)
  , (5, 3, 14)
  , (6, 4, 10)
  , (7, 4, 11)
  , (8, 4, 12)
  , (9, 5, 15)
  , (10, 6, 15)
  , (11, 7, 15)
  ;

COMMIT;

-- INSERT INTO "item" (id, title, description, url, item_type, created_at) VALUES (4, 'title', 'description', 'url', 'Video', '2018-03-01') ;
