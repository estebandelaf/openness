package Help;

sub main {
	print qq{Modo de uso: $0 {módulo} [opciones]

Módulos:

  scan      Realiza un escaneo de equipos y puertos. Si se ejecutó la
            aplicación como root se hará un escaneo con mayores
            privilegios. Adicionalmente se puede pasar un archivo XML
            de nmap para ser procesado.

  search    Busca en los reportes generados.

  test      Realizar alguna prueba sobre los equipos. Si no se indica
            un equipo se hará la prueba sobre todos los que estén
            en registro y posean el servicio para el cual el test fue
            ideado.

  email     Envío de correo electrónico de forma "anónima".

  help      Muestra esta ayuda.


Opciones del módulo "scan":
  --host {host}       Equipo que se desea escanear.
  --net {net/mask}    Red y máscara que se desea escanear.
  --all-ports         Escanear todos los puertos.
  --port {port}       Escanea solo un puerto.
  --host-timeout {t}  Abandonar el objetivo después de "t" minutos. Por
                      defecto 30 minutos, si es 0 no se abandonará.
  --version-all       Hacer el máximo esfuerzo para determinar las
                      versiones de las aplicaciones, ocupa más tiempo.
  --file {file}       Archivo XML con la salida de nmap para procesar.
  --all-files         Reprocesar todos los archivos XML de nmap.
  --up                Enviar los reportes generados a una base de datos
                      remota (puede ser la oficial u otra).

Opciones del módulo "search":
  --ip {ip}           Busca el análisis de puertos para la IP indicada.
  --port {port}       Busca los equipos con el puerto indicado abierto.
  --service {service} Busca los equipos que corran el servicio indicado.
  --all {expr}        Busca la expresión en los reportes.

Opciones del módulo "test":
  --host {host}       Equipo en el cual hacer la prueba (se debe indicar
                      el puerto si se indica el equipo).
  --port {port}       Puerto del servicio que se probará.
  --service {service} Servicio al que se le realizará el test. Los
                      disponibles por defecto, junto a la prueba que se
                      hará, son:
                        smtp   Verificar si se permite enviar correos de
                               forma anónima (Relay activado, sin
                               autenticación).
                        mysql  Ataque de diccionario.
                        rdp    Se probará el inicio de sesión remoto con
                               la cuenta "Administrador" e "Invitado".
  --test {test}       Prueba a ejecutar, por defecto "default".
  --only-root         Se utilizará solo el usuario root para el test que
                      se realice (válido solo en pruebas que se usen
                      usuarios, excepto el test "rdp").

Opciones del módulo "email":
  --server {server}   Servidor SMTP sin autenticación y relay activado.
  --port {port}       Puerto donde está escuchando el servicio SMTP.
  --from {from}       Remitente del correo, si no es especificado se
                      generará un nombre aleatorio por cada repetición
                      realizada.
  --to {to}           Destinatario del correo.
  --subject {subject} Asunto del correo.
  --data {data}       Mensaje o cuerpo del correo.
  --repeat {times}    Cantidad de veces que el mensaje será enviado.
  --delay {t}         Segundos de pausa entre cada envío, solo tiene
                      sentido si se especificó --repeat.
  --debug             Activa el debug para el envío del correo, útil
                      para ver la traza del envío.


Ejemplos:
  scan:
    $0 scan --net 192.168.1.0/24 --version-all
    $0 scan --net 172.16.0.0/16 --port 25 --host-timeout 5
    $0 scan --host example.com --all-ports --version-all --up
    $0 scan --file nmap.xml --up
    $0 scan --all-files --up
  search:
    $0 search --port 25
    $0 search --service ssh
    $0 search --all "terminal service"
  test:
    $0 test --service smtp
    $0 test --service mysql --only-root --host A.B.C.D --port 3306
    $0 test --service rdp
  email:
    $0 email --to user\@domain.com --subject Saludo --data "Hola mundo"
    $0 email --server A.B.C.D --from admin\@example.com \
      --to usuario\@example.com --subject Urgente --data "Esta baneado"
    $0 email --to "user1\@domain.com;user2\@domain.com" \
      --subject Aviso --data "Esto es un aviso" --repeat 10
};
}

1;
