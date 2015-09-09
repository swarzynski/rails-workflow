# rails-workflow

Uwaga: kod jest na etapie "u mnie działa" - nie wystraszyć się :) pre-alpha :)

Wszelka pomoc mile widziana.

rails_dev_server:
maszyna wirtualna obsługiwana przez vagranta - Ubuntu 14.04 (64-bit) + provisioning (Ruby 2.0, PostgreSQL, Rails)


rails_production_server:
serwer produkcyjny + staging - podobnie jak wyżej, ale bez wykorzystania vagranta (tryb headless virtualbox-a)

Notatka:
* nie udało mi się zmusić Passengera do poprawnej pracy z Ruby2.2 z Brightboxa - dlatego jest tu wersja 2.0, która działa out-of-the-box (problem do rozwiązania)

Wymagania:
* Ubuntu
* vagrant
* Twój komputer powinien mieć adres IP przydzielany przez DHCP (wirtualka produkcyjnego dostaje osobne IP)
* masz skonfigurowane klucze SSH (używa ssh-copy-id by wpuszczać Cię na serwery bez pytania o hasło)

Użycie:
rails_dev_server:
- w katalogu rails_dev_server/ uruchamiasz "vagrant up" i czekasz
- potem polecenie "vagrant ssh" i dostajesz się do konsoli
- by wyłączyć maszynę "vagrant halt"

rails_production_server:
w katalogu rails_production_server/ uruchamiasz "./make_full_server.sh" i czekasz
potem "./server.sh start"
potem "./server.sh ip" by sprawdzić jakie IP dostał

Instrukcja jak skonfigurować Capistrano
TODO
