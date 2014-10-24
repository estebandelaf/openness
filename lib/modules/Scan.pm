package Scan;
use Getopt::Long;
use Scan::Nmap;

sub main {
	# recuperar opciones
	my $host;
	my $net;
	my $all_ports = $Conf::conf->scan_all_ports;
	my $port;
	my $host_timeout = $Conf::conf->scan_host_timeout;
	my $version_all = $Conf::conf->scan_version_all;
	my $file;
	my $all_files = 0;
	my $up = $Conf::conf->scan_up;
	GetOptions (
		'host=s' => \$host,
		'net=s' => \$net,
		'all-ports' => \$all_ports,
		'port=s' => \$port,
		'host-timeout=i' => \$host_timeout,
		'version-all' => \$version_all,
		'file=s' => \$file,
		'all-files' => \$all_files,
		'up' => \$up
	);
	# si se pide procesar todos los archivos XML denuvo, se llama
	# recursivamente a la aplicación por cada uno de los archivos
	# existentes
	if($all_files) {
		# obtener listado de archivos
		opendir (DIR, main::NMAP_DIR) or die $!;
		my @files = grep { /\.xml$/ && -f main::NMAP_DIR.'/'.$_ } readdir(DIR);
		closedir(DIR);
		use autodie qw(:all); # si system() falla, OpenNESS también fallará
		foreach my $file (@files) {
			if($up) {
				system ( $0.' scan --file '.main::NMAP_DIR.'/'.$file.' --up' );
			} else {
				system ( $0.' scan --file '.main::NMAP_DIR.'/'.$file );
			}
		}
		# una vez se terminan de procesar los archivos no hay más que
		# hacer
		exit 0;
	}
	# definir el "objetivo" a escanear
	my $target = '';
	if (defined $net) { # si se paso una red
		if (main::net_valid($net)) {
			$target = $net;
		} else {
			main::options_error ('La red "'.$net.'" no es válida.');
		}
	}
	if (defined $host) { # si se paso un host
		$target = $host;
	}
	if (defined $file and -e $file) { # si se paso un archivo
		$target = $file;
	}
	if ($target eq '') {
		main::options_error ('Debe especificar un equipo o una red a escanear.');
	}
	# realizar consulta
	if(!defined $file) {
		print '# Escaneando ',$target,'...',"\n\n";
	}
	my $scan = new Scan::Nmap();
	$scan->{all_ports} = $all_ports;
	$scan->{port} = $port;
	$scan->{host_timeout} = $host_timeout;
	$scan->{version_all} = $version_all;
	my @hosts = $scan->do($target);
	# definir archivo para guardar procesado
	my $nmap_target = $scan->getTarget();
	my $file_result = $nmap_target.'.log';
	$file_result =~ s/\//_/;
	if (defined $port) {
		$file_result = $port.'/'.$file_result;
		mkdir main::SCAN_DIR.'/'.$port;
	}
	$file_result = main::SCAN_DIR.'/'.$file_result;
	# abrir archivo
	open FILE_RESULT, '>', $file_result or die $!;
	# guardar cabecera en el archivo
	main::header ('#', *FILE_RESULT);
	# procesar hosts
	my $net_old = '';
	foreach my $host (@hosts) {
		# mostrar información de la red
		if ($net_old ne $host->{net}) {
			main::print2 (*FILE_RESULT, '#'."\n");
			main::print2 (*FILE_RESULT, '# Reporte de la red '.$host->{net}.' ('.$host->{owner}.')'."\n");
			main::print2 (*FILE_RESULT, '# Usando: '.$scan->getArgs()."\n");
			main::print2 (*FILE_RESULT, '#'."\n\n");
			$net_old = $host->{net};
		}
		# imprimir información del host
		main::print2 (*FILE_RESULT, '# Reporte del equipo '.$host->{ip});
		main::print2 (*FILE_RESULT, ' ('.$host->{name}.')') if defined $host->{name} ne '';
		main::print2 (*FILE_RESULT, ' de la red '.$host->{net}.' ('.$host->{owner}.')'."\n");
		# imprimir información de los puertos abiertos encontrados
		my @ports = $host->getOpenPorts();
		foreach my $port (@ports) {
			main::print2 (*FILE_RESULT, sprintf("%15s   %5d   %-20s", $host->{ip}, $port->{id}, $port->{service}));
			main::print2 (*FILE_RESULT, $port->{product}) if defined $port->{product};
			main::print2 (*FILE_RESULT, ' '.$port->{version}) if defined $port->{version};
			main::print2 (*FILE_RESULT, ' ('.$port->{extrainfo}.')') if defined $port->{extrainfo};
			main::print2 (*FILE_RESULT, ' in '.$port->{ostype}) if defined $port->{ostype};
			main::print2 (*FILE_RESULT, "\n");
		}
		main::print2 (*FILE_RESULT, "\n");
	}
	# cerrar archivo
	close FILE_RESULT;
	# subir archivo XML (de nmap) y LOG (de OpenNESS) al servidor
	if ($up) {
		Remote::sendXML($scan->getXMLFile());
	}
}

1;
