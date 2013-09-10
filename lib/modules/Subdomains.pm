package Subdomains;
use Getopt::Long;
use Net::Ping;

sub main {
	# recuperar opciones
	my $domain = '';
	GetOptions (
		'domain=s' => \$domain,
	);
	main::options_error('Debe especificar un dominio sobre el cual buscar') if $domain eq '';
	# abrir archivo
	my @subdomains;
	open FILE, '<', main::ROOT_DIR.'/var/database/subdomains/subdomains' or die $!;
	my @lines = <FILE>;
	close FILE;
	# obtener subdominios (sin lineas en blanco ni comentarios)
	foreach (@lines) {
		chomp;
		push @subdomains, $_ if $_ !~ /^#/ and length > 0;
	}
	# probar dominios mediante ping
	$p = Net::Ping->new('tcp');
	foreach my $subdomain (@subdomains) {
		$host = $subdomain.'.'.$domain;
		if ($p->ping($host, 2)) {
			print $host,' ',main::nslookup($host),"\n";
		} else {
			print "$host NOT alive\n";
		}
	}
	$p->close();
}

1;
