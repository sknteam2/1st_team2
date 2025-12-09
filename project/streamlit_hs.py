import streamlit as st
import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv
import os
import pandas as pd
import plotly.express as px

# -----------------------------
# 1. 환경변수 & DB 연결
# -----------------------------
load_dotenv()
PASSWORD = os.getenv('PASSWORD')

def create_connection():
    try:
        conn = mysql.connector.connect(
            host="localhost",
            user="root",
            password=PASSWORD,
            database="sknteam2",
            charset='utf8'
        )
        if conn.is_connected():
            return conn
    except Error as e:
        st.error(f"DB 연결 오류: {e}")
        return None

# -----------------------------
# 2. 사이드바 메뉴
# -----------------------------
menu = st.sidebar.radio("메뉴 선택", ["main", "정비소", "FAQ"])

# -----------------------------
# 3. main 페이지
# -----------------------------
if menu == "main":
    st.title("최강 2팀 보여줄게")

    # --- 상단 검색 UI ---
    col1, col2, col3 = st.columns([4, 2, 2])
    address = col1.text_input("주소 검색")
    city = col2.selectbox("도시", ["전체", "서울", "부산", "대구"])
    district = col3.selectbox("시/군/구", ["전체"])

    st.markdown("---")

    # --- SQL 데이터 조회 ---
    conn = create_connection()
    if conn:
        query = """
        SELECT s.station_id, s.station_name, s.address, s.detail_address,
                s.lat, s.lon, s.available_time, s.contact, s.reg_date,
                r.region AS region_name,
                c.city_name AS city_name
        FROM ev_station s
        LEFT JOIN region r ON s.region_code = r.region_code
        LEFT JOIN city c ON s.city_code = c.city_code
        limit 10
        """
        df = pd.read_sql(query, conn)
        conn.close()        

         # --- 사이드바 필터 ---
        region_list = ["전체"] + sorted(df['region_name'].dropna().unique().tolist())
        city_list = ["전체"] + sorted(df['city_name'].dropna().unique().tolist())

        selected_region = st.sidebar.selectbox("지역 선택", region_list)
        selected_city = st.sidebar.selectbox("시/군/구 선택", city_list)

        filtered_df = df.copy()

        if selected_region != "전체":
            filtered_df = filtered_df[filtered_df['region_name'] == selected_region]

        if selected_city != "전체":
            filtered_df = filtered_df[filtered_df['city_name'] == selected_city]
        
        st.subheader("충전소 위치")
        st.table(df)

        st.markdown("---")
        
       
