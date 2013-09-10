#
# net.pl
# Copyright (C) 2012 Esteban De La Fuente Rubio (esteban[at]delaf.cl)
#
# Librería de rutinas para la red.
#
# requiere: dig
#

# Rutina para obtener la dirección IP a partir de un nombre
sub nslookup {
	my $host = shift;
	my $ip = '';
	if (ip_valid($host)) {
		$ip = $host;
	} else {
		$ip = `dig +short $host | tail -1`;
		chomp $ip;
	}
	return $ip;
}

# Rutina para validar una dirección IP (formato: WWW.XXX.YYY.ZZZ)
sub ip_valid {
	my $octeto = '(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])';
	return ($_[0] =~ m/^$octeto\.$octeto\.$octeto\.$octeto$/);
}

# Rutina para validar una red IP (formato: WWW.XXX.YYY.ZZZ/AA)
sub net_valid {
	my $octeto = '(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])';
	my $mask = '(\d|[1-2]\d|3[0-2])';
	return ($_[0] =~ m/^$octeto\.$octeto\.$octeto\.$octeto\/$mask$/);
}

# Rutina que verifica si la ip es local
sub ip_local {
	my $octeto = '(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])';
	return 192 if $_[0] =~ m/^192\.168\.$octeto\.$octeto$/;
	return 172 if $_[0] =~ m/^172\.(1[6-9]|2\d|3[0-1])\.$octeto\.$octeto$/;
	return 10 if $_[0] =~ m/^10\.$octeto\.$octeto\.$octeto$/;
	return 0;
}

# Rutina que verifica si la ip es de loopback
sub ip_loopback {
	my $octeto = '(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])';
	return ($_[0] =~ m/^127\.$octeto\.$octeto\.$octeto$/);
}

# Rutina para enviar un correo electrónico sin usar autenticación
# $to puede ser user1@example.com o user1@example.com;user2@example.com
use Net::SMTP;
sub email_send {
	# recibir parámetros de la rutina
	my $host = shift;
	my $port = shift;
	my $from = shift;
	my $to = shift;
	my $subject = shift;
	my $data = shift;
	my $debug = shift;
	# generar mensaje a enviar
	my $msg = "MIME-Version: 1.0\n"
             ."From: $from\n"
             ."To: $to\n"
             ."Date: ".date_r()."\n"
             ."Subject: $subject\n\n"
             .$data;
	# conectar al servidor y enviar correo
	my $smtp = Net::SMTP->new($host, Port=>$port, Hello=>'OpenNESS', Timeout=>30, Debug=>$debug) or return 1;
	$smtp->mail($from) or return 1;
	$smtp->to(split(';', $to)) or return 1;
	$smtp->data($msg) or return 1;
	$smtp->quit;
	return 0;
}

1;
