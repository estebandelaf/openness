package Test::Smtp::Default;

sub main {
	# recibir parámetros
	my $hosts = shift;
	my $options = shift;
	# ejecutar test para el servicio
	foreach my $host (@$hosts) {
		my $status = main::email_send (
			$host->{host},
			$host->{port},
			'webmaster@example.com',
			'webmaster@example.com',
			'Test',
			'Test'
		);
		print $host->{host},"\n" if !$status;
	}
}

1;
