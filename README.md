# Cyberbezpieczeństwo - repozytorium wiedzy

## Cel
Repozytorium łączy teorię, laboratoria, rejestry źródeł, standardy, raporty i dowody w sposób umożliwiający odtworzenie pracy.

## Zasady
1. Nie zapisuj sekretów, realnych poświadczeń ani danych osobowych.
2. Każde laboratorium ma identyfikator, zakres, wersje narzędzi i ścieżkę do dowodów.
3. Źródła mają identyfikator i datę weryfikacji.
4. Opublikowane wydania są oznaczane tagiem Git i wpisem w CHANGELOG.md.
5. Git nie zastępuje kopii zapasowej; wykonuj i testuj osobne kopie.

## Szybki start
```powershell
git init
git status
git add .
git commit -m "chore(repo): utworzenie struktury repozytorium wiedzy"
```

## Rejestry
- `00_admin/registers/sources.csv`
- `00_admin/registers/standards.csv`
- `00_admin/registers/labs.csv`
- `00_admin/registers/backups.csv`

## Szablony
- `00_admin/templates/technical-report.md`
- `00_admin/templates/incident-report.md`
- `00_admin/templates/lab-report.md`
