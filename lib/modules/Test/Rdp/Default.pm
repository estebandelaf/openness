package Test::Rdp::Default;

sub main {
	# recibir parámetros
	my $hosts = shift;
	my $options = shift;
	# ejecutar test para el servicio
	foreach my $host (@$hosts) {
		my $msg = "[Administrador:administrador\@$host->{host}:$host->{port}]";
		print "$msg\n";
		system("rdesktop -z -a 16 -k es -T '$msg' -u Administrador -p administrador $host->{host}:$host->{port}");
		$msg = "[Invitado:\@$host->{host}:$host->{port}]";
		print "$msg\n";
		system("rdesktop -z -a 16 -k es -T '$msg' -u Invitado -p '' $host->{host}:$host->{port}");
	}
}

1;
