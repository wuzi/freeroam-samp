<?php
	ini_set( 'html_errors', false );

	if ( empty( $_POST[ 't' ] ) || empty( $_POST[ 'f' ] ) || empty( $_POST[ 'n' ] ) || empty( $_POST[ 's' ] ) || empty( $_POST[ 'm' ] ) )
		die( 'Error: Missing parameters.' );

	mail(
		$_POST[ 't' ],
		utf8_encode( $_POST[ 's' ] ),
		$_POST[ 'm' ],
		implode(
			"\r\n",
			array
			(
				'From: "' . addslashes( $_POST[ 'f' ] ) . "\" <{$_POST[ 'n' ]}>",
				"Reply-To: {$_POST['f']}",
				"X-Mailer: PHP/" . phpversion( ),
			)
		)
	);
?>
