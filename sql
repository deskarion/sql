DROP database if exists vk;

CREATE DATABASE vk;
USE vk;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY, -- SERIAL = BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
    firstname VARCHAR(50),
    lastname VARCHAR(50) COMMENT 'Р¤Р°РјРёР»СЊ', -- COMMENT РЅР° СЃР»СѓС‡Р°Р№, РµСЃР»Рё РёРјСЏ РЅРµРѕС‡РµРІРёРґРЅРѕРµ
    email VARCHAR(120) UNIQUE,
    phone BIGINT, 
    INDEX users_phone_idx(phone), -- РєР°Рє РІС‹Р±РёСЂР°С‚СЊ РёРЅРґРµРєСЃС‹?
    INDEX users_firstname_lastname_idx(firstname, lastname)
);

DROP TABLE IF EXISTS `profiles`;
CREATE TABLE `profiles` (
	user_id SERIAL PRIMARY KEY,
    gender CHAR(1),
    birthday DATE,
	photo_id BIGINT UNSIGNED NULL,
    created_at DATETIME DEFAULT NOW(),
    hometown VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES users(id) -- РІРЅРµС€РЅРёР№ РєР»СЋС‡
    	ON UPDATE CASCADE -- РїРѕРІРµРґРµРЅРёРµ РїРѕ СѓРјРѕР»С‡Р°РЅРёСЋ РїСЂРё РѕР±РЅРѕРІР»РµРЅРёРё Р·Р°РїРёСЃРё РІ РіР»Р°РІРЅРѕР№ С‚Р°Р±Р»РёС†Рµ
    	ON DELETE restrict -- РїРѕРІРµРґРµРЅРёРµ РїРѕ СѓРјРѕР»С‡Р°РЅРёСЋ РїСЂРё СѓРґР°Р»РµРЅРёРё Р·Р°РїРёСЃРё РІ РіР»Р°РІРЅРѕР№ С‚Р°Р±Р»РёС†Рµ
    -- , FOREIGN KEY (photo_id) REFERENCES media(id) -- РїРѕРєР° СЂР°РЅРѕ, С‚.Рє. С‚Р°Р±Р»РёС†С‹ media РµС‰Рµ РЅРµС‚
);

DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	id SERIAL PRIMARY KEY,
	from_user_id BIGINT UNSIGNED NOT NULL,
    to_user_id BIGINT UNSIGNED NOT NULL,
    body TEXT,
    created_at DATETIME DEFAULT NOW(), -- РјРѕР¶РЅРѕ Р±СѓРґРµС‚ РґР°Р¶Рµ РЅРµ СѓРїРѕРјРёРЅР°С‚СЊ СЌС‚Рѕ РїРѕР»Рµ РїСЂРё РІСЃС‚Р°РІРєРµ
    INDEX messages_from_user_id (from_user_id),
    INDEX messages_to_user_id (to_user_id),
    FOREIGN KEY (from_user_id) REFERENCES users(id),
    FOREIGN KEY (to_user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS friend_requests;
CREATE TABLE friend_requests (
	-- id SERIAL PRIMARY KEY, -- РёР·РјРµРЅРёР»Рё РЅР° СЃРѕСЃС‚Р°РІРЅРѕР№ РєР»СЋС‡ (initiator_user_id, target_user_id)
	initiator_user_id BIGINT UNSIGNED NOT NULL,
    target_user_id BIGINT UNSIGNED NOT NULL,
    -- `status` TINYINT UNSIGNED,
    `status` ENUM('requested', 'approved', 'unfriended', 'declined'),
    -- `status` TINYINT UNSIGNED, -- РІ СЌС‚РѕРј СЃР»СѓС‡Р°Рµ РІ РєРѕРґРµ С…СЂР°РЅРёР»Рё Р±С‹ С†РёС„РёСЂРЅС‹Р№ enum (0, 1, 2, 3...)
	requested_at DATETIME DEFAULT NOW(),
	confirmed_at DATETIME,
	
    PRIMARY KEY (initiator_user_id, target_user_id),
	INDEX (initiator_user_id),
    INDEX (target_user_id),
    FOREIGN KEY (initiator_user_id) REFERENCES users(id),
    FOREIGN KEY (target_user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS communities;
CREATE TABLE communities(
	id SERIAL PRIMARY KEY,
	name VARCHAR(150),

	INDEX communities_name_idx(name)
);

DROP TABLE IF EXISTS users_communities;
CREATE TABLE users_communities(
	user_id BIGINT UNSIGNED NOT NULL,
	community_id BIGINT UNSIGNED NOT NULL,
  
	PRIMARY KEY (user_id, community_id), -- С‡С‚РѕР±С‹ РЅРµ Р±С‹Р»Рѕ 2 Р·Р°РїРёСЃРµР№ Рѕ РїРѕР»СЊР·РѕРІР°С‚РµР»Рµ Рё СЃРѕРѕР±С‰РµСЃС‚РІРµ
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (community_id) REFERENCES communities(id)
);

DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types(
	id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

    -- Р·Р°РїРёСЃРµР№ РјР°Р»Рѕ, РїРѕСЌС‚РѕРјСѓ РёРЅРґРµРєСЃ Р±СѓРґРµС‚ Р»РёС€РЅРёРј (Р·Р°РјРµРґР»РёС‚ СЂР°Р±РѕС‚Сѓ)!
);

DROP TABLE IF EXISTS media;
CREATE TABLE media(
	id SERIAL PRIMARY KEY,
    media_type_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
  	body text,
    filename VARCHAR(255),
    size INT,
	metadata JSON,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX (user_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (media_type_id) REFERENCES media_types(id)
);

DROP TABLE IF EXISTS likes;
CREATE TABLE likes(
	id SERIAL PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    media_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW()

    -- PRIMARY KEY (user_id, media_id) вЂ“ РјРѕР¶РЅРѕ Р±С‹Р»Рѕ Рё С‚Р°Рє РІРјРµСЃС‚Рѕ id РІ РєР°С‡РµСЃС‚РІРµ PK
  	-- СЃР»РёС€РєРѕРј СѓРІР»РµРєР°С‚СЊСЃСЏ РёРЅРґРµРєСЃР°РјРё С‚РѕР¶Рµ РѕРїР°СЃРЅРѕ, СЂР°С†РёРѕРЅР°Р»СЊРЅРµРµ РёС… РґРѕР±Р°РІР»СЏС‚СЊ РїРѕ РјРµСЂРµ РЅРµРѕР±С…РѕРґРёРјРѕСЃС‚Рё (РЅР°РїСЂ., РїСЂРѕРІРёСЃР°СЋС‚ РїРѕ РІСЂРµРјРµРЅРё РєР°РєРёРµ-С‚Рѕ Р·Р°РїСЂРѕСЃС‹)  

/* РЅР°РјРµСЂРµРЅРЅРѕ Р·Р°Р±С‹Р»Рё, С‡С‚РѕР±С‹ РїРѕР·РґРЅРµРµ СѓРІРёРґРµС‚СЊ РёС… РѕС‚СЃСѓС‚СЃС‚РІРёРµ РІ ER-РґРёР°РіСЂР°РјРјРµ
    , FOREIGN KEY (user_id) REFERENCES users(id)
    , FOREIGN KEY (media_id) REFERENCES media(id)
*/
);

DROP TABLE IF EXISTS `photo_albums`;
CREATE TABLE `photo_albums` (
	`id` SERIAL,
	`name` varchar(255) DEFAULT NULL,
    `user_id` BIGINT UNSIGNED DEFAULT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
  	PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `photos`;
CREATE TABLE `photos` (
	id SERIAL PRIMARY KEY,
	`album_id` BIGINT unsigned NOT NULL,
	`media_id` BIGINT unsigned NOT NULL,

	FOREIGN KEY (album_id) REFERENCES photo_albums(id),
    FOREIGN KEY (media_id) REFERENCES media(id)
);
DROP TABLE IF EXISTS `games`;
CREATE TABLE `games` (
 	RPG VARCHAR(50),
    Actionplay VARCHAR(50),
    Symulator VARCHAR(50),
	id SERIAL PRIMARY KEY,
	`games_id` BIGINT unsigned NOT NULL,

	FOREIGN KEY (games_id) REFERENCES games(id)
);
DROP TABLE IF EXISTS `Lovestory`;
CREATE TABLE `Lovestory` (
 	DivineStory VARCHAR(50),
    ShockStory VARCHAR(50),
    FriendkStory VARCHAR(50),
	id SERIAL PRIMARY KEY,
	`Lovestory_id` BIGINT unsigned NOT NULL,

	FOREIGN KEY (Lovestory_id) REFERENCES lovestory(id)
);
DROP TABLE IF EXISTS `Lovestory`;
CREATE TABLE `events` (
 	shock_content VARCHAR(50),
    news_stories VARCHAR(50),
	id SERIAL PRIMARY KEY,
	`events_id` BIGINT unsigned NOT NULL,

	FOREIGN KEY (events_id) REFERENCES events(id)
);
