<!doctype html>
<html lang="en">
  <head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.3/font/bootstrap-icons.css">
    <script src="//cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <title>Digital Credentials</title>
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
        <div class="form-group">
            <label for="exampleFormControlInput1">Issuer Name</label>
            <input type="email" class="form-control" id="exampleFormControlInput1" value="DVLA UK" readonly> 
        </div>
        <div class="form-group">
            <label for="apitext">API to send credential Request</label>
            <input type="text" class="form-control" id="apitext" value="https://shankarammai.com.np/VerifiableCredentials/public/api/sendDocs" readonly> 
        </div>

        <div class="form-group">
            <label for="publickey">Public Key</label>
            <textarea class="form-control" id="publickey" rows="10" readonly>
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn5NzHhb+tKXppCBcLqXj
IgRub2JrEhAxM0UF0zK7d01cZsqIYQVxUceyGrg30UZ6LkSnUe5aBwTDPbcAzKSv
rCMZP49dyDdAFoEfR0UczEPQ1m1I2dsvGoYVMHwI22V80MKdeWA9BvzOrbjIrxIS
uTkByA3GCfPyW6Lf+wfjuZB7ENzAkWKxRvfmGAJNx0KXkkXONGZEJepciy0We8Xc
cWlZimgYGbuUIXYkk/PIxWgkORE9u1NZwUGY8OXMeqae2SmDjbrPQ6bEZ1cedR+4
siCS5Q9VOU4/rpquqJUnuLL6ZKpnHbjv2iOJZhsjIdLrN4+RhKt7FxIcGKOuh/0s
+QIDAQAB
-----END PUBLIC KEY-----</textarea>
        </div>

                <div class="form-group">
            <label for="publickey">Paste Public Key to compare</label>
            <textarea class="form-control" id="publickeyCheck"></textarea>
        </div>
        <button type="button" class="btn btn-primary mt-2" id="compare">Compare</button>
                
        <script>
            document.getElementById("compare").addEventListener("click", function (){
                const checktextarea=document.getElementById("publickeyCheck");
                let publickey=document.getElementById("publickey");

                if(checktextarea.value==publickey.value){
                    console.log('Matched');
                    Swal.fire({icon: 'success',title: 'Public key match',});
                }
                else{
                    console.log('Does not match');
                    Swal.fire({icon: 'error',title: 'Public key does not match'});
                }
            });

        </script>


    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>
  </body>
</html>
