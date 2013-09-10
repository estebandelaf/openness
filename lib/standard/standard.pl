#
# general.pl
# Copyright (C) 2012 Esteban De La Fuente Rubio (esteban[at]delaf.cl)
#
# Librería de rutinas para propósitos generales.
#

# Rutina que verifica si una función/rutina de Perl existe
sub function_exists {    
    no strict 'refs';
    my $funcname = shift;
    return \&{$funcname} if defined &{$funcname};
    return;
}

# Rutina para quitar espacios al inicio y final de una cadena (además
# quita salto de línea en caso de existir)
sub trim {
	my $string = shift;
	chomp $string;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

# Rutina para generar un string de forma aleatoria
# Original: http://th.atguy.com/mycode/generate_random_string/
sub str_random {
	my $length = shift;
	my @chars=('a'..'z', '0'..'9');
	my $string;
	foreach (1..$length) {
		$string .= $chars[rand @chars];
	}
	return $string;
}

# Rutina para generar fecha en el formato requerido por correos
# electrónicos
# Original: http://members.toast.net/strycher/perl/example_net_smtp.htm
use Time::Zone;
sub date_r {
	@DAYS = ('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun');
	@MON = ('Jan', 'Feb', 'Mar', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Nov', 'Dic');
	my ($day, $mon, $str);
	my (@lt) = ();
	@lt = localtime();
	$day = $lt[6] - 1;
	$mon = $lt[4] - 1;
	$str = $DAYS[$day] . ", " . $lt[3] . " " . $MON[$mon] . " " . ($lt[5]+1900)
		. " " . sprintf("%02d:%02d:%02d", $lt[2], $lt[1], $lt[0] )
		. " " . sprintf("%03d%02d", (Time::Zone::tz_offset() / 3600), 0);
	return $str;
}

# Rutina para imprimir lo pasado por pantalla y para guardarlo en el
# archivo indicado
sub print2 {
	$file = shift;
	$text = shift;
	print $text;
	print $file $text;
}

# hacer que eval, evalue el archivo como TRUE
1;
