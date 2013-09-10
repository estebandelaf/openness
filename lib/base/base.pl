# Rutina que dibuja la cabecera del programa
# Fuente: http://patorjk.com/software/taag/#p=display&f=Standard&t=OpenNESS
sub header {
	my $pre = defined $_[0] ? $_[0] : '';
	my $to = defined $_[1] ? $_[1] : *STDOUT;
	print $to $pre,'   ___                   _   _ _____ ____ ____  ',"\n";
	print $to $pre,'  / _ \ _ __   ___ _ __ | \ | | ____/ ___/ ___| ',"\n";
	print $to $pre,' | | | | \'_ \ / _ \ \'_ \|  \| |  _| \___ \___ \ ',"\n";
	print $to $pre,' | |_| | |_) |  __/ | | | |\  | |___ ___) |__) |',"\n";
	print $to $pre,'  \___/| .__/ \___|_| |_|_| \_|_____|____/____/ ',"\n";
	print $to $pre,'       |_|                                      ',"\n";
	print $to $pre,'                                        by DeLaF',"\n\n";
}

# Rutina que muestra un mensaje de error e indica que se vea la ayuda de la aplicación
sub options_error {
	my $msg = shift;
	print STDERR '[error] ',$msg,"\n";
	print STDERR 'Utilice "',$0,' {módulo} help" para ver la ayuda y opciones del módulo.',"\n\n";
	exit 1;
}

1;
