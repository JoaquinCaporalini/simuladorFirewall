# simuladorFirewall
Levantar un archivo de configuración de firewall y simular intentar pasar paquetes por el

**Materia**: Análisis de lenguajes de programación.

**Alumno**: Caporalini, Joaquin.

**Docente**: Mazino, Cecilia.

___Agosto 2023, FCEIA, UNR, Rosario.___

## Lenguaje

inspirado en el [iptables](https://linux.die.net/man/8/iptables) estelenguaje de dominio específico está orientado a simular parte de su comportamiento, permitiendo a través de esta implementación "simular" un pequeño firewall enviado paquetes y viendo si estos atraviesan o son descartados.

## Partes del lenguaje:

### Interfaces 

Para recibir y enviar paquetes en la red primero tenemos que crear nuestro **host**, el cual consiste en una serie de interfaces de red dadas por sus nombres, ip asignada y mac, en el siguiente ejemplo podemos ver una configuración:

```
INIT_HOST
interfaz "eth0:" ip 192.168.135.4 mac "00:15:17:a2:07:56";
interfaz "eth1" ip 200.3.123.115 mac "00:15:17:a2:07:56";
interfaz "eth2" ip 192.168.1.100 mac "00:0c:29:f7:5c:ae";
interfaz "wifi0" ip 172.16.0.7 mac "10:0c:ca:fe:5c:21";
END_HOST
```
De esta forma tenemos nuestro host creado para enviar y recibir paquetes de red.

### Paquetes

En general existen varios tipos de protocolos y tipos de coneccion, aunque los más comunes son **TCP**, **UDP** e  **ICMP** cada uno de los cuales tiene su propia información.
 
En el caso de los paquetes **TCP** tenemos el siguiente paquete de ejemplo dentro de nuestro simulador:

```
TCP state ESTABLISHED src 192.168.135.4 src-mac  "00:15:17:a2:07:56" dst 192.168.100.7 spot 8080 dport 5 ttl 55 Use 1 interfaz "eth0"  ;
```
Este paquete es una conexión ya establecida desde 192.168.135.4  hacia 192.168.100.7 con el puesto de salida 8080 y llegada 5 con un tiempo de vida de 5 milisegundos y es capturado por la interfaz eth0. Los paquetes llevan en el segundo campo información interna del protocolo que es el estado de la comunicación. Los posibles valores son: NONE, ESTABLISHED, SYN_SENT, SYN_RECV, FIN_WAIT, TIME_WAIT, CLOSE, CLOSE_WAIT, LAST_ACK, LISTEN.

Por otro lado tenemos los paquetes **ICMP** encargados de la administración y configuración de la red. 

```
ICMP src 192.168.135.4 src-mac  "00:15:17:a2:07:56" dst 192.168.100.7 stype 128 scode 1 sid 2 dtype 129 dcode 1 did 2 Use 0 interfaz "eth0";
```
En este ejemplo vemos una solicitud de ___ping___ hecha por 192.168.135.4 a 192.168.100.7.

El último de los paquetes usuales dentro de la red son los paquetes **UDP** los cuales tienen la siguiente forma dentro del simulador:

```
UDP src 192.168.135.4 src-mac  "00:15:17:a2:07:56" dst 192.168.100.7 spot 8080 dport 5 Use 1 interfaz “wifi0”;
```
En estructura es parecido a los paquetes TCP solo que al no requerir mantener la conexión no debe almacenar esa información.

Una posible definición de paquetes sera:

```
INIT_PACKAGES
TCP state ESTABLISHED src 192.168.135.4 src-mac  "00:15:17:a2:07:56" dst 192.168.100.7 spot 8080 dport 5 ttl 55 Use 1 interfaz "eth0"  ;

ICMP src 192.168.135.4 src-mac  "00:15:17:a2:07:56" dst 192.168.100.7 stype 128 scode 1 sid 2 dtype 129 dcode 1 did 2 Use 0 interfaz "eth0";

UDP src 192.168.135.4 src-mac  "00:15:17:a2:07:56" dst 192.168.100.7 spot 8080 dport 5 Use 1 interfaz “wifi0”;
END_PACKAGES
```

### conexiones

Una conexión dentro del protocolo de TCP/IP está dada por una ip y puesto de origen más una ip y puerto de destino. A estas conexiones se les asigna uno de los siguientes estados: NEW, INVALID, ESTABLISHED, RELATED. Es importante conocer cual es el estado de la conexión con el host para poder filtrar el tráfico. Dentro del simulador se vería de la siguiente forma:

```
INIT_CONNECTIONS
ip 200.3.123.115 puerto 8080 ip 192.168.100.11 puerto 5 state NEW
ip 192.168.100.7 puerto 80 ip 200.3.123.115 puerto 5 state ESTABLISHED;
END_CONNECTIONS
```

### Reglas

Las reglas son la parte más jugosa a la hora de construir un filtro de paquetes. Para crear una regla tenemos que tener en cuenta su estructura:

* Tabla: Sobre que tabla se quiere agregar la nueva regla
* Comando: En que puesto dentro de una cadena especifica dentro de una tabla se agregara la nueva regla
* La condición: que propiedad queremos que cumpla un paquete para aplicarle la regla
* La Regla o predicado: Que vamos a hacer con el paquete.

existen unas cuantas combinaciones posibles de estas, a continuación se muestran algunas   

```
-t mangle -P -j ACCEPT;
-t nat -P -j RETURN;
-t filter -P -j DROP;
-t filter -A OUTPUT -s 192.168.100.7 -j ACCEPT;
-t nat -A OUTPUT -p tcp -j ACCEPT;
-t nat -A POSTROUTING -i "ens33" -j ACCEPT;
-t mangle -I FORDWARD 0 -m –state NEW -j REGECT;
```

## Modo de uso

Para poder utilizarlo se debería ejecutar, en caso de no tener descargado el proyecto:

```
git clone https://github.com/JoaquinCaporalini/simuladorFirewall
cd simuladorFirewall/simuladorFirewall/
``` 

una vez descargado se debe compilar:

```
stack setup
stack build
```
Y por último para ejecutarlo (sin instalar)

```
stack exec simuladorFirewall-exe FILE
```






```mermaid
graph TD;
    LLegada de un paquete por la interfaz--> Mangle Prerouting;
    Mangle Prerouting --> Nat Prerouting;
    Nat Prerouting --> Mangle Input;
    Mangle Input --> Filter Input;
    Filter Input --> Pasa el filtro y llega al host;
    C-->D;
```