workspace "C4 L2 - System Medyczny" "Container diagram (C4-compliant, event-driven microservices)" {
  !identifiers hierarchical

  model {
    pacjent = person "Pacjent" "Uzytkownik portalu pacjenta."
    lekarz = person "Lekarz" "Realizuje i finalizuje wizyty."
    recepcjonista = person "Recepcjonista" "Rejestruje i anuluje wizyty dla pacjentow."
    administrator = person "Administrator" "Zarzadza kontami, rolami i placowkami."

    payu = softwareSystem "PayU" "Zewnetrzna bramka platnosci (platnosci, zwroty, webhooki IPN)."
    communicationApis = softwareSystem "Gmail API / Google Calendar API" "Wysylka maili i synchronizacja kalendarzy."

    systemMedyczny = softwareSystem "System Medyczny" "Platforma obslugi wizyt i procesow administracyjnych." {
      frontendPortal = container "Frontend Portal (WWW)" "UI dla pacjenta oraz panel dla personelu." "Web Application"

      apiGateway = container "API Gateway / Backend API" "Jeden punkt wejscia, routing, security, walidacja wejscia." "API Gateway"

      authIdentityService = container "Auth & Identity Service" "Logowanie, uzytkownicy, role (pacjent/lekarz/recepcjonista/admin)." "Service"
      appointmentService = container "Appointment Service" "Tworzenie/anulowanie wizyt, reguly biznesowe, status wizyty." "Service"
      scheduleService = container "Schedule Service" "Dostepnosc terminow, blokada slotu na czas platnosci, przypisanie do grafiku lekarza." "Service"
      paymentService = container "Payment Service (PayU Adapter)" "Inicjacja platnosci, odbior webhookow/statusow, timeouty, zwroty." "Service"
      notificationService = container "Notification Service" "Potwierdzenia i przypomnienia, sciezki manualne." "Service"
      facilityStaffService = container "Facility & Staff Service" "Rejestracja placowek, zakladanie kont recepcjonistow i lekarzy." "Service"
      medicalRecordService = container "Medical Record / Visit Finalization Service" "Zakonczenie wizyty, historia wizyt, SLA." "Service"
      auditLoggingService = container "Audit/Logging Service" "Slad zmian statusow wizyt i platnosci, logi operacyjne." "Service"

      rabbitmq = container "Message Broker (RabbitMQ)" "Asynchroniczne eventy domenowe (appointment.created, appointment.canceled, payment.success, payment.failed)." "RabbitMQ" {
        tags "Queue"
      }

      dbIdentity = container "Identity DB" "Dane tozsamosci i uprawnien." "PostgreSQL" {
        tags "Database"
      }
      dbAppointments = container "Appointments DB" "Wizyty i statusy wizyt." "PostgreSQL" {
        tags "Database"
      }
      dbSchedule = container "Schedule DB" "Kalendarze, sloty i blokady terminow." "PostgreSQL" {
        tags "Database"
      }
      dbPayments = container "Payments DB" "Transakcje, webhooki, zwroty i timeouty." "PostgreSQL" {
        tags "Database"
      }
      dbNotifications = container "Notifications DB" "Statusy i przypomnienia o wizytach." "PostgreSQL" {
        tags "Database"
      }
      dbFacilityStaff = container "Facility & Staff DB" "Placowki i konta personelu." "PostgreSQL" {
        tags "Database"
      }
      dbMedicalRecords = container "Medical Records DB" "Historia wizyt, notatki lekarskie, SLA." "PostgreSQL" {
        tags "Database"
      }
      dbAudit = container "Audit DB" "Niezmienialny slad audytowy i logi operacyjne." "PostgreSQL" {
        tags "Database"
      }
    }

    pacjent -> systemMedyczny.frontendPortal "Korzysta z portalu pacjenta" "HTTP"
    lekarz -> systemMedyczny.frontendPortal "Korzysta z panelu personelu" "HTTP"
    recepcjonista -> systemMedyczny.frontendPortal "Korzysta z panelu recepcji" "HTTP"
    administrator -> systemMedyczny.frontendPortal "Korzysta z panelu administracyjnego" "HTTP"

    systemMedyczny.frontendPortal -> systemMedyczny.apiGateway "Wywolania backendu" "HTTP"

    systemMedyczny.apiGateway -> systemMedyczny.authIdentityService "Autoryzacja i tozsamosc" "HTTP"
    systemMedyczny.apiGateway -> systemMedyczny.appointmentService "Operacje na wizytach" "HTTP"
    systemMedyczny.apiGateway -> systemMedyczny.scheduleService "Wyszukiwanie i podglad terminow" "HTTP"
    systemMedyczny.apiGateway -> systemMedyczny.paymentService "Inicjacja platnosci i zwrotow" "HTTP"
    systemMedyczny.apiGateway -> systemMedyczny.notificationService "Manualne i awaryjne notyfikacje" "HTTP"
    systemMedyczny.apiGateway -> systemMedyczny.facilityStaffService "Placowki i personel" "HTTP"
    systemMedyczny.apiGateway -> systemMedyczny.medicalRecordService "Finalizacja wizyt i historia" "HTTP"
    systemMedyczny.apiGateway -> systemMedyczny.auditLoggingService "Logi API i zdarzen krytycznych" "HTTP"

    systemMedyczny.appointmentService -> systemMedyczny.scheduleService "Walidacja dostepnosci i blokada slotu" "HTTP"
    systemMedyczny.appointmentService -> systemMedyczny.paymentService "Inicjacja procesu platnosci i zwrotow" "HTTP"

    systemMedyczny.appointmentService -> systemMedyczny.rabbitmq "Publikuje appointment.created i appointment.canceled" "AMQP"
    systemMedyczny.paymentService -> systemMedyczny.rabbitmq "Publikuje payment.success i payment.failed" "AMQP"
    systemMedyczny.medicalRecordService -> systemMedyczny.rabbitmq "Publikuje appointment.finished" "AMQP"

    systemMedyczny.rabbitmq -> systemMedyczny.appointmentService "Dostarcza zdarzenia statusow platnosci" "AMQP"
    systemMedyczny.rabbitmq -> systemMedyczny.scheduleService "Dostarcza zdarzenia zmian rezerwacji" "AMQP"
    systemMedyczny.rabbitmq -> systemMedyczny.notificationService "Dostarcza zdarzenia do notyfikacji" "AMQP"
    systemMedyczny.rabbitmq -> systemMedyczny.medicalRecordService "Dostarcza zdarzenia do historii i metryk" "AMQP"
    systemMedyczny.rabbitmq -> systemMedyczny.auditLoggingService "Dostarcza centralny strumien audytowy" "AMQP"

    systemMedyczny.paymentService -> payu "OrderCreate, zwroty, status transakcji" "HTTP"
    payu -> systemMedyczny.paymentService "Webhooki IPN (status platnosci i zwrotu)" "HTTP"

    systemMedyczny.notificationService -> communicationApis "Wysylka email i synchronizacja kalendarza" "HTTP"

    systemMedyczny.authIdentityService -> systemMedyczny.dbIdentity "odczyt" "TCP/Postgres"
    systemMedyczny.dbIdentity -> systemMedyczny.authIdentityService "zapis" "TCP/Postgres"

    systemMedyczny.appointmentService -> systemMedyczny.dbAppointments "odczyt" "TCP/Postgres"
    systemMedyczny.dbAppointments -> systemMedyczny.appointmentService "zapis" "TCP/Postgres"

    systemMedyczny.scheduleService -> systemMedyczny.dbSchedule "odczyt" "TCP/Postgres"
    systemMedyczny.dbSchedule -> systemMedyczny.scheduleService "zapis" "TCP/Postgres"

    systemMedyczny.paymentService -> systemMedyczny.dbPayments "odczyt" "TCP/Postgres"
    systemMedyczny.dbPayments -> systemMedyczny.paymentService "zapis" "TCP/Postgres"

    systemMedyczny.notificationService -> systemMedyczny.dbNotifications "odczyt" "TCP/Postgres"
    systemMedyczny.dbNotifications -> systemMedyczny.notificationService "zapis" "TCP/Postgres"

    systemMedyczny.facilityStaffService -> systemMedyczny.dbFacilityStaff "odczyt" "TCP/Postgres"
    systemMedyczny.dbFacilityStaff -> systemMedyczny.facilityStaffService "zapis" "TCP/Postgres"

    systemMedyczny.medicalRecordService -> systemMedyczny.dbMedicalRecords "odczyt" "TCP/Postgres"
    systemMedyczny.dbMedicalRecords -> systemMedyczny.medicalRecordService "zapis" "TCP/Postgres"

    systemMedyczny.auditLoggingService -> systemMedyczny.dbAudit "odczyt" "TCP/Postgres"
    systemMedyczny.dbAudit -> systemMedyczny.auditLoggingService "zapis" "TCP/Postgres"
  }

  views {
    container systemMedyczny "L2_Container" {
      include pacjent
      include lekarz
      include recepcjonista
      include administrator
      include payu
      include communicationApis

      include systemMedyczny.frontendPortal
      include systemMedyczny.apiGateway
      include systemMedyczny.authIdentityService
      include systemMedyczny.appointmentService
      include systemMedyczny.scheduleService
      include systemMedyczny.paymentService
      include systemMedyczny.notificationService
      include systemMedyczny.facilityStaffService
      include systemMedyczny.medicalRecordService
      include systemMedyczny.auditLoggingService
      include systemMedyczny.rabbitmq

      include systemMedyczny.dbIdentity
      include systemMedyczny.dbAppointments
      include systemMedyczny.dbSchedule
      include systemMedyczny.dbPayments
      include systemMedyczny.dbNotifications
      include systemMedyczny.dbFacilityStaff
      include systemMedyczny.dbMedicalRecords
      include systemMedyczny.dbAudit

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
      element "Container" {
        background #1971C2
        color #FFFFFF
      }
      element "Database" {
        background #2B8A3E
        color #FFFFFF
        shape Cylinder
      }
      element "Queue" {
        background #E67700
        color #FFFFFF
      }
    }
  }
}