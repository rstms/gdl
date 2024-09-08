# gdl

gdl - write URL content to local file using designated CA and client cert

Requires PEM-formatted CA, client certificate, client_key files, 
specified with flags or environment variables.

If not provided, OUTPUT_FILE is set from the final element of the URL.
Use - to write output to stdout.

usage: gdl [flags] URL [OUTPUT_FILE]

  -ca file
    	certificate authority file [GDL_CA]
  -cert file
    	client cert file [GDL_CERT]
  -key file
    	client cert key file [GDL_KEY]
  -v	verbose output
