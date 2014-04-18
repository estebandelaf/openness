package Remote;
use HTTP::Request::Common;
use LWP::UserAgent;
use JSON;
use MIME::Base64;
use Try::Tiny;
#use Data::Dumper;

# Definir URI que se utilizará para la comunicación con el servidor
use constant URI => 'http://'.$Conf::conf->openness_server.'/bd/webservice';

# Rutina que envía un archivo XML (de nmap) al servidor
sub sendXML {
	# solo se puede enviar el archivo si hay un hash de usuario
	if($Conf::conf->openness_user_hash eq '') {
		print STDERR '[warning] openness_user_hash en openness.conf no ha sido especificado. No se ha subido el XML.',"\n";
		return 1;
	}
	# recibir nombre del archivo
	my $file = shift;
	# realizar consulta
	my $ua = new LWP::UserAgent();
	my $res = $ua->request(
		POST URI,
		Content_Type => 'form-data',
		Content => [
			user_hash => $Conf::conf->openness_user_hash,
			action => 'sendXML',
			xml => [ $file ]
		]
	);
	# revisar que se haya podido enviar la consulta
	if ($res->is_success) {
		# recibir respuesta y procesar json a tipo de dato Perl
		try {
			my $response = decode_json $res->decoded_content;
                        $response->{data} = decode_base64 $response->{data} if $response->{header}{encoding} eq 'base64';
                        $response->{data} = decode_json $response->{data};
                        # verificar que se la consulta haya sido exitosa
                        if ($response->{header}->{status} eq 'ok') {
                                print 'Se ha enviado el XML al servidor ',$Conf::conf->openness_server,"\n";
                                return 0;
                        } else {
                                print STDERR '[warning] problemas al recibir el XML en el servidor ',$Conf::conf->openness_server,', error: ',$response->{header}->{error}->{mesg},"\n";
                        }
		} catch {
                        print STDERR '[warning] respuesta incorrecta del servidor ',$Conf::conf->openness_server,', error: no se recibió JSON, se recibió:',"\n\n",$res->decoded_content,"\n";
                        return 1;
                };
    } else {
        print STDERR '[warning] no se ha podido enviar el XML al servidor ',$Conf::conf->openness_server,', error: ',$res->status_line,"\n";
    }
    # si se llego hasta aca es porque hubo algún error
    return 1;
}

1;
