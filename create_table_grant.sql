-- CREATE USER 'sknteam2'@'localhost' IDENTIFIED BY '1234';
-- GRANT ALL PRIVILEGES ON sknteam2.* TO 'sknteam2'@'localhost';
-- FLUSH PRIVILEGES;
-- 
-- SELECT user, host FROM mysql.user;
create database sknteam2;
use sknteam2;

CREATE table if not exists ev_station (
	id Int primary key auto_increment COMMENT 'ID',
    station_id VARCHAR(100) COMMENT '충전소 ID',
    station_name VARCHAR(200) COMMENT '충전소명',
    address VARCHAR(300) COMMENT '충전소 주소',
    detail_address VARCHAR(300) COMMENT '상세 주소',
    lat DOUBLE COMMENT '위도',
    lon DOUBLE COMMENT '경도',
    available_time VARCHAR(200) COMMENT '이용 시간',
    contact VARCHAR(100) COMMENT '연락처',
    reg_date VARCHAR(50) COMMENT '등록일자',
 	region_code INT COMMENT '도시',
    city_code INT  COMMENT '지역',
    CONSTRAINT fk_ev_region FOREIGN KEY (region_code) REFERENCES region(region_code) ,
    CONSTRAINT fk_ev_city   FOREIGN KEY (city_code)   REFERENCES city(city_code)
);

select * from ev_station
order by station_id;

select count(*) from ev_station;

CREATE TABLE region (
    region_code INT AUTO_INCREMENT PRIMARY KEY COMMENT '지역 코드 (PK)',
    region VARCHAR(50) NOT NULL UNIQUE COMMENT '도시/도 이름'
);

CREATE TABLE city (
    city_code INT AUTO_INCREMENT PRIMARY KEY COMMENT '도시 코드 (PK)',
    city_name VARCHAR(100) NOT NULL COMMENT '시 / 군 / 구 이름',
    region_code INT NOT NULL COMMENT '광역지역 코드 (FK)',
    FOREIGN KEY (region_code) REFERENCES region(region_code)
);


INSERT INTO region (region) VALUES
('서울'),
('대전'),
('부산'),
('대구'),
('광주'),
('제주'),
('경기도'),
('충청북도'),
('충청남도'),
('강원도'),
('경상북도'),
('경상남도'),
('전라북도'),
('전라남도');




-- --------------------------------

CREATE TABLE IF NOT EXISTS ev_vehicle_stats (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '고유 ID',
    region VARCHAR(100) COMMENT '시군구 지역명',
    fuel_type VARCHAR(50) COMMENT '연료 종류 (전기, 수소 등)',
    usage_type VARCHAR(50) COMMENT '차량 용도 (개인, 업무, 공공 등)',
    passenger INT COMMENT '승용 차량 수',
    van INT COMMENT '승합 차량 수',
    truck INT COMMENT '화물 차량 수',
    special INT COMMENT '특수 차량 수',
    total INT COMMENT '전체 차량 수 합계'
) COMMENT='지역별 전기차/친환경차 통계 테이블';

-- -------------------------
CREATE TABLE IF NOT EXISTS ev_regional_status (
    ev_region_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ev_region_id',
    base_date DATE COMMENT '기준일',
    seoul INT COMMENT '서울',
    incheon INT COMMENT '인천',
    gyeonggi INT COMMENT '경기',
    gangwon INT COMMENT '강원',
    chungbuk INT COMMENT '충북',
    chungnam INT COMMENT '충남',
    daejeon INT COMMENT '대전',
    sejong INT COMMENT '세종',
    gyeongbuk INT COMMENT '경북',
    daegu INT COMMENT '대구',
    jeonbuk INT COMMENT '전북',
    jeonnam INT COMMENT '전남',
    gwangju INT COMMENT '광주',
    gyeongnam INT COMMENT '경남',
    busan INT COMMENT '부산',
    ulsan INT COMMENT '울산',
    jeju INT COMMENT '제주'
) COMMENT='지역별 전기차 현황 테이블';

select * from ev_vehicle_stats;
select * from ev_regional_status;


-- -------------------
CREATE TABLE IF NOT EXISTS faq_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title TEXT,
    content TEXT
);


SELECT
    title,
    SUBSTRING(
        title,
        LOCATE('[', title) + 1,
        LOCATE(']', title) - LOCATE('[', title) - 1
    ) AS category,
    LTRIM(SUBSTRING_INDEX(title, ']', -1)) AS question_text
FROM faq_data;

ALTER TABLE faq_data
ADD COLUMN category VARCHAR(255),
ADD COLUMN question_text TEXT;

UPDATE faq_data
SET 
    category = SUBSTRING(
        title,
        LOCATE('[', title) + 1,
        LOCATE(']', title) - LOCATE('[', title) - 1
    ),
    question_text = LTRIM(SUBSTRING_INDEX(title, ']', -1));

ALTER TABLE faq_data
DROP COLUMN title;

ALTER TABLE faq_data
MODIFY COLUMN content text AFTER question_text;

ALTER TABLE faq_data
ADD COLUMN major_category VARCHAR(100),
ADD COLUMN minor_category VARCHAR(100);

UPDATE faq_data
SET major_category = TRIM(SUBSTRING_INDEX(category, '>', 1)),
    minor_category = TRIM(SUBSTRING_INDEX(category, '>', -1));

ALTER TABLE faq_data
DROP COLUMN category;

ALTER TABLE faq_data
MODIFY COLUMN id int not null FIRST;

ALTER TABLE faq_data
MODIFY COLUMN content text AFTER question_text;

ALTER TABLE faq_data
ADD COLUMN major_category VARCHAR(100),
ADD COLUMN minor_category VARCHAR(100);

UPDATE faq_data
SET major_category = TRIM(SUBSTRING_INDEX(category, '>', 1)),
    minor_category = TRIM(SUBSTRING_INDEX(category, '>', -1));

ALTER TABLE faq_data
DROP COLUMN category;

ALTER TABLE faq_data
MODIFY COLUMN id int not null FIRST;

#-------------------------repair_shop 컬럼 나누기(주소)---------------------------

alter table repair_shop
add column region_code varchar(10);



update repair_shop
set region_code = 
	case 
		when location like '%경기도%' then 10
		when location like '%경상남도%' then 7
		when location like '%경상북도%' then 1
		when location like '%광주%' then 11
		when location like '%대구%' then 12
		when location like '%대전%' then 13
		when location like '%부산%' then 14
		when location like '%서울%' then 4
		when location like '%세종%' then 17
		when location like '%울산%' then 15
		when location like '%인천%' then 5
		when location like '%전라남도%' then 3
		when location like '%전라북도%' then 16
		when location like '%제주%' then 6
		when location like '%충청남도%' then 8
		when location like '%충청북도%' then 9
		when location like '%강원%' then 2
		when location like '%전북%' then 16
		else null
	end;
	


alter table repair_shop
add column city_code varchar(10);



UPDATE repair_shop
SET city_code =
    CASE
        WHEN location LIKE '%칠곡군%' THEN 1
        WHEN location LIKE '%동해시%' THEN 2
        WHEN location LIKE '%곡성군%' THEN 3
        WHEN location LIKE '%원주시%' THEN 4
        WHEN location LIKE '%영등포구%' THEN 5
        WHEN location LIKE '%미추홀구%' THEN 6
        WHEN location LIKE '%제주시%' THEN 7
        WHEN location LIKE '%강릉시%' THEN 8
        WHEN location LIKE '%거창군%' THEN 9
        WHEN location LIKE '%공주시%' THEN 10
        WHEN location LIKE '%충주시%' THEN 11
        WHEN location LIKE '%고양시%' THEN 12
        WHEN location LIKE '%용인시%' THEN 13
        WHEN location LIKE '%신안군%' THEN 14
        WHEN location LIKE '%의성군%' THEN 15
        WHEN location LIKE '%평택시%' THEN 16
        WHEN location LIKE '%천안시%' THEN 17
        WHEN location LIKE '%서구%' THEN 18
        WHEN location LIKE '%서구%' THEN 19
        WHEN location LIKE '%서산시%' THEN 20
        WHEN location LIKE '%노원구%' THEN 21
        WHEN location LIKE '%파주시%' THEN 22
        WHEN location LIKE '%서구%' THEN 23
        WHEN location LIKE '%청주시%' THEN 24
        WHEN location LIKE '%북구%' THEN 25
        WHEN location LIKE '%강북구%' THEN 26
        WHEN location LIKE '%마포구%' THEN 27
        WHEN location LIKE '%강동구%' THEN 28
        WHEN location LIKE '%함양군%' THEN 29
        WHEN location LIKE '%해운대구%' THEN 30
        WHEN location LIKE '%안양시%' THEN 31
        WHEN location LIKE '%부평구%' THEN 32
        WHEN location LIKE '%중구%' THEN 33
        WHEN location LIKE '%양천구%' THEN 34
        WHEN location LIKE '%진도군%' THEN 35
        WHEN location LIKE '%수원시%' THEN 36
        WHEN location LIKE '%창원시%' THEN 37
        WHEN location LIKE '%제천시%' THEN 38
        WHEN location LIKE '%울주군%' THEN 39
        WHEN location LIKE '%진안군%' THEN 40
        WHEN location LIKE '%영암군%' THEN 41
        WHEN location LIKE '%춘천시%' THEN 42
        WHEN location LIKE '%영동군%' THEN 43
        WHEN location LIKE '%김해시%' THEN 44
        WHEN location LIKE '%무안군%' THEN 45
        WHEN location LIKE '%영천시%' THEN 46
        WHEN location LIKE '%달성군%' THEN 47
        WHEN location LIKE '%김제시%' THEN 48
        WHEN location LIKE '%남원시%' THEN 49
        WHEN location LIKE '%서초구%' THEN 50
        WHEN location LIKE '%중랑구%' THEN 51
        WHEN location LIKE '%송파구%' THEN 52
        WHEN location LIKE '%순천시%' THEN 53
        WHEN location LIKE '%진천군%' THEN 54
        WHEN location LIKE '%성동구%' THEN 55
        WHEN location LIKE '%은평구%' THEN 56
        WHEN location LIKE '%여수시%' THEN 57
        WHEN location LIKE '%고흥군%' THEN 58
        WHEN location LIKE '%사천시%' THEN 59
        WHEN location LIKE '%동구%' THEN 60
        WHEN location LIKE '%의령군%' THEN 61
        WHEN location LIKE '%광양시%' THEN 62
        WHEN location LIKE '%보은군%' THEN 63
        WHEN location LIKE '%포항시%' THEN 64
        WHEN location LIKE '%나주시%' THEN 65
        WHEN location LIKE '%남구%' THEN 66
        WHEN location LIKE '%영광군%' THEN 67
        WHEN location LIKE '%화순군%' THEN 68
        WHEN location LIKE '%익산시%' THEN 69
        WHEN location LIKE '%전주시%' THEN 70
        WHEN location LIKE '%서귀포시%' THEN 71
        WHEN location LIKE '%당진시%' THEN 72
        WHEN location LIKE '%안동시%' THEN 73
        WHEN location LIKE '%광산구%' THEN 74
        WHEN location LIKE '%함평군%' THEN 75
        WHEN location LIKE '%구리시%' THEN 76
        WHEN location LIKE '%유성구%' THEN 77
        WHEN location LIKE '%목포시%' THEN 78
        WHEN location LIKE '%산청군%' THEN 79
        WHEN location LIKE '%서구%' THEN 80
        WHEN location LIKE '%함안군%' THEN 81
        WHEN location LIKE '%광명시%' THEN 82
        WHEN location LIKE '%광주시%' THEN 83
        WHEN location LIKE '%여주시%' THEN 84
        WHEN location LIKE '%사상구%' THEN 85
        WHEN location LIKE '%밀양시%' THEN 86
        WHEN location LIKE '%창녕군%' THEN 87
        WHEN location LIKE '%구례군%' THEN 88
        WHEN location LIKE '%임실군%' THEN 89
        WHEN location LIKE '%정읍시%' THEN 90
        WHEN location LIKE '%인제군%' THEN 91
        WHEN location LIKE '%양산시%' THEN 92
        WHEN location LIKE '%오산시%' THEN 93
        WHEN location LIKE '%부천시%' THEN 94
        WHEN location LIKE '%서천군%' THEN 95
        WHEN location LIKE '%구미시%' THEN 96
        WHEN location LIKE '%동래구%' THEN 97
        WHEN location LIKE '%남해군%' THEN 98
        WHEN location LIKE '%담양군%' THEN 99
        WHEN location LIKE '%보성군%' THEN 100
        WHEN location LIKE '%김천시%' THEN 101
        WHEN location LIKE '%북구%' THEN 102
        WHEN location LIKE '%장성군%' THEN 103
        WHEN location LIKE '%동구%' THEN 104
        WHEN location LIKE '%부산진구%' THEN 105
        WHEN location LIKE '%영도구%' THEN 106
        WHEN location LIKE '%진주시%' THEN 107
        WHEN location LIKE '%고창군%' THEN 108
        WHEN location LIKE '%통영시%' THEN 109
        WHEN location LIKE '%해남군%' THEN 110
        WHEN location LIKE '%안성시%' THEN 111
        WHEN location LIKE '%장수군%' THEN 112
        WHEN location LIKE '%의왕시%' THEN 113
        WHEN location LIKE '%연수구%' THEN 114
        WHEN location LIKE '%성남시%' THEN 115
        WHEN location LIKE '%안산시%' THEN 116
        WHEN location LIKE '%이천시%' THEN 117
        WHEN location LIKE '%하남시%' THEN 118
        WHEN location LIKE '%북구%' THEN 119
        WHEN location LIKE '%성북구%' THEN 120
        WHEN location LIKE '%동대문구%' THEN 121
        WHEN location LIKE '%구로구%' THEN 122
        WHEN location LIKE '%남동구%' THEN 123
        WHEN location LIKE '%남구%' THEN 124
        WHEN location LIKE '%수성구%' THEN 125
        WHEN location LIKE '%금천구%' THEN 126
        WHEN location LIKE '%광진구%' THEN 127
        WHEN location LIKE '%달서구%' THEN 128
        WHEN location LIKE '%문경시%' THEN 129
        WHEN location LIKE '%중구%' THEN 130
        WHEN location LIKE '%양주시%' THEN 131
        WHEN location LIKE '%무주군%' THEN 132
        WHEN location LIKE '%포천시%' THEN 133
        WHEN location LIKE '%태안군%' THEN 134
        WHEN location LIKE '%금정구%' THEN 135
        WHEN location LIKE '%양양군%' THEN 136
        WHEN location LIKE '%기장군%' THEN 137
        WHEN location LIKE '%동구%' THEN 138
        WHEN location LIKE '%강화군%' THEN 139
        WHEN location LIKE '%합천군%' THEN 140
        WHEN location LIKE '%횡성군%' THEN 141
        WHEN location LIKE '%양평군%' THEN 142
        WHEN location LIKE '%동두천시%' THEN 143
        WHEN location LIKE '%화성시%' THEN 144
        WHEN location LIKE '%음성군%' THEN 145
        WHEN location LIKE '%아산시%' THEN 146
        WHEN location LIKE '%홍성군%' THEN 147
        WHEN location LIKE '%금산군%' THEN 148
        WHEN location LIKE '%부안군%' THEN 149
        WHEN location LIKE '%하동군%' THEN 150
        WHEN location LIKE '%강남구%' THEN 151
        WHEN location LIKE '%평창읍%' THEN 152
        WHEN location LIKE '%보령시%' THEN 153
        WHEN location LIKE '%대덕구%' THEN 154
        WHEN location LIKE '%동작구%' THEN 155
        WHEN location LIKE '%영덕군%' THEN 156
        WHEN location LIKE '%거제시%' THEN 157
        WHEN location LIKE '%가평군%' THEN 158
        WHEN location LIKE '%종로구%' THEN 159
        WHEN location LIKE '%영주시%' THEN 160
        WHEN location LIKE '%예산군%' THEN 161
        WHEN location LIKE '%서대문구%' THEN 162
        WHEN location LIKE '%강진군%' THEN 163
        WHEN location LIKE '%철원군%' THEN 164
        WHEN location LIKE '%태백시%' THEN 165
        WHEN location LIKE '%청송군%' THEN 166
        WHEN location LIKE '%홍천군%' THEN 167
        WHEN location LIKE '%증평군%' THEN 168
        WHEN location LIKE '%삼척시%' THEN 169
        WHEN location LIKE '%완도군%' THEN 170
        WHEN location LIKE '%동구%' THEN 171
        WHEN location LIKE '%고성군%' THEN 172
        WHEN location LIKE '%강서구%' THEN 173
        WHEN location LIKE '%북구%' THEN 174
        WHEN location LIKE '%속초시%' THEN 175
        WHEN location LIKE '%경주시%' THEN 176
        WHEN location LIKE '%상주시%' THEN 177
        WHEN location LIKE '%울진군%' THEN 178
        WHEN location LIKE '%의정부시%' THEN 179
        WHEN location LIKE '%아름동%' THEN 180
        WHEN location LIKE '%종촌동%' THEN 181
        WHEN location LIKE '%김포시%' THEN 182
        WHEN location LIKE '%남양주시%' THEN 183
        WHEN location LIKE '%중구%' THEN 184
        WHEN location LIKE '%한솔동%' THEN 185
        WHEN location LIKE '%어진동%' THEN 186
        WHEN location LIKE '%도담동%' THEN 187
        WHEN location LIKE '%서구%' THEN 188
        WHEN location LIKE '%도봉구%' THEN 189
        WHEN location LIKE '%시흥시%' THEN 190
        WHEN location LIKE '%중구%' THEN 191
        WHEN location LIKE '%용산구%' THEN 192
        WHEN location LIKE '%부여군%' THEN 193
        WHEN location LIKE '%군산시%' THEN 194
        WHEN location LIKE '%군포시%' THEN 195
        WHEN location LIKE '%관악구%' THEN 196
        WHEN location LIKE '%중구%' THEN 197
        WHEN location LIKE '%고운동%' THEN 198
        WHEN location LIKE '%고령군%' THEN 199
        WHEN location LIKE '%사하구%' THEN 200
        WHEN location LIKE '%중구%' THEN 201
        WHEN location LIKE '%논산시%' THEN 202
        WHEN location LIKE '%연제구%' THEN 203
        WHEN location LIKE '%조치원읍%' THEN 204
        WHEN location LIKE '%영월군%' THEN 205
        WHEN location LIKE '%계양구%' THEN 206
        WHEN location LIKE '%단양군%' THEN 207
        WHEN location LIKE '%경산시%' THEN 208
        WHEN location LIKE '%동구%' THEN 209
        WHEN location LIKE '%남구%' THEN 210
        WHEN location LIKE '%소담동%' THEN 211
        WHEN location LIKE '%양구군%' THEN 212
        WHEN location LIKE '%강서구%' THEN 213
        WHEN location LIKE '%남구%' THEN 214
        WHEN location LIKE '%완주군%' THEN 215
        WHEN location LIKE '%연동면%' THEN 216
        WHEN location LIKE '%계룡시%' THEN 217
        WHEN location LIKE '%연천군%' THEN 218
        WHEN location LIKE '%순창군%' THEN 219
        WHEN location LIKE '%고성군%' THEN 220
        WHEN location LIKE '%평창군%' THEN 221
        WHEN location LIKE '%정선군%' THEN 222
        WHEN location LIKE '%나성동%' THEN 223
        WHEN location LIKE '%옥천군%' THEN 224
        WHEN location LIKE '%괴산군%' THEN 225
        WHEN location LIKE '%새롬동%' THEN 226
        WHEN location LIKE '%청도군%' THEN 227
        WHEN location LIKE '%동구%' THEN 228
        WHEN location LIKE '%보람동%' THEN 229
        WHEN location LIKE '%장흥군%' THEN 230
        WHEN location LIKE '%영양군%' THEN 231
        WHEN location LIKE '%고성읍%' THEN 232
        WHEN location LIKE '%예천군%' THEN 233
        WHEN location LIKE '%성주군%' THEN 234
        WHEN location LIKE '%건입동%' THEN 235
        WHEN location LIKE '%봉화군%' THEN 236
        WHEN location LIKE '%군위군%' THEN 237
        WHEN location LIKE '%청양군%' THEN 238
        WHEN location LIKE '%화천군%' THEN 239
        WHEN location LIKE '%옹진군%' THEN 240
        WHEN location LIKE '%대평동%' THEN 241
        WHEN location LIKE '%수영구%' THEN 242
        WHEN location LIKE '%과천시%' THEN 243
        WHEN location LIKE '%다정동%' THEN 244
        WHEN location LIKE '%덕진구%' THEN 245
        WHEN location LIKE '%울릉군%' THEN 246
        WHEN location LIKE '%연기면%' THEN 247
        WHEN location LIKE '%북구%' THEN 248
        WHEN location LIKE '%전의면%' THEN 249
        WHEN location LIKE '%군위군%' THEN 250
        ELSE NULL
    END;

