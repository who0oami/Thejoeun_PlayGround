"""
Created on Sun Feb  6 05:41:18 2022

@author: kenny
"""


class Ngram():
    def ngram(self, s, num):
        res = []
        slen = len(s) - num + 1
        for i in range(slen):
            ss = s[i:i+num]
            res.append(ss)
        return res

    def diff_ngram(self, sa, sb, num):
        a = self.ngram(sa, num)
        b = self.ngram(sb, num)
        r = []
        cnt = 0
        for i in a:
            for j in b:
                if i == j:
                    cnt += 1
                    r.append(i)
        return cnt / len(a), r    