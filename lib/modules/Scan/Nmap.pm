package Scan::Nmap;
use XML::Simple;
use Scan::Host;

# Constructor
sub new {
	my $class = shift;
	my $self = {
		data,
		all_ports,
		port,
		host_timeout,
		version_all
	};
	bless $self, $class;
	return $self;
}

sub do {
	my ( $self, $target ) = @_;
	# si como "objetivo" se paso un archivo se parsea
	if (-e $target) {
		$self->{XMLFile} = $target;
	}
	# Escanear "objetivo" si es un equipo o una red
	else {
		my $args = $Conf::conf->scan_args;
		$args .= ' -p1-65535' if $self->{all_ports};
		$args .= ' --host-timeout '.$self->{host_timeout}.'m' if $self->{host_timeout} > 0;
		$args .= ' --version-all' if $self->{version_all};
		$args .= ' -PU -PE -PP -PM' if ($ENV{USER} eq 'root');
		# definir archivo donde se guardará la salida de nmap (en XML)
		my $file = $target.'.xml';
		$file =~ s/\//_/;
		# acciones si se desea escanear solo un puerto
		if (defined $self->{port}) {
			$args .= ' -p '.$self->{port} if defined $self->{port};
			$file = $self->{port}.'/'.$file;
			mkdir main::NMAP_DIR.'/'.$self->{port};
		}
		$self->{XMLFile} = main::NMAP_DIR.'/'.$file;
		$args .= ' -oX '.$self->{XMLFile};
		# ejecutar escaneo y recuperar xml generado
		system ('nmap '.$args.' '.$target.' > /dev/null 2>&1');
		
	}
	# Leer contenido del XML
	my $result = `cat $self->{XMLFile}`;
	# Parsear XML generado por nmap
	my $xml = new XML::Simple;
	$self->{data} = $xml->XMLin($result);
	$hosts_data = $self->{data}->{host};
	my @hosts;
	# si la variable esta definida es porque se encontro al menos un host
	if (defined $hosts_data) {
		# si no es un arreglo de hashes se crea
		$hosts_data = [$hosts_data] if ref($hosts_data) ne 'ARRAY';
		# se crea cada uno de los objetos y se agrega al arreglo
		foreach my $host_data (@$hosts_data) {
			push (@hosts, new Scan::Host ($host_data));
		}
	}
	return @hosts;
}

sub getTarget {
	my ( $self ) = @_;
	my @nmap_args = split (' ', $self->{data}->{args});
	return $nmap_args[$#nmap_args];
}

sub getArgs {
	my ( $self ) = @_;
	return $self->{data}->{args};
}

sub getXMLFile {
	my ( $self ) = @_;
	return $self->{XMLFile};
}

# hacer que eval, evalue el archivo como TRUE
1;
