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

    .TopRequirementHeader {
        color: #000000;
    }

</style>
"@
