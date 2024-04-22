# Internet Przedmiotów - Protokół komunikacyjny Eclipse Zenoh: zabezpieczenie komunikacji uwierzytelnianiem użytkownik hasło
## Zenoh w pigułce

<img src="img/zenoh-dragon-500x543.png" alt="zenoh-dragon" width="200"/>

**Zenoh** czyli w rozwinięciu *Zero Overhead Network Prtocol* **to protokół komunikacyjny ujednolicający dane w ruchu, dane w rest i obliczenia**. Łączy pub/sub/query z roproszoną geograficznie pamięcią masową, zapytnia i obliczenia ale zachowuje jednocześnie efektywność czasową oraz przestrznną. 

### Zenoh w IoT
Zenoh to jedyny protokół dostępny na rynku**, który umożliwia efektywną pracę i wydajność od serwerowego hardware i rozległych sieci do urządzeń takich jak mikrokontrolery i niezwykle ograniczone sieci.

Więcej informacji pod: https://zenoh.io/docs/overview/what-is-zenoh/


# Przygotowanie do zadania
## Wymagania
- klient Docker
- Python w wersji min. 3.8
- Python virtualenv

1. W dowolnie wybranej lokalizacji przygotuj folder roboczy i sklonuj do niego repozytorium.

# Zadanie 1 - komunikacja client-router-client bez zabezpieczeń
## Przygotowanie kontenera z Routerem Zenoh
1. Załaduj plik '`.tar`' z przygotowanym obrazem Routera Zenoh:
    ```bash
    docker load -i zenohrouterimage.tar
    ```
    W zależności od instalacji Docker może być wymagane wywołanie komendy poprzez `sudo`:
    ```bash
    sudo docker load -i zenohrouterimage.tar
    ```

2. Zweryfikuj czy obraz został poprawnie załadowany:
    ```bash
    docker images
    ```

    Wynik:
    ```bash
    REPOSITORY         TAG       IMAGE ID       CREATED         SIZE
    zenohrouterimage   latest    6f9ad9a54d91   2 minutes ago   42.7MB
    ```

3. Uruchom obraz:
    ```bash
    docker run -d --name zenoh_router zenohrouterimage
    ```

4. Zweryfikuj czy uruchomienie kontenera się powiodło:
    ```bash
    docker ps -a
    ```

    Wynik operacji powinien być podobny do:
    ```bash
    CONTAINER ID   IMAGE              COMMAND            CREATED          STATUS                        PORTS       NAMES
    ------------   zenohrouterimage   "/entrypoint.sh"   17 seconds ago   Exited (255) 16 seconds ago               zenoh_router
    ```
5. Wystartuj kontener (jeśli nie jest już uruchomiony):
    ```bash
    docker start zenoh_router

6. Zweryfikuj poprawność uruchomienia:
    ```bash
    docker logs zenoh_router
    ```

    Zamierzony wynik:
    ```bash
    [2024-04-17T20:00:28Z INFO  zenoh::net::runtime] Using PID: 3de15d3bc99d5bc36150c7b41f8ba171
    [2024-04-17T20:00:28Z INFO  zenoh::net::runtime::orchestrator] Zenoh can be reached at: tcp/172.17.0.2:7447
    [2024-04-17T20:00:28Z INFO  zenoh::net::runtime::orchestrator] zenohd listening scout messages on 224.0.0.224:7446
    [2024-04-17T20:00:28Z INFO  zenohd] Finished loading plugins
    ```
## Skrypty w Python
Jedną z opcji przekazywania danych metodą pub/sub jest uruchomienie dwóch skryptów w języku Python. 
Inne możliwości przewidują komunikację za pośrednictwem cmd lub skryptami w języku C dla mikrokontrolerów takich jak ESP32 lub STM32F7.
W tym zadaniu zostały przygotowane dwa podstawowe skrypty w języku Python:
- `z_pub.py` - jest producentem danych, publikuje na zdefiniownym `key expression` dane, które trafiają do routera w linii client<->router. 
- `z_sub.py` - konsument danych, subskrybuje predefiniowany key expression i czeka na publikowane dane.

1. Stwórz i uruchom środowisko `virtualenv`:
    ```bash
    python3 -m venv env/
    ```

    ```bash
    source env/bin/activate
    ```

2. Zainstaluj wymagane biblioteki:
    ```bash
    pip install -r requirments.txt
    ```

3. Uruchom skrypt `z_pub.py`:
    ```bash
    python3 z_pub.py
    ```
    Konsola powinna wyglądać tak:
    ```bash
    Opening session...
    Declaring Publisher on 'demo/example/zenoh-python-pub'...
    Putting Data ('demo/example/zenoh-python-pub': '[   0] Pub from Python!')...
    Putting Data ('demo/example/zenoh-python-pub': '[   1] Pub from Python!')...
    Putting Data ('demo/example/zenoh-python-pub': '[   2] Pub from Python!')...
    ``` 

4. Uruchom skrytp `z_sub.py`:
    ```bash
    python3 z_sub.py
    ```

    Konsola powinna wyglądać tak:
    ```bash
    Opening session...
    Declaring Subscriber on 'demo/example/**'...
    Enter 'q' to quit...
    >> [Subscriber] Received PUT ('demo/example/zenoh-python-pub': '[   0] Pub from Python!')
    >> [Subscriber] Received PUT ('demo/example/zenoh-python-pub': '[   1] Pub from Python!')
    >> [Subscriber] Received PUT ('demo/example/zenoh-python-pub': '[   2] Pub from Python!')
    >> [Subscriber] Received PUT ('demo/example/zenoh-python-pub': '[   3] Pub from Python!')
    ```
5. Obserwacje?
Komunikacja działa, przykład zrobiony lokalnie, z uwzględnieniem routera uruchomionego na publicznym hoście
oraz skrypty uruchomione z odpowiednimi parametrami wskazującymi na adres routera, umożliwiają komunikację,
pomiędzy różnymi urządzeniami poprzez sieć. Aktualnie komunikacja jest pozbawiona jakichkolwiek zabezpieczeń, więc
każdy w sieci znając adres routera moze uruchomić taki skrypt i podglądać przepływające w systemie dane.

# Zadanie 2 - komunikacja client-router-client: uwierzytelnianie użytkownik/hasło
Jest to najprostsza forma zabezpieczenia komunikacji w Zenoh. Poprzez stworzenie listy par `użytkownik:hasło`,
oraz uzwględnienie tych danych w konfiguracjach klientów oraz routera, może skutecznie zablokować odczyt danych
przez nieporządane osoby. Jak to działa?

## Przygotowanie kontenera z Routerem Zenoh Auth
1. Zatrzymuj wcześniej uruchomiony Router aby zwolnić wykorzystywane przez Zenoh porty sieciowe. 
    ```bash
    docker stop zenoh_router
    ```

2. Załaduj plik '`.tar`' z przygotowanym obrazem Routera Zenoh:
    ```bash
    docker load -i zenohrouterimage_auth.tar
    ```
3. Zweryfikuj czy obraz został poprawnie załadowany:
    ```bash
    docker images
    ```

    Wynik:
    ```bash
    REPOSITORY         TAG       IMAGE ID       CREATED         SIZE
    zenohrouterimage_auth   latest    6f9ad9a54d91   2 minutes ago   42.7MB
    ```

3. Uruchom obraz:
    ```bash
    docker run -d --name zenoh_router_auth zenohrouterimage_auth
    ```

4. Zweryfikuj uruchomienie kontenera się powiodło:
    ```bash
    docker ps -a
    ```

    Wynik operacji powinien być podobny do:
    ```bash
    CONTAINER ID   IMAGE              COMMAND            CREATED          STATUS                        PORTS       NAMES
    ------------   zenohrouterimage_auth   "/entrypoint.sh"   17 seconds ago   Exited (255) 16 seconds ago               zenoh_router_auth
    ```
5. Wystartuj kontener:
    ```bash
    docker start zenoh_router

6. Zweryfikuj poprawność uruchomienia:
    ```bash
    docker logs zenoh_router_auth
    ```

## Skrypty w Python
Tym razem uruchomimy skrypty z konfiguracją uwierzytelnienia oraz jeden skrypt pozbawiony konfiguracji, który
będzie nam symulować nieporządanego podglądacza w systemie.

1. Uruchom skrypt `z_pub.py`:
    ```bash
    python3 z_pub.py -c config_client_auth.json5
    ```
    Konsola powinna wyglądać tak:
    ```bash
    Opening session...
    Declaring Publisher on 'demo/example/zenoh-python-pub'...
    Putting Data ('demo/example/zenoh-python-pub': '[   0] Pub from Python!')...
    Putting Data ('demo/example/zenoh-python-pub': '[   1] Pub from Python!')...
    Putting Data ('demo/example/zenoh-python-pub': '[   2] Pub from Python!')...
    ``` 

2. Uruchom skrytp `z_sub.py`:
    ```bash
    python3 z_sub.py -c config_client_auth.json5
    ```

    Konsola powinna wyglądać tak:
    ```bash
    Opening session...
    Declaring Subscriber on 'demo/example/**'...
    Enter 'q' to quit...
    >> [Subscriber] Received PUT ('demo/example/zenoh-python-pub': '[   0] Pub from Python!')
    >> [Subscriber] Received PUT ('demo/example/zenoh-python-pub': '[   1] Pub from Python!')
    >> [Subscriber] Received PUT ('demo/example/zenoh-python-pub': '[   2] Pub from Python!')
    ```

    Wyniki są takie same jak w przypadku uruchomienia bez dodatkowej konfiguracji. Różnica pojawia się, gdy uruchomimy kolejny skrypt `z_sub.py` bez konfiguracji.

2. Uruchom skrypt `z_sub.py` w kolejnym terminalu:
    ```bash
    python3 z_sub.py
    ```

    Wynik:
    ```bash
    Enter 'q' to quit...
    [2024-04-17T21:01:33Z ERROR zenoh_transport::unicast::establishment::open] Received a close message (reason GENERIC) in response to an InitSyn on: tcp/172.17.0.1:53452 => tcp/172.17.0.2:7447 at /root/.cargo/registry/src/index.crates.io-6f17d22bba15001f/zenoh-transport-0.10.1-rc/src/unicast/establishment/open.rs:226.
    [2024-04-17T21:01:35Z ERROR zenoh_transport::unicast::establishment::open] Received a close message (reason GENERIC) in response to an InitSyn on: tcp/172.17.0.1:53454 => tcp/172.17.0.2:7447 at /root/.cargo/registry/src/index.crates.io-6f17d22bba15001f/zenoh-transport-0.10.1-rc/src/unicast/establishment/open.rs:226.
    [2024-04-17T21:01:39Z ERROR zenoh_transport::unicast::establishment::open] Received a close message (reason GENERIC) in response to an InitSyn on: tcp/172.17.0.1:57760 => tcp/172.17.0.2:7447 at /root/.cargo/registry/src/index.crates.io-6f17d22bba15001f/zenoh-transport-0.10.1-rc/src/unicast/establishment/open.rs:226.
    ```

    Widać przepływające komunikaty, jednak nie widać ich zawartości. Wszystko przez to że konfiguracja klienta nie zawiera potrzebnych do uwierzytelnienia danych.

# Wnioski
Zastosowanie prostego mechanizmu uwierzytelniania umożliwiło zabezpiecznie komunikacji poprzez protokół Zenoh. Bez tego zabezpieczenia, dane można swobodnie podgląć, jeśli pozna się adres routera.