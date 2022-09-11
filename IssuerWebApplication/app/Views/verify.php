<!doctype html>
<html lang="en">
  <head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.3/font/bootstrap-icons.css">
    <script src="//cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jsencrypt/3.2.1/jsencrypt.min.js" integrity="sha512-hI8jEOQLtyzkIiWVygLAcKPradIhgXQUl8I3lk2FUmZ8sZNbSSdHHrWo5mrmsW1Aex+oFZ+UUK7EJTVwyjiFLA==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.1.1/crypto-js.min.js" integrity="sha512-E8QSvWZ0eCLGk4km3hxSsNmGWbLtSCSUcewDQPQWZF6pEU8GlT8a5fF32wOl1i8ftdMhssTrF/OhyGWwonTcXA==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jsrsasign/8.0.20/jsrsasign-all-min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.1/jquery.js" integrity="sha512-CX7sDOp7UTAq+i1FYIlf9Uo27x4os+kGeoT7rgwvY+4dmjqV0IuE/Bl5hVsjnQPQiTOhAX1O2r2j5bjsFBvv/A==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/forge/1.3.1/forge.min.js" integrity="sha512-95iy0RZIbw3H/FgfAj2wnCQJlzFQ+eaSfUeV/l8WVyGHKSRMzm3M/O+85j9ba/HFphkijrCTDjcuDX0BL2lthA==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>    <title>Digital Credentials</title>
  </head>
  <body>
	<nav class="navbar navbar-dark bg-primary navbar-expand-lg">
  <div class="container-fluid">
    <a class="navbar-brand" href="#">Digital Credentials</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav">
        <li class="nav-item">
          <a class="nav-link active" aria-current="page" href=".">Home</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="dashboard">Dashboard</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="DigitalCredentials">Docs</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="Verify">Verify</a>
        </li>
      </ul>
    </div>
  </div>
</nav>
	<div class="container">
    <div class="mt-4 mb-4">
      <label for="credentialUpload" class="form-label">Upload verifiable credential file</label>
      <input class="form-control form-control-lg" id="credentialUpload" type="file" name="credential" accept="application/JSON">
    </div>

    <div class="card" id="dropZone">
      <div class="card-header">
        Upload Credential file here
      </div>
      <div class="card-body">
      Drag files here
    <br><br><br><br><br>
      </div>
  </div>




        <button type="button" class="btn btn-primary mt-2" id="verifyCredential">Verify</button>

      <div id="credentialArea"class="row">
      

      </div>
                
<script>
    document.getElementById('verifyCredential').addEventListener('click', verifyDocument);

    
    var credentialDoc=null;
    var dropZone = document.getElementById('dropZone');

    // Optional.   Show the copy icon when dragging over.  Seems to only work for chrome.
    dropZone.addEventListener('dragover', function(e) {
        e.stopPropagation();
        e.preventDefault();
        e.dataTransfer.dropEffect = 'copy';
    });

    // Get file data on drop
    dropZone.addEventListener('drop', function(e) {
      console.log("dropped");
        e.stopPropagation();
        e.preventDefault();
        var files = e.dataTransfer.files; // Array of all files
        document.getElementById('credentialUpload').files=files;
        for (var i=0, file; file=files[i]; i++) {
            if (file.type.match(/application.json/)) {
                console.log("JSON uploaded");
                getFileFromUpload();}
            }  
        });

        var inputBtn = document.getElementById('credentialUpload');
        var credential= null;
        // When file is uploader is changed then load function called getFileFromUpload
        inputBtn.addEventListener('change', getFileFromUpload);
        var credentiaArea = document.getElementById('credentiaArea');

        //Reads content from the files then create card using the deatils of the particular credential.
        function getFileFromUpload() {
          const reader = new FileReader;
          reader.onload = function () {
            credential = reader.result;
            var credentialArea = document.getElementById('credentialArea');
            var credentialObj = JSON.parse(credential);
            credentialDoc=credentialObj;
            console.log(credentialObj);
            // Add the following code to the credential area.
           credentialArea.innerHTML=`
                          <div class="col-12 mt-4 credential credentialno">
                            <div class="card">
                              <div class="card-body">
                                <h5 class="card-title">Name of Issuer  = <strong>${credentialObj.issuer.name} </strong> </h5>
                                <p class="card-text" id='credentialData'></p>
                              </div>
                            </div>
                          </div>`;


            Object.entries(credentialObj.credentialData.data).forEach(([key, value]) => {
              console.log(key + ' - ' + value) // key - value
              document.getElementById('credentialData').innerHTML+=`<p>${key} <strong>${value}</strong>`;

            });

          }
          reader.readAsText(inputBtn.files[0]);
          
        };

        function verifyDocument(){
            // $.post("https://shankarammai.com.np/VerifiableCredentials/api/verifyDoc", {credentialDocument: JSON.stringify(credentialDoc)}, function(result){
            //   if(result.success){
            //   
            //}
            // });

          // var verify = new JSEncrypt();
          // verify.setPublicKey(credentialDoc.issuer.publicKey);

          var pkey=forge.pki.publicKeyFromPem(credentialDoc.issuer.publicKey);
          var md = forge.md.sha256.create();
          md.update(credentialDoc.credentialData.data, 'utf8');
          //check the signature
          if(credentialDoc.credentialData.hasOwnProperty('selectiveFieldsproof')){

          }
          else{
            var signatureDecoded=forge.util.decode64(credentialDoc.proof.proofValue);
            var verified = pkey.verify(md.digest().bytes(),signatureDecoded );
            console.log(verified);
            // var verified = verify.verify(credentialDoc.credentialData.data, credentialDoc.proof.proofValue, CryptoJS.SHA256);
            // console.log(verified);
          }
           Swal.fire('Signature Matches',`Issued by ${credentialDoc.issuer.name}`,'success');
        }

        </script>


    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>
  </body>
</html>
