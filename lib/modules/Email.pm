package Email;
use Getopt::Long;

# Rutina para enviar un correo de forma anónima
sub main {
	# recuperar opciones
	my $server = $Conf::conf->email_server;
	my $port = $Conf::conf->email_port;
	my $from = $Conf::conf->email_from;
	my $to = '';
	my $subject = '';
	my $data = '';
	my $repeat = 1;
	my $delay = 0;
	my $debug = 0;
	GetOptions (
		'server=s' => \$server,
		'port=i' => \$port,
		'from=s' => \$from,
		'to=s' => \$to,
		'subject=s' => \$subject,
		'data=s' => \$data,
		'repeat=i' => \$repeat,
		'delay=i' => \$delay,
		'debug' => \$debug
	);
	# verificar los parámetros requeridos
	if($server eq '' or $port==0 or $to eq '' or $subject eq '' or $data eq '' ) {
		main::options_error ('Para enviar un correo se deben especificar los campos: server, to, subject y data.');
	}
	# enviar correo "n" veces
	for (my $count=1; $count <= $repeat; $count++) {
		# si "from" no fue entregado, se genera un remitente al azar
		my $from_real;
		if ($from eq '') {
			$from_real = main::str_random(24).'@gmail.com';
		} else {
			$from_real = $from;
		}
		# enviar correo
		my $status = main::email_send ($server, $port, $from_real, $to, $subject, $data, $debug);
		# mensaje al usuario
		if(!$status) { print "[$count] ".$from_real.' envío el mensaje a través de '.$server.':'.$port,"\n"; }
		else { print "[$count] ".'No fue posible enviar el mensaje de '.$from_real,"\n"; }
		# si se especifico un delay se hace una pausa
		if ($delay > 0 and $count < $repeat) {
			sleep $delay;
		}
	}
}

1;
