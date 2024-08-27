# Desarrollo Parcial 1

Realizado por: 
- Kenny Alejandro Diaz Caicedo - 2195114
- Andres Felipe Muñoz Silva - 2201601

## Configuración de Servidor DNS Maestro/Esclavo y Autenticación PAM en Apache

### Primera Parte: Configuracion de DNS Maestro y Esclavo

En la maquina que escojamos como Maestro iniciamos instalando Bind9 y algunas dependencias

### 1. Instalar Bind9
  ``` sudo apt-get install bind9 bind9utils ```


Una vez instalados, procedemos a entrar en el directorio
   ``` /etc/bind ```

En este directorio se hace una copia del archivo db.0 al nombre del DNS de la empresa 
donde en este caso es *db.diazmunoz2024* 

### 2. Y se cambia lo siguiente:
```
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     diazmunoz2024.com. root.diazmunoz2024.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns.diazmunoz2024.com.
ns      IN      A       192.168.50.3
esclavo IN      A       192.168.50.2
visitante       IN      CNAME esclavo
maestro IN      CNAME   ns
server IN       CNAME   ns
www     IN      CNAME   ns
mail    IN      CNAME   ns
```

Una vez creado y modificado se continua modificando en el mismo directorio el archivo llamado *named.conf.local* 

### 3. Se hace lo siguiente:
```
//
// Do any local configuration here
//

// Consider adding the 1918 zones here, if they are not used in your
// organization
//include "/etc/bind/zones.rfc1918";
/*Zona hacia adelante*/
zone "diazmunoz2024.com" {
type master;
file "/etc/bind/db.diazmunoz2024.com";
allow-transfer { 192.168.50.2; };
};
/*Zona inversa*/
zone "50.168.192.in-addr.arpa" {
type master;
file "/etc/bind/db.192";
};
```
Esto es para poder configurar el **_DNS_** Maestro y ya con esto terminado en el maestro 
se continua en la otra maquina para configurar el Esclavo

## En el esclavo

Una vez estando en el esclavo se prosigue a instalar lo necesario para volverlo esclavo,
en este caso es necesario instalar **_BIND9_** para configurar correctamente el DNS esclavo.

## 4. Instalar Bind9 en el esclavo

```sudo apt-get install bind9```


Una vez se termine de instalar Bind9 y sus dependencias, procedemos a entrar al siguiente directorio:
```/etc/bind```

En este directorio no dirigimos al archivo llamado *named.conf.local* 

### 5. Se modifica lo siguiente:

```
//
// Do any local configuration here
//

// Consider adding the 1918 zones here, if they are not used in your
// organization
//include "/etc/bind/zones.rfc1918";

zone "diazmunoz2024.com" {
type slave;
masters {192.168.50.3; };
file "/var/cache/bind/db.diazmunoz2024.com";
};

```

De esta forma hacemos que la otra maquina se vuelva esclavo.
