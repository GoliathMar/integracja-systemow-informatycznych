workspace "C4 L1 - System Medyczny" "Poziom 1 C4 (System Context) na podstawie BPMN" {
  !identifiers hierarchical

  model {
    pacjent = person "Pacjent" "Rejestruje i anuluje wizyty oraz odbiera powiadomienia."
    lekarz = person "Lekarz" "Zarzadza grafikiem, anuluje i finalizuje wizyty."
    recepcjonista = person "Recepcjonista" "Rejestruje wizyty i obsluguje anulowania w recepcji."
    administrator = person "Administrator" "Zarządza kontami, usługami i konfiguracją."

    systemMedyczny = softwareSystem "System Medyczny" "Centralny system obslugi wizyt, platnosci, anulowan, kont i historii medycznej."
    systemPlatnosci = softwareSystem "System Platniczy (PayU)" "Obsluga platnosci i zwrotow."
    systemKomunikacji = softwareSystem "Uslugi komunikacyjne (Email / Kalendarz)" "Dostarczanie powiadomien i synchronizacja wydarzen."

    pacjent -> systemMedyczny "Rejestracja wizyty, anulowanie wizyty, przegląda historię wizyt"
    lekarz -> systemMedyczny "Anulowanie wizyt, dodaje po wizycie notatki i zalecenia, aktualizacja grafiku wizyt"
    recepcjonista -> systemMedyczny "Rejestracja wizyt, obsluga pacjentow"
    administrator -> systemMedyczny "Tworzenie kont personelu, zarzadzanie placowkami i danymi slownikowymi"

    systemMedyczny -> systemPlatnosci "Zleca platnosci i zwroty, odbiera status transakcji" "HTTP/REST + webhooki"
    systemMedyczny -> systemKomunikacji "Wysyla potwierdzenia i przypomnienia, synchronizuje kalendarz" "API"
  }

  views {
    systemContext systemMedyczny "L1_SystemContext" {
      include *
      autolayout lr
    }

    styles {
      element "Person" {
        background #0B7285
        color #FFFFFF
        shape Person
      }
      element "Software System" {
        background #1C7ED6
        color #FFFFFF
      }
    }
  }
}