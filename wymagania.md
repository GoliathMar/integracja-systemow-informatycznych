# Wymagania systemu medycznego

## Wymagania funkcjonalne

### Użytkownicy, role i administracja

1. System musi umożliwiać rejestrację i logowanie użytkowników z podziałem na role: pacjent, lekarz, recepcjonista, administrator.
2. Administrator musi móc zakładać konta pracowników, przypisywać role i placówki oraz inicjować wysyłkę danych dostępowych.
3. Recepcjonista musi móc zarejestrować lekarza w systemie na podstawie formularza, a system musi wspierać weryfikację kompletności danych i aktywację konta.
4. Administrator musi móc dodać nową placówkę medyczną na podstawie procesu formularzowego z walidacją danych i informacją zwrotną.

### Rejestracja wizyt i dostępność terminów

5. Pacjent i recepcjonista muszą móc wyszukiwać dostępne terminy i specjalistów.
6. System musi weryfikować dostępność terminu przed utworzeniem rezerwacji.
7. W przypadku braku dostępnego terminu system musi umożliwić zaproponowanie alternatywnego terminu i decyzję użytkownika o akceptacji lub odrzuceniu.
11. Po udanej płatności system musi automatycznie dodać wizytę do grafiku lekarza.

### Płatności i potwierdzenia

8. System musi tymczasowo blokować wybrany termin na czas procesu płatności.
9. System musi obsługiwać płatność online przez bramkę płatniczą oraz odbierać status transakcji.
10. System musi obsługiwać limit czasu na opłacenie wizyty i anulować rejestrację po jego przekroczeniu.
12. System musi wysyłać potwierdzenia rejestracji i anulowania wizyty do pacjenta.
13. W przypadku błędu automatycznej wysyłki potwierdzenia system musi wspierać tryb potwierdzenia manualnego przez personel.

### Anulowanie wizyt i zwroty

14. Pacjent, lekarz i recepcjonista muszą móc inicjować anulowanie wizyty.
15. System musi sprawdzać, czy anulowanie wizyty jest dozwolone (np. ograniczenia czasowe, status wizyty).
16. W przypadku anulowania opłaconej wizyty system musi inicjować proces zwrotu płatności przez bramkę.
17. System musi rozróżniać anulowanie ze zwrotem i bez zwrotu oraz powiadamiać pacjenta o wyniku.
18. System musi zwalniać termin po skutecznym anulowaniu wizyty.

### Realizacja wizyty i historia medyczna

19. Lekarz musi móc zakończyć wizytę poprzez uzupełnienie formularza po wizycie (notatki, dane medyczne).
20. System musi aktualizować historię wizyt i metryki operacyjne po zakończeniu lub anulowaniu wizyty.

### Portal pacjenta i obsługa wyjątków

21. Portal pacjenta musi umożliwiać podstawowe akcje sesyjne: logowanie, wybór akcji, umówienie wizyty, anulowanie wizyty, wylogowanie.
22. System musi obsługiwać ścieżki wyjątków procesowych: błędy walidacji, błędy grafiku, błędy systemowe, eskalacja do administratora.
