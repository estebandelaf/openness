package Test::Mysql::Default;

sub main {
	# recibir parámetros
	my $hosts = shift;
	my $options = shift;
	# ejecutar test para el servicio
	# definir usuarios
	my @users;
	if($options->{only_root}) {
		@users = ('root');
	} else {
		open USERS, '<', main::ROOT_DIR.'/var/database/users/users' or die $!;
		my @lines = <USERS>;
		close USERS;
		foreach (@lines) {
			chomp;
			push @users, $_ if $_ !~ /^#/ and length > 0;
		}
	}
	# definir contraseñas
	my @passwords;
	open PASSWORDS, '<', main::ROOT_DIR.'/var/database/passwords/passwords' or die $!;
	my @lines = <PASSWORDS>;
	close PASSWORDS;
	foreach (@lines) {
		chomp;
		push @passwords, $_ if $_ !~ /^#/ and length > 0;
	}
	foreach my $host (@$hosts) {
		# correr test por cada usuario
		foreach my $user (@users) {
			# Agregar claves comunes que dependen del usuario
			unshift @passwords, $user;
			unshift @passwords, $user.'1';
			unshift @passwords, $user.'123';
			unshift @passwords, $user.'.,';
			# Por cada clave correr el test
			foreach my $password (@passwords) {
				print "[$user:$password\@$host->{host}:$host->{port}] ";
				system("mysql --host=$host->{host} --port=$host->{port} --user=$user --password=$password");
			}
		}
	}
}

1;
