# Desarrollo Parcial 1

Realizado por: 
- Kenny Alejandro Diaz Caicedo - 2195114
- Andres Felipe Muñoz Silva - 2201601

## Configuración de Servidor DNS Maestro/Esclavo y Autenticación PAM en Apache

### Primera Parte: Configuracion de DNS Maestro y Esclavo

En la maquina que escojamos como Maestro iniciamos instalando Bind9 y algunas dependencias

### 1. Instalar Bind9
  ```
  sudo apt-get install bind9 bind9utils
 ```


Una vez instalados, procedemos a entrar en el directorio
   ```
 /etc/bind 
   ```

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

```
sudo apt-get install bind9
```


Una vez se termine de instalar Bind9 y sus dependencias, procedemos a entrar al siguiente directorio:
```
/etc/bind
```

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


## Configuracion de PAM y Apache

### Segunda Parte: Configuración de Autenticación PAM en Servidor Apache

Una vez terminada la configuracion de los servidores DNS en el maestro y esclavo,
se continua en la maquina Meaestro para configurar apache y la autenticacion PAM

## En la maquina Maestro

Estando en la maquina maestro procedemos a instalar Apache2

### 1. Instalar apache2

```
sudo apt-get install apache2
```

Ya intalado apache2 se nos crea un directorio llamado _apache2_, ubicado en:
```
/etc/apache2
```
Y se configura el archivo **_apache2.conf_** agregando el Directorio:

```
<Directory "/var/www/html/archivos_privados">
    AuthType Basic
    AuthName "Directorio Protegido"
    Require valid-user
</Directory>

```

Ya configurado entramos en el directorio _sites-avaible_ y configuramos el archivo **_000-default.conf_**

```
sudo vim /etc/apache2/sites-available/000-default.conf
```

Aquí agregamos la siguiente configuracion:

```
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
<Directory "/var/www/html/archivos_privados">
AuthType Basic
AuthName "private area"
AuthBasicProvider PAM
AuthPAMService apache
Require valid-user
</Directory>
</VirtualHost>

```

Una vez hecha esta configuracion nos dirigimos a la siguiente ruta:

```
/var/www/html
```
En esta ruta creamos el directorio ```/archivos_privados``` el cual sera nuestro directorio con index html protegido,
el cual fue configurado en el archivo **_000-default.conf_** con el siguiente codigo:

```
<Directory "/var/www/html/archivos_privados">
AuthType Basic
AuthName "private area"
AuthBasicProvider PAM
AuthPAMService apache
Require valid-user
</Directory>

```

Ya configurado en las paginas se puede proceder a descargar el PAM con la siguiente linea de comando:

```
apt-get install libapache2-mod-authnz-pam
```

Una vez descargado, procedemos a activar el modulo de PAM:

```
a2enmod authnz_pam
```
Al terminar de activar el modulo PAM continuamos con crear el archivo de la lista de excluidos en la carpeta pam.d

```
sudo vim /etc/pam.d/usuarios_denegados
```

Y en ese archvio ponemos los nombres que se quieren excluir 

```
Kenny
andres
daniel
 ```
 
Despues de la lista creamos un archivo  de configuración pam  llamado "apache" en la misma carpeta pam 

```
sudo vim /etc/pam.d/apache
```

Y en el archivo ponemos la siguiente configuracion

```
(ingresa la lista)
auth required pam_unix.so
account required pam_unix.so

```
Autenticamos el acceso al servicio apache mediante las cuentas de ubuntu

```
groupadd shadow
usermod -a -G shadow www-data
chown root:shadow /etc/shadow
chmod g+r /etc/shadow'''
```
Usamos el super usuario para agregar usuarios con el commando add user 

```sudo -i``` Y luego ```adduser nombre_usuario```


reiniciamos el apache para aplicar cambios


```
sudo systemctl restart apache2
```

