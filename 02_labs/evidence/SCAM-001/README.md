# SCAM-001 — Podejrzana wiadomość podszywająca się pod PGE

**Klasyfikacja:** Phishing / scam  
**Ocena ryzyka:** HIGH  
**Status:** Potwierdzony przypadek podejrzanej wiadomości; interakcję z witryną przerwano na ostrzeżeniu przeglądarki.

## 1. Evidence

- `SCAM-001_original.eml` — oryginalna wiadomość EML.
- `SCAM-001_01_certificate_warning.png` — Chrome: `NET::ERR_CERT_COMMON_NAME_INVALID` dla `sagabfm.main.jp`.
- `SCAM-001_02_chrome_dangerous_site.png` — Chrome: „Niebezpieczna strona”.

## 2. Najważniejsze obserwacje

1. Wiadomość wyświetla nazwę nadawcy **PGE**, ale rzeczywisty adres nadawcy znajduje się w domenie `stu.spencer.kyschools.us`.
2. Nagłówki pokazują poprawne uwierzytelnienie techniczne dla tej domeny: SPF=pass, DKIM=pass, DMARC=pass. Nie potwierdza to tożsamości PGE.
3. Link przycisku „Portal Klienta” prowadzi do `https://sagabfm.main.jp/shop_file/shop_images/sh8603/png/`.
4. W wiadomości znajduje się także `data-saferedirecturl` z parametrem `url`, którego wartość Base64 dekoduje się do `https://gkd14.bemobtrk.com/`.
5. Wiadomość zawiera również link `http://www.gkpge.pl/`, który nie jest adresem domeny użytym jako nadawca ani adresem docelowym przycisku.
6. Podczas kontrolowanej obserwacji w zwykłej przeglądarce Chrome wystąpił błąd certyfikatu `NET::ERR_CERT_COMMON_NAME_INVALID`, a następnie ostrzeżenie „Niebezpieczna strona”. Interakcję zakończono bez obchodzenia ostrzeżeń.

## 3. Wnioski

Przypadek należy traktować jako phishing/scam podszywający się pod PGE. Najsilniejsze wskaźniki to niespójność tożsamości nadawcy, niepowiązana domena docelowa oraz ostrzeżenia przeglądarki.

### Ważna obserwacja dydaktyczna

SPF/DKIM/DMARC mogą potwierdzić, że wiadomość została wysłana z autoryzowanej infrastruktury danej domeny. Nie oznacza to, że domena należy do marki, pod którą wiadomość się podszywa. W tym przypadku uwierzytelnienie dotyczy `stu.spencer.kyschools.us`, a nie PGE.

## 4. Zasady bezpieczeństwa zastosowane podczas analizy

- Nie obchodzono ostrzeżenia certyfikatu.
- Nie kontynuowano na stronę po ostrzeżeniu „Niebezpieczna strona”.
- Nie wprowadzano żadnych danych uwierzytelniających ani danych płatniczych.
- Dalsza aktywna analiza URL powinna zostać wykonana dopiero w izolowanym środowisku laboratoryjnym projektu.

## 5. Planowana dalsza analiza

Po ukończeniu infrastruktury laboratoryjnej przewidzianej w projekcie przypadek może posłużyć jako materiał testowy do:

- analizy DNS/TLS,
- analizy przekierowań HTTP,
- obserwacji żądań sieciowych,
- analizy fingerprintingu strony,
- analizy zachowania JavaScript,
- identyfikacji mechanizmu phishingowego,
- dokumentacji IOC.

**Nie należy uruchamiać aktywnej analizy z systemu produkcyjnego.**
