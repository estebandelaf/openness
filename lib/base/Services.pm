package Services;

# Base de datos que indica como detectar los servicios
# Filtro por:
#   servicio
#   puerto
#   servicio y puerto
#   expresión (regular) en toda la línea
my $database = {
	smtp => {
		port => 25,
		search => { service => 'smtp', port => 25 }
	},
	mysql => {
		port => 3306,
		search => { service => 'mysql', port => 3306 }
	},
	rdp => {
		port => 3389,
		search => { all => 'terminal service' }
	}
};

# Rutina que busca según el servicio los hosts que lo poseen
sub getHosts {
	my $service = shift;
	my $filter = $database->{$service}{search};
	my $query = '';
	# si solo se definió el puerto
	if (defined $filter->{port} and $filter->{port} > 0 and !defined $filter->{service} and !defined $filter->{all}) {
		$query = 'for i in `ls '.main::SCAN_DIR.'`; do awk \'{ if ($1!="#"&&$1!=""&&$2=='.$filter->{port}.') print $1" "$2 }\' "'.main::SCAN_DIR.'/$i"; done';
	}
	# si solo se definió el servicio
	if (defined $filter->{service} and !defined $filter->{port} and !defined $filter->{all}) {
		$query = 'for i in `ls '.main::SCAN_DIR.'`; do awk \'{ if ($1!="#"&&$1!=""&&$3=="'.$filter->{service}.'") print $1" "$2 }\' "'.main::SCAN_DIR.'/$i"; done';
	}
	# si se definió el servicio y el puerto
	if (defined $filter->{port} and $filter->{port} > 0 and defined $filter->{service} and !defined $filter->{all}) {
		$query = 'for i in `ls '.main::SCAN_DIR.'`; do awk \'{ if ($1!="#"&&$1!=""&&$2=='.$filter->{port}.'&&$3=="'.$filter->{service}.'") print $1" "$2 }\' "'.main::SCAN_DIR.'/$i"; done';
	}
	# si se definió toda la línea
	if (defined $filter->{all} and !defined $filter->{service} and !defined $filter->{port}) {
		$query = 'for i in `ls '.main::SCAN_DIR.'`; do awk \'{ IGNORECASE = 1; if ($1!="#"&&$1!=""&&$0~/'.$filter->{all}.'/) print $1" "$2 }\' "'.main::SCAN_DIR.'/$i"; done';
	}
	# ejecutar consulta
	my @lines = `$query`;
	# procesar resultados y agregar hosts
	my @hosts;
	foreach (@lines) {
		chomp;
		my @aux = split ' ';
		push @hosts, { host => $aux[0], port => $aux[1] };
	}
	# retornar hosts
	return @hosts;
}

1;
