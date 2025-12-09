import os
import requests
import pandas as pd
import pymysql
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("PUBLIC_DATA_API_KEY")
BASE_URL = os.getenv("PUBLIC_STATION_BASE_URL")
PASSWORD = os.getenv("PASSWORD")


# 1) 지역 이름 표준화

def normalize_region(region: str):
    if not region:
        return None

    region = region.strip()

    mapping = {
        "서울특별시": "서울",
        "부산광역시": "부산",
        "대구광역시": "대구",
        "인천광역시": "인천",
        "광주광역시": "광주",
        "대전광역시": "대전",
        "울산광역시": "울산",
        "세종특별자치시": "세종",

        "경기도": "경기도",
        "경기": "경기도",

        "강원도": "강원도",
        "강원특별자치도": "강원도",

        "충북": "충청북도",
        "충청북도": "충청북도",
        "충남": "충청남도",
        "충청남도": "충청남도",

        "전북": "전라북도",
        "전북특별자치도": "전라북도",
        "전라북도": "전라북도",

        "전남": "전라남도",
        "전라남도": "전라남도",

        "경북": "경상북도",
        "경상북도": "경상북도",

        "경남": "경상남도",
        "경상남도": "경상남도",

        "제주특별자치도": "제주",
        "제주도": "제주",
        "제주": "제주",
    }

    return mapping.get(region, region)


def normalize_city(city: str):
    if not city:
        return None
    return city.strip()



# 2) 주소 파싱

def extract_region_city(address: str):
    if not address or not isinstance(address, str):
        return None, None

    parts = address.split()
    if len(parts) < 2:
        return None, None

    region_raw = parts[0]  # 서울특별시 / 경기 / 전북 등
    city_raw = parts[1]    # 중구 / 성남시 / 익산시 등

    region = normalize_region(region_raw)
    city = normalize_city(city_raw)

    return region, city



# 3) Region / City 조회·생성

def get_or_create_region(cursor, region):
    sql_select = "SELECT region_code FROM region WHERE region = %s"
    cursor.execute(sql_select, (region,))
    row = cursor.fetchone()

    if row:
        return row[0]

    sql_insert = "INSERT INTO region (region) VALUES (%s)"
    cursor.execute(sql_insert, (region,))
    return cursor.lastrowid


def get_or_create_city(cursor, city_name, region_code):
    sql_select = "SELECT city_code FROM city WHERE city_name = %s AND region_code = %s"
    cursor.execute(sql_select, (city_name, region_code))
    row = cursor.fetchone()

    if row:
        return row[0]

    sql_insert = "INSERT INTO city (city_name, region_code) VALUES (%s, %s)"
    cursor.execute(sql_insert, (city_name, region_code))
    return cursor.lastrowid



# 4) 공공데이터 API 호출

def fetch_ev_station_data():
    url = f"https://{BASE_URL}"

    all_rows = []
    page = 1
    per_page = 100

    while True:
        params = {
            "page": page,
            "perPage": per_page,
            "serviceKey": API_KEY
        }

        res = requests.get(url, params=params)
        res.raise_for_status()
        data = res.json()

        rows = data.get("data", [])
        if not rows:
            break

        all_rows.extend(rows)
        print(f"{page} 페이지 로드 완료 (rows: {len(rows)})")
        page += 1

    df = pd.DataFrame(all_rows)
    print("총 데이터 수:", len(df))
    return df



# 5) 최종 DB 삽입

def insert_ev_stations_to_db():
    df = fetch_ev_station_data()

    conn = pymysql.connect(
        host="localhost",
        user="root",
        password=PASSWORD,
        database="sknteam2",
        charset="utf8mb4"
    )
    cursor = conn.cursor()

    sql_insert_station = """
        INSERT INTO ev_station (
            station_id, station_name, address, detail_address,
            lat, lon, available_time, contact, reg_date,
            region_code, city_code
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """

    inserted = 0

    for _, row in df.iterrows():
        address = row.get("충전소주소")
        region, city = extract_region_city(address)

        if not region or not city:
            continue  # 주소가 비정상인 경우

        # FK 매핑
        region_code = get_or_create_region(cursor, region)
        city_code = get_or_create_city(cursor, city, region_code)

        values = (
            row.get("충전소아이디"),
            row.get("충전소명"),
            address,
            row.get("상세주소"),
            row.get("위도"),
            row.get("경도"),
            row.get("이용가능시간"),
            row.get("연락처"),
            row.get("등록일자"),
            region_code,
            city_code
        )

        cursor.execute(sql_insert_station, values)
        inserted += 1

    conn.commit()

    print(f"\n총 {inserted}개의 데이터가 ev_station 테이블에 삽입되었습니다.")

    cursor.close()
    conn.close()


if __name__ == "__main__":
    insert_ev_stations_to_db()
