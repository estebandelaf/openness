#
# Config
# Copyright (C) 2014 Esteban De La Fuente Rubio (esteban[at]delaf.cl)
#
# Archivo que define variables de configuración y las carga desde el
# archivo de configuración de la aplicación (si existe).
#
package Conf;

# Nombre del archivo de configuración
use constant CONF_FILE => 'openness.conf';

# Módulos requeridos
use AppConfig;
use AppConfig qw(:expand :argcount);

# Crear objeto de la configuración
$conf = AppConfig->new(
	# Opciones del objeto de configuración
	{
		GLOBAL => {
			ARGCOUNT => ARGCOUNT_ONE
		}
	},
	# Variables y sus valores por defecto
	# Opciones generales
	'openness_server'		=> { DEFAULT => 'https://openness.sasco.cl' },
	'openness_user_hash'	=> { DEFAULT => '' },
	# Opciones del módulo "scan"
	'scan_up'				=> { DEFAULT => 0 },
	'scan_args'				=> { DEFAULT => '-PS22,23,25,53,80 -A --osscan-limit' },
	'scan_all_ports'		=> { DEFAULT => 0 },
	'scan_host_timeout'		=> { DEFAULT => 30 },
	'scan_version_all'		=> { DEFAULT => 0 },
	# Opciones del módulo "email"
	'email_server'			=> { DEFAULT => '' },
	'email_port'			=> { DEFAULT => 25 },
	'email_from'			=> { DEFAULT => '' },
);

# Si existe el archivo de configuración, cargarlo
$conf->file(CONF_FILE) if (-e CONF_FILE);

1;
