# CSS Codes for Report Exporting
$CSSHeader = @"
<style>
	h1 {
		font-family: Arial, Helvetica, sans-serif;
		color: #e68a00;
		font-size: 28px;
	}
	
	h2 {
		font-family: Arial, Helvetica, sans-serif;
		color: #000099;
		font-size: 18px;

	}

	h3 {
		font-family: Arial, Helvetica, sans-serif;
		color: #0080a0;
		font-size: 16px;

	}
	
   table {
		font-size: 12px;
		border: 0px; 
		font-family: Arial, Helvetica, sans-serif;
	} 

	td {
		padding: 4px;
		margin: 0px;
		border: 0;
	}

	th {
		background: #395870;
		background: linear-gradient(#49708f, #293f50);
		color: #fff;
		font-size: 11px;
		text-transform: uppercase;
		padding: 10px 15px;
		vertical-align: middle;
	}

	tbody tr:nth-child(even) {
		background: #f0f0f2;
	} 

	#CreationDate {
		font-family: Arial, Helvetica, sans-serif;
		color: #ff3300;
		font-size: 12px;
	}

	#RequirementHeader {
		font-family: Arial, Helvetica, sans-serif;
		color: #ff0000;
		font-size: 32px;
	}

	#Req2 {
		font-family: Arial, Helvetica, sans-serif;
		color: #ff0000;
		font-size: 32px;
	}

	#Req4 {
		font-family: Arial, Helvetica, sans-serif;
		color: #ff0000;
		font-size: 32px;
	}

	#Req5 {
		font-family: Arial, Helvetica, sans-serif;
		color: #ff0000;
		font-size: 32px;
	}

	#Req7 {
		font-family: Arial, Helvetica, sans-serif;
		color: #ff0000;
		font-size: 32px;
	}

	#Req8 {
		font-family: Arial, Helvetica, sans-serif;
		color: #ff0000;
		font-size: 32px;
	}

	#Req10 {
		font-family: Arial, Helvetica, sans-serif;
		color: #ff0000;
		font-size: 32px;
	}

	#ReqDiag {
		font-family: Arial, Helvetica, sans-serif;
		color: #ff0000;
		font-size: 32px;
	}

	.AvailableStatus {
		color: #2a9df4;
	}
  
	.InstalledStatus {
		color: #008000;
	}

	.RemovedStatus {
		color: #ff0000;
	}

	.EnabledStatus {
		color: #008000;
	}

	.DisabledStatus {
		color: #ff0000;
	}

	h1.TopRequirementHeader {
		font-family: Arial, Helvetica, sans-serif;
		color: #000000;
		font-size: 32px;
	}

	#toc_container {
		background: #f9f9f9 none repeat scroll 0 0;
		border: 1px solid #aaa;
		display: table;
		font-size: 95%;
		margin-bottom: 1em;
		padding: 20px;
		width: auto;
	}

	.toc_title {
		font-weight: 700;
		text-align: center;
	}

	#toc_container li, #toc_container ul, #toc_container ul li{
		list-style: outside none none !important;
	}

	#myBtn {
		display: none; /* Hidden by default */
		position: fixed; /* Fixed/sticky position */
		bottom: 20px; /* Place the button at the bottom of the page */
		right: 30px; /* Place the button 30px from the right */
		z-index: 99; /* Make sure it does not overlap */
		border: none; /* Remove borders */
		outline: none; /* Remove outline */
		background-color: red; /* Set a background color */
		color: white; /* Text color */
		cursor: pointer; /* Add a mouse pointer on hover */
		padding: 15px; /* Some padding */
		border-radius: 10px; /* Rounded corners */
	font-size: 18px; /* Increase font size */
	}

	#myBtn:hover {
		background-color: #555; /* Add a dark-grey background on hover */
	}
</style>
"@

$ScrollTopScript = @"
<script>
//Get the button
var mybutton = document.getElementById("myBtn");

// When the user scrolls down 20px from the top of the document, show the button
window.onscroll = function() {scrollFunction()};

function scrollFunction() {
  if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20) {
    mybutton.style.display = "block";
  } else {
    mybutton.style.display = "none";
  }
}

// When the user clicks on the button, scroll to the top of the document
function topFunction() {
  document.body.scrollTop = 0;
  document.documentElement.scrollTop = 0;
}
</script>
"@

$GlobalBackToTop = "<button onclick=`"topFunction()`" id=`"myBtn`" title=`"Go to top`">Top</button>"