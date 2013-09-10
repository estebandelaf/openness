package Test;
use Getopt::Long;

sub main {
	# recuperar opciones
	my $host = '';
	my $port = 0;
	my $service = '';
	my $test = 'default';
	my $only_root = 0;
	GetOptions (
		'host=s' => \$host,
		'port=i' => \$port,
		'service=s' => \$service,
		'test=s' => \$test,
		'only-root' => \$only_root
	);
	# se tiene que haber especificado al menos el servicio
	if ($service eq '') {
		main::options_error ('Debe especificar el servicio que se probará.');
	}
	# dependiendo del servicio es lo que se hará
	my $test_service = main::ROOT_DIR.'/lib/modules/Test/'.ucfirst($service).'/'.ucfirst($test).'.pm';
	# incluir test si existe
	if (-e $test_service ) {
		require $test_service;
		# verificar que exista la función main dentro de la prueba
		my $main = 'Test::'.ucfirst($service).'::'.ucfirst($test).'::main';
		if (main::function_exists($main)) {
			my @hosts;
			# si no se especificó el host y puerto se asume que hay que
			# probar todo los equipos de los reportes que tengan el servicio
			if ($host eq '' or $port == 0) {
				@hosts = Services::getHosts($service);
			}
			# sino solo se prueba en el equipo y puerto indicado
			else {
				@hosts = { host => $host, port => $port};
			}
			# ejecutar test
			print '# Ejecutando test "',$test,'" para el servicio "'.$service.'"',"\n\n";
			&$main(\@hosts, { only_root => $only_root });
		} else {
			print 'La prueba "'.$test.'" para el servicio "'.$service.'" no ha podido ser inicializada.';
		}
	} else {
		main::options_error ('La prueba "'.$test.'" para el servicio "'.$service.'" no existe.');
	}
}

1;
