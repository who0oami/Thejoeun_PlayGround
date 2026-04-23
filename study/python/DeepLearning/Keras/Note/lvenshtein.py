"""
Created on Sun Feb  6 02:14:32 2022

@author: kenny
"""


class Lvenshtein():
    def calc_distance(self, a, b):
        if a == b: return 0
        a_len = len(a)
        b_len = len(b)
        if a == "": return b_len
        if b == "": return a_len
        # 2차원 표 (a_len+1, b_len+1) 준비하기 -
        matrix = [[] for i in range(a_len+1)]
        for i in range(a_len+1): # 0으로 초기화
            matrix[i] = [0 for j in range(b_len+1)]
        # 0일 때 초기값을 설정
        for i in range(a_len+1):
            matrix[i][0] = i
        for j in range(b_len+1):
            matrix[0][j] = j
        # 표 채우기 
        for i in range(1, a_len+1):
            ac = a[i-1]
            for j in range(1, b_len+1):
                bc = b[j-1]
                cost = 0 if (ac == bc) else 1
                matrix[i][j] = min([
                    matrix[i-1][j] + 1,     # 문자 삽입
                    matrix[i][j-1] + 1,     # 문자 제거
                    matrix[i-1][j-1] + cost # 문자 변경
                ])
        return matrix[a_len][b_len]

