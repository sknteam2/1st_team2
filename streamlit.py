import streamlit as st
import mysql.connector
from mysql.connector import Error

# -----------------------------------------
# 1. MySQL 연결 함수
# -----------------------------------------
def create_connection():
    try:
        conn = mysql.connector.connect(
            host="localhost",       # ← 본인 MySQL 주소
            user="root",            # ← MySQL 아이디
            password="rlaekqls23",        # ← MySQL 비밀번호
            database="sknteam2",     # ← 사용할 데이터베이스명
            charset='utf8'
        )
        if conn.is_connected():
            return conn
    except Error as e:
        st.error(f"DB 연결 오류: {e}")
        return None

# -----------------------------------------
# 2. Streamlit UI 화면
# -----------------------------------------
st.title("최강 2팀 보여줄게")

menu = st.sidebar.radio("메뉴 선택", ["main", "지역별 정비소", "FAQ"])

# -----------------------------------------
# 3. 데이터 조회
# -----------------------------------------
if menu == "main":
    st.subheader("")

    conn = create_connection()
    if conn:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM repair_shop;")  # ← 본인 테이블명 입력
        rows = cursor.fetchall()

        if rows:
            st.table(rows)
        else:
            st.info("표시할 데이터가 없습니다.")

        cursor.close()
        conn.close()


# -----------------------------------------
# 4. 데이터 추가
# -----------------------------------------
elif menu == "지역별 정비소":
    st.subheader("📝 데이터 추가하기")

    col1, col2 = st.columns(2)
    name = col1.text_input("이름 입력")
    age = col2.number_input("나이 입력", min_value=1, max_value=120)

    if st.button("저장하기"):
        conn = create_connection()
        if conn:
            cursor = conn.cursor()
            sql = "INSERT INTO your_table (name, age) VALUES (%s, %s)"
            cursor.execute(sql, (name, age))
            conn.commit()

            st.success("데이터가 성공적으로 저장되었습니다! 🎉")

            cursor.close()
            conn.close()

elif menu == "FAQ":
    st.subheader("📝 데이터 추가하기")

    col1, col2 = st.columns(2)
    name = col1.text_input("이름 입력")
    age = col2.number_input("나이 입력", min_value=1, max_value=120)

    if st.button("저장하기"):
        conn = create_connection()
        if conn:
            cursor = conn.cursor()
            sql = "INSERT INTO your_table (name, age) VALUES (%s, %s)"
            cursor.execute(sql, (name, age))
            conn.commit()

            st.success("데이터가 성공적으로 저장되었습니다! 🎉")

            cursor.close()
            conn.close()
