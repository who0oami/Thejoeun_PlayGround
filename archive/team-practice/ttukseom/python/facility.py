from urllib.parse import urljoin

import requests
import urllib3
from fastapi import APIRouter
from lxml import html
from urllib3.exceptions import InsecureRequestWarning

urllib3.disable_warnings(InsecureRequestWarning)

router = APIRouter()

SOURCE_URL = "https://korean.visitseoul.net/entertainment/X-GAME/KOP6zvjr6"


def _text(node, xpath: str) -> str:
    value = node.xpath(xpath)
    if isinstance(value, list):
        if not value:
            return ""
        value = value[0]
    return " ".join(str(value).split())


def _fallback_recommendations():
    return [
        {
            "title": "뚝섬 한강공원 눈썰매장 개장",
            "description": "뚝섬한강공원의 눈썰매장과 빙어잡기, 놀이기구가 올해도 찾아온다.",
            "url": urljoin(SOURCE_URL, "/events/뚝섬-한강공원-눈썰매장-개장-KR/KOP009044"),
        },
        {
            "title": "뚝섬한강공원",
            "description": "서울 한강변에 위치한 수영장, 눈썰매장, 자전거도로 등 시설의 복합 여가 공간",
            "url": urljoin(SOURCE_URL, "/nature/TtukseomHangngRiverpark/KOPbdyynw"),
        },
        {
            "title": "뚝섬유원지",
            "description": "뚝섬의 한강 변 일대에 조성된 시민공원으로 각종 편의시설이 구비",
            "url": urljoin(SOURCE_URL, "/nature/뚝섬유원지/KOP011395"),
        },
        {
            "title": "아리랑 하우스",
            "description": "한강 뚝섬유원지내에 위치해 수상레저기구와 다양한 음식 및 편의시설이 준비된 곳",
            "url": urljoin(SOURCE_URL, "/entertainment/2024-arirang/KOPp8olr5"),
        },
    ]


def crawl_facility_recommendations():
    response = requests.get(
        SOURCE_URL,
        headers={
            "User-Agent": (
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36"
            )
        },
        timeout=15,
        verify=False,
    )
    if response.status_code >= 400:
        return _fallback_recommendations()

    response.encoding = response.apparent_encoding or "utf-8"
    root = html.fromstring(response.text)
    items = root.xpath(
        '//section[contains(@class, "article-list-element")][.//h3[contains(normalize-space(.), "연관 추천 정보")]]'
        '//ul[contains(@class, "article-list")]/li/a'
    )

    recommendations = []
    for item in items:
        title = _text(item, './/span[contains(@class, "title")]/text()')
        description = _text(item, './/span[contains(@class, "small-text")]/text()')
        href = _text(item, "./@href")
        if not title or not href:
            continue

        recommendations.append(
            {
                "title": title,
                "description": description,
                "url": urljoin(SOURCE_URL, href),
            }
        )

    return recommendations or _fallback_recommendations()


@router.get("/recommendations")
def facility_recommendations():
    return {
        "message": "Facility recommendations loaded.",
        "data": crawl_facility_recommendations(),
    }
