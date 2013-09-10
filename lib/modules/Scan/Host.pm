package Scan::Host;

# Constructor
sub new {
	my $class = shift;
	my $self = {
		data => shift
	};
	bless $self, $class;
	$self->{ip} = $self->getAddr('ipv4');
	$self->{name} = $self->{data}->{hostnames}{hostname}{name};
	my $ipInfo = ip_info($self->{ip});
	$self->{net} = $ipInfo->{net};
	$self->{owner} = $ipInfo->{owner};
	return $self;
}

# Método para obtener una dirección (ipv4, ipv6 o mac)
sub getAddr {
	my ( $self, $type ) = @_;
	$self->{data}->{address} = [$self->{data}->{address}] if(ref($self->{data}->{address}) ne 'ARRAY');
	my $addresses = $self->{data}->{address};
	foreach my $address (@$addresses) {
		if ($address->{addrtype} eq $type) {
			return $address->{addr};
		}
	}
	return '';
}

# Método que obtiene la red y el dueño de la IP
sub ip_info {
	my $ip = shift;
	my $info = {net=>'', owner=>''};
	# obtener red y dueño para ip privada (la máscara se asume para el mayor bloque)
	$net = main::ip_local($ip);
	if ($net) {
		$info->{net} = '192.168.0.0/16' if $net == 192;
		$info->{net} = '172.16.0.0/12' if $net == 172;
		$info->{net} = '10.0.0.0/8' if $net == 10;
		$info->{owner} = 'LAN';
	}
	# obtener red y dueño para ip loopback
	if (main::ip_loopback($ip)) {
		$info->{net} = '127.0.0.0/8';
		$info->{owner} = 'LOOPBACK';
	}
	# obtener red y dueño para red pública
	# TODO: buscar mediante whois la red y dueño de la IP
	if ($info->{net} eq '') {
		#$self->{owner} = trim(`whois $block$net/$mask | grep owner: | awk -F : '{print \$2}'`);
		$info->{net} = 'NET';
		$info->{owner} = 'OWNER';
	}
	# retornar
	return $info;
}

# Método que entrega los puertos abiertos NmapHostPort
sub getOpenPorts {
	my ( $self ) = @_;
	# generar datos de los puertos (armar arreglo de hashes)
	my $ports_data = $self->{data}->{ports}{port};
	$ports_data = [$ports_data] if ref($ports_data) eq 'HASH';
	$ports_data = [] if ref($ports_data) ne 'ARRAY';
	# recorrer puertos, si está abierto se crea un objeto y se agrega
	# al arreglo que se retornará
	my @ports;
	foreach my $port (@$ports_data) {
		if ($port->{state}->{state} eq "open") {
			push (@ports, {
				protocol => $port->{protocol},
				id => $port->{portid},
				state => $port->{state}->{state},
				service => $port->{service}->{name},
				product => $port->{service}->{product},
				version => $port->{service}->{version},
				extrainfo => $port->{service}->{extrainfo},
				ostype => $port->{service}->{ostype}
			});
		}
	}
	return @ports;
}

# hacer que eval, evalue el archivo como TRUE
1;
