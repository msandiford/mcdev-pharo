"Seaside 3.0"
UIManager default inform: 'Loading Seaside 3.0'.
Gofer new
        squeaksource: 'MetacelloRepository';
        package: 'ConfigurationOfSeaside30';
        load.
(Smalltalk at: #ConfigurationOfSeaside30) load.
!
"AJP Server"
UIManager default inform: 'Loading AJP'.
Gofer new
        squeaksource: 'ajp';
        package: 'YBuffer-Core';
        package: 'YBuffer-Pharo-Core';
        package: 'AJP-Core';
        package: 'AJP-Pharo-Core';
        load.
!
"RFB (VNC) server/client"
UIManager default inform: 'Loading RFB'.
Gofer new
        squeaksource: 'MetacelloRepository';
        package: 'ConfigurationOfRFB';
        load.
(Smalltalk at: #ConfigurationOfRFB) load.
!
"Fixes for abnormally terminated connections"
FileStream fileIn: '../cs/RFBFixes.1.cs'.