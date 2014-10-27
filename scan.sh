#!/bin/bash
#
# OpenNESS v0.2.3
# Copyright (C) 2014 Esteban De La Fuente Rubio (esteban[at]delaf.cl)
#
# Script para lanzar un escaneo sobre un grupo de redes.
# Los escaneos generados se enviarán al servidor
#
# Las direcciones IP para el archivo que se pasa al script se pueden obtener
# desde:
#   - http://www.nirsoft.net/countryip
#   - http://incredibill.me/htaccess-block-country-ips
#

# argumentos que se utilizarán con OpenNESS
PORTS=`cat var/database/ports/tcp | tr '\n' ','`
ARGS="--port $PORTS --host-timeout 5 --up"
# ¿usar tsocks? (default: no)
#TSOCKS="yes"

# verificar que se haya pasado un parámetro y sea un archivo
if [ ! -f "$1" ]; then
	echo "[error] Falta indicar archivo con direcciones IPs y sus máscaras"
	echo "Modo de uso: $0 <archivo con IPs y máscaras>"
	exit 1
fi

# directorio para archivos temporles
DIR="tmp/`basename $1`"

# función que genera las redes clase C de un rango a partir de una IP de origen
# y una IP de destino
function generar_redes_clase_c {
	# determinar hasta que red /24 se debe llegar
	PARTS=(`echo $2 | tr "." " "`)
	NETWORK_TO="${PARTS[0]}.${PARTS[1]}.${PARTS[2]}.0"
	# determinar desde que red /24 se debe partir, se deja en variables
	# diferentes ya que se irá sumando uno a cada parte C, B y A, hasta
	# llegar a NETWORK_TO
	PARTS=(`echo $1 | tr "." " "`)
	A=${PARTS[0]}
	B=${PARTS[1]}
	C=${PARTS[2]}
	NETWORK=""
	while [ "$NETWORK" != "$NETWORK_TO" ]; do
		# armar red
		NETWORK="$A.$B.$C.0"
		echo $NETWORK
		# aumentar C
		C=`expr $C + 1`
		if [ $C -eq 256 ]; then
			C=0
			# aumentar B
			B=`expr $B + 1`
			if [ $B -eq 256 ]; then
				B=0
				# aumentar A
				A=`expr $A + 1`
				if [ $A -eq 256 ]; then
					break
				fi
			fi
		fi
	done
}

# crear directorio donde se guardará la red que se está escaneando, esto para
# poder continuar en caso que el programa termine por alguna razón
mkdir -p $DIR

# si no existe el archivo de redes /24 crearlo
if [ ! -f "$DIR/redes" ]; then
	for NETWORK in `cat $1`; do
		HOSTMIN=`ipcalc -nb $NETWORK | grep HostMin | awk '{print $2}'`
		HOSTMAX=`ipcalc -nb $NETWORK | grep HostMax | awk '{print $2}'`
		generar_redes_clase_c $HOSTMIN $HOSTMAX >> $DIR/redes
	done
fi

# si no existe el archivo para la última red que se estaba escaneando se crea
if [ ! -f "$DIR/escaneando" ]; then
	head -1 tmp/cl/redes > $DIR/escaneando
fi

# determinar desde donde se debe continuar el escaneo
ESCANEANDO=`head -1 $DIR/escaneando`

# escanear cada una de las redes /24 a partir de la última que se escaneo
# (inclusive)
STARTED=0
for NETWORK in `cat $DIR/redes`; do
	# buscar red desde donde se debe partir el escaneo
	if [ $STARTED -eq 0 ]; then
		if [ "$NETWORK" = "$ESCANEANDO" ]; then
			STARTED=1
		else
			continue
		fi
	fi
	# escanear red
	if [ -n "$TSOCKS" -a "$TSOCKS" = "yes" ]; then
		tsocks ./openness scan $ARGS --net $NETWORK/24
	else
		./openness scan $ARGS --net $NETWORK/24
	fi
	# guardar red que se estaba escaneando
	echo $NETWORK > $DIR/escaneando
done
