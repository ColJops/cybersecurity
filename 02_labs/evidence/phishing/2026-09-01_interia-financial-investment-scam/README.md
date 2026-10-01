@'

\# Case Study — interia.financial Investment Scam



\## 1. Informacje podstawowe



\- \*\*Data pozyskania materiału:\*\* 2026-09-01

\- \*\*Typ incydentu:\*\* podejrzany scam inwestycyjny / phishing / brand impersonation

\- \*\*Podszywanie się pod markę:\*\* Interia

\- \*\*Podejrzana domena:\*\* `interia\[.]financial`

\- \*\*Oficjalna domena marki:\*\* `interia.pl`

\- \*\*Status zgłoszenia:\*\* zgłoszono do CERT Polska

\- \*\*Numer sprawy CERT Polska:\*\* `6161474`

\- \*\*Status CERT:\*\* zgłoszenie przyjęte, rozpoczęto obsługę incydentu



\## 2. Opis zdarzenia



Zidentyfikowano stronę internetową działającą w domenie:



`interia\[.]financial`



Strona wizualnie i treściowo podszywa się pod portal informacyjny Interia.



Wykorzystuje sensacyjny artykuł dotyczący osób publicznych oraz rzekomej

platformy umożliwiającej uzyskiwanie wysokich zysków finansowych.



Na podstawie analizy adresu URL, sposobu prezentacji treści oraz zastosowanych

mechanizmów śledzenia stronę zaklasyfikowano roboczo jako potencjalny scam

inwestycyjny wykorzystujący techniki socjotechniczne oraz brand impersonation.



Ocena ta stanowi analizę własną. Przyjęcie zgłoszenia przez CERT Polska

oznacza rozpoczęcie obsługi incydentu, ale samo w sobie nie stanowi

potwierdzenia końcowej klasyfikacji strony przez CERT.



\## 3. IOC — Indicators of Compromise / Interest



\### Domena



`interia\[.]financial`



\### Ścieżka URL



`/kulczyk-oskarza-domanskiego-tajna-platforma-milionowa-wychodzi-na-jaw-ao/`



\### Parametry obserwowane w URL



\- `lp`

\- `aff\_click\_id`

\- `lptoken`

\- `cep`

\- `cpid`



Parametry mogą być wykorzystywane przez system kampanii reklamowych,

sieć afiliacyjną, mechanizm śledzenia kliknięć lub infrastrukturę

landing page.



Pełny oryginalny URL został zachowany w materiale dowodowym.



\## 4. Zaobserwowane techniki socjotechniczne



W analizowanym przypadku zaobserwowano m.in.:



\- podszywanie się pod rozpoznawalny portal informacyjny,

\- wykorzystanie domeny wizualnie kojarzącej się z legalną marką,

\- sensacyjny nagłówek mający wzbudzić ciekawość,

\- wykorzystanie nazwisk osób publicznych,

\- narrację dotyczącą łatwego lub wysokiego zysku finansowego,

\- wykorzystanie landing page,

\- identyfikatory i parametry śledzące kampanię reklamową.



Techniki te są charakterystyczne dla kampanii fraudowych opartych

na socjotechnice i fałszywych inwestycjach.



\## 5. Materiał dowodowy



\### interia-financial.mhtml



Lokalna kopia analizowanej strony zapisana z przeglądarki w formacie MHTML.



\*\*SHA-256:\*\*



`8925C0712BE07CEC6F55FB4FF7F92059A0404789DF87624E4D1732E9B9227A8F`



\---



\### CERT-PL-6161474-confirmation.pdf



Potwierdzenie przyjęcia zgłoszenia przez CERT Polska oraz rozpoczęcia

obsługi incydentu.



\*\*Numer sprawy:\*\*



`6161474`



\*\*SHA-256:\*\*



`518D4CDC88C4AB588D57A09FF0B08000FE08ADDA488AE349C20E2F36DE7F686C`



\---



\### SHA256SUMS.csv



Manifest zawierający sumy kontrolne SHA-256 artefaktów zabezpieczonych

w ramach case study.



\## 6. Integralność materiału



Integralność podstawowych artefaktów została zabezpieczona poprzez

obliczenie kryptograficznych sum kontrolnych SHA-256.



Do weryfikacji można wykorzystać PowerShell:



```powershell

Get-FileHash ".\\interia-financial.mhtml" -Algorithm SHA256

Get-FileHash ".\\CERT-PL-6161474-confirmation.pdf" -Algorithm SHA256

