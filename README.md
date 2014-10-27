OpenNESS v0.2.3
===============

OpenNESS corresponde a una herramienta en Perl muy sencilla para el escaneo de
equipos y redes TCP/IP distribuída bajo licencia GPL v3.

Visite el sitio web para más información:

- Requerimientos e instalación: <http://openness.cl/instalacion>
- Tutoriales: <http://openness.cl/tutoriales>
- Tareas futuras: <http://openness.cl/tareas-futuras>
- Base de datos con escaneos de nmap: <http://openness.cl/bd>

Módulos disponibles
-------------------

* **scan**: realiza un escaneo de equipos y puertos. Si se ejecutó la
aplicación como root se hará un escaneo con mayores privilegios. Adicionalmente
se puede pasar un archivo XML de nmap para ser procesado.

* **search**: busca en los reportes generados.

* **test**: realizar alguna prueba sobre los equipos. Si no se indica un equipo
se hará la prueba sobre todos los que estén en registro y posean el servicio
para el cual el test fue ideado.

* **email**: envío de correo electrónico de forma "anónima".

* **help**: muestra la ayuda de la aplicación.
