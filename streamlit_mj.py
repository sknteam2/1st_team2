import os
from dotenv import load_dotenv
import streamlit as st
import mysql.connector
from mysql.connector import Error
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
menu = st.sidebar.radio("메뉴 선택", ["main", "지역별 정비소", "FAQ"])

# -----------------------------------------
# 3. main 페이지
# -----------------------------------------
if menu == "main":
    st.title("최강 2팀 보여줄게")

    region_map = {
        "seoul": "서울",
        "busan": "부산",
        "daegu": "대구",
        "incheon": "인천",
        "gwangju": "광주",
        "daejeon": "대전",
        "ulsan": "울산",
        "sejong": "세종",
        "gyeonggi": "경기",
        "gangwon": "강원",
        "chungbuk": "충북",
        "chungnam": "충남",
        "jeonbuk": "전북",
        "jeonnam": "전남",
        "gyeongbuk": "경북",
        "gyeongnam": "경남",
        "jeju": "제주"  
    }

    # 2. 사용자에게 지역 선택을 받습니다.
    # 매핑된 한글 지역 이름(값)을 사용자에게 보여주고, 실제 DB 컬럼명(키)을 내부적으로 사용합니다.
    # 한글 지역 이름 딕셔너리에서 value값을 리스트로 가져와 korean_regions에 저장
    korean_regions = list(region_map.values())

    # selectbox에 한글 지역 이름을 보여줌
    selected_korean_region = st.selectbox("지역을 선택하세요:", korean_regions)

    # 3. 선택된 한글 지역명에 해당하는 DB 컬럼명(key)을 찾습니다.
    selected_db_column = None # 초기값 설정 (찾지 못했을 경우 대비)

    for key, val in region_map.items():
        if val == selected_korean_region:
            selected_db_column = key
            break # 일치하는 것을 찾았으므로 루프를 즉시 종료

    if selected_db_column is None:
        st.error("잘못된 지역이 선택되었습니다.")
        st.stop()

    # 4. DB 연결 및 쿼리 실행
    conn = create_connection() # 기존에 정의된 함수 사용
    if conn is None:
        st.stop()

    cursor = conn.cursor(dictionary=True)

    # base_date와 선택된 지역의 컬럼 데이터 전체를 가져오는 쿼리
    query = f"""
    SELECT base_date, {selected_db_column}
    FROM ev_regional_status
    ORDER BY base_date ASC
    """

    try:
        cursor.execute(query)
        rows = cursor.fetchall()
    except Exception as e:
        st.error(f"쿼리 실행 중 오류 발생: {e}")
        rows = []

    if not rows:
        st.error(f"선택한 지역 ({selected_korean_region})에 대한 데이터가 없습니다.")
        st.stop()

    # 5. 데이터 처리 (Pandas DataFrame 생성)
    # base_date를 '기간'으로, 선택된 지역의 차량 수를 '차량 수'로 설정합니다.
    chart_df = pd.DataFrame(rows)
    chart_df.rename(columns={
        'base_date': '기간',
        selected_db_column: '차량 수'
    }, inplace=True)

    # 기간(base_date)을 인덱스로 설정하고 라인 차트 생성 (시계열 데이터에 적합)
    # chart_df['기간'] = pd.to_datetime(chart_df['기간'])
    # chart_df = chart_df.sort_values('기간')
    st.subheader(f"📈 {selected_korean_region} 지역별 차량 증감 추이")

    # 라인 차트 사용: 시계열(시간의 변화)에 따른 증감 추이를 보기 좋습니다.
    # st.bar_chart는 범주형에 더 적합하지만, 요구사항에 맞춰 bar_chart를 유지하거나 line_chart를 사용합니다.
    st.bar_chart(chart_df.set_index("기간"))

    st.dataframe(chart_df)

    # 6. DB 연결 종료
    cursor.close()
    conn.close()

    
# -----------------------------------------
# 4. 지역별 정비소
# -----------------------------------------
elif menu == "지역별 정비소":
    st.subheader("🚩지역별 정비소 위치")

    col1, col2, col3, col4 = st.columns(4)
    with col1:
        address = st.text_input("주소")

    with col2:
        company = st.selectbox("회사명", options=[])

    with col3:
        region = st.selectbox("시/도", options=[])

    with col4:
        city = st.selectbox("시/군/구", options=[])

elif menu == "FAQ":
    st.subheader("📝 데이터 추가하기")

    col1, col2 = st.columns(2)


