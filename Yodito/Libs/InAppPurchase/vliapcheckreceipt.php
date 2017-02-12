<?php
// http://localhost/partyplanner/vliapsubscriptions/vliapcheckreceipt.php?secret=fdsgdfgv&receipt=fragregeatga&debug=true

class VLCRCommon
{
	public static $kHttpParamSecret = "secret";
	public static $kHttpParamReceipt = "receipt";
	public static $kHttpParamDebug = "debug";
	
	public static $kJsonKeyCode = "code";
	public static $kJsonKeyStatus = "status";
	public static $kJsonKeyReceiptStatus = "receipt_stat";
	public static $kJsonErrorWrongResponseFromITunesServer = -401;
	
	public static $kJsonReceiptValidStatusValue = 73953;
	
	public static $kVerifyReceiptUrl = "https://buy.itunes.apple.com/verifyReceipt";
	public static $kVerifyReceiptUrlSandbox = "https://sandbox.itunes.apple.com/verifyReceipt";
}

function postOrGetParam($paramName)
{
	if(isset($_POST[$paramName]))
		return $_POST[$paramName];
	if(isset($_GET[$paramName]))
		return $_GET[$paramName];
	return null;
}

function getReceiptDataFromAppleServer($receipt, $secret, $isSandbox)
{
	// determine which endpoint to use for verifying the receipt
	if ($isSandbox)
		$endpoint = VLCRCommon::$kVerifyReceiptUrlSandbox;
	else
		$endpoint = VLCRCommon::$kVerifyReceiptUrl;
 
	// build the post data
	$postData = json_encode(array('receipt-data' => $receipt, 'password' => $receipt));
 
	// create the cURL request
	$ch = curl_init($endpoint);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_POST, true);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);
	curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
 
	// execute the cURL request and fetch response data
	$response = curl_exec($ch);
	$errno    = curl_errno($ch);
	$errmsg   = curl_error($ch);
	curl_close($ch);
 
	// ensure the request succeeded
	if ($errno != 0)
		throw new Exception($errmsg, $errno);
 
	// parse the response data
	$data = json_decode($response, true);

	return $data;
}

$secret = postOrGetParam(VLCRCommon::$kHttpParamSecret);
$sReceiptB64 = postOrGetParam(VLCRCommon::$kHttpParamReceipt);
$receiptData = $sReceiptB64;
$isDebug = postOrGetParam(VLCRCommon::$kHttpParamDebug);
$isDebug = isset($isDebug) ? (filter_var($isDebug, FILTER_VALIDATE_BOOLEAN)) : false;

$response = getReceiptDataFromAppleServer($receiptData, $secret, $isDebug);
if(!array_key_exists(VLCRCommon::$kJsonKeyStatus, $response))
{
	$jsonResponse = json_encode(array(VLCRCommon::$kJsonKeyCode => VLCRCommon::$kJsonErrorWrongResponseFromITunesServer, 'text' => ""));
	echo $jsonResponse;
	exit;
}
$status = $response[VLCRCommon::$kJsonKeyStatus];
$status = intval($status);
if($status === 0)
	$status = VLCRCommon::$kJsonReceiptValidStatusValue;

$jsonResponse = json_encode(array(VLCRCommon::$kJsonKeyCode => 0, VLCRCommon::$kJsonKeyReceiptStatus => $status, 'text' => ""));
echo $jsonResponse;

?>