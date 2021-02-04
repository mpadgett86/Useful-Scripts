// PHP Server Run Command
// sudo php -t ~/http-web/ -S 127.0.0.1:2222
// Requires SUDO to save filestream
// -t = the directory of this server.php file
// -S = php server listening on IP:PORT

<?php 

$use_sts = true;

// iis sets HTTPS to 'off' for non-SSL requests
if ($use_sts && isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] != 'off') {
    header('Strict-Transport-Security: max-age=31536000');
} elseif ($use_sts) {
    header('Location: https://'.$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'], true, 301);
    // we are in cleartext at the moment, prevent further execution and output
    die();
}

if(!empty($_POST['name'])){
	$name = $_POST['name'];			// Get the user name from the machine.
	$date = $_POST['date'];			// Get the date/time stamp from the machine.
	$data = $_POST['data'];			// Get data to be analyzed. i.e. Return values from a PowerShell script.

	$fname = $name . ".txt";		// Take user name and use it as the log file name for ease of access.

	$file = fopen($fname, 'a');				            // Open the log file.
       		fwrite($file, "[" . $date . "]" . "\n");	// Write the date to the log.
		fwrite($file, $data . "\n");			        // Write the data to the log.
		fwrite($file, "##############################\n");
	fclose($file);						                // Close the log file.
}
?>
