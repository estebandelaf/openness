package Search;
use Getopt::Long;

sub main {
	# recuperar opciones
	my $ip = '';
	my $port = 0;
	my $service = '';
	my $all = '';
	GetOptions (
		'ip=s' => \$ip,
		'port=i' => \$port,
		'service=s' => \$service,
		'all=s' => \$all
	);
	# si no se paso ninguna opción
	if ($ip eq '' and $port == 0 and $service eq '' and $all eq '') {
		main::options_error ('Debe especificar algún filtro para la búsqueda.');
	}
	# si se debe hacer match con cualquier línea
	if ($ip ne '') {
		system ('for i in `ls '.main::SCAN_DIR.'`; do awk \'{ if ($1!="#"&&$1!=""&&$1=="'.$ip.'") print $0 }\' "'.main::SCAN_DIR.'/$i"; done');
	}
	# si se debe buscar por puerto
	if ($port > 0) {
		system ('for i in `ls '.main::SCAN_DIR.'`; do awk \'{ if ($1!="#"&&$1!=""&&$2=='.$port.') print $0 }\' "'.main::SCAN_DIR.'/$i"; done');
	}
	# si se debe buscar por servicio
	if ($service ne '') {
		system ('for i in `ls '.main::SCAN_DIR.'`; do awk \'{ if ($1!="#"&&$1!=""&&$3=="'.$service.'") print $0 }\' "'.main::SCAN_DIR.'/$i"; done');
	}
	# si se debe hacer match con cualquier línea
	if ($all ne '') {
		system ('for i in `ls '.main::SCAN_DIR.'`; do awk \'{ IGNORECASE = 1; if ($1!="#"&&$1!=""&&$0~/'.$all.'/) print $0 }\' "'.main::SCAN_DIR.'/$i"; done');
	}
}

1;
