<?php

namespace App\Controllers;
require '../../vendor/autoload.php';
use App\Models\RequestsModel;
use App\Models\Issuers;
use App\Models\ShowCredentials;
use App\Models\IssuedCredentials;



use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use phpseclib\Crypt\RSA;
use phpseclib3\Crypt\PublicKeyLoader;
use phpseclib3\Crypt\AES;
use phpseclib3\Crypt\Random;


class Home extends BaseController
{
    protected $helpers = ['url', 'form','date','filesystem'];
    public $issuerUuid='cd1d21d7-64c8-4511-9ae9-6f719b162b6b';
    public function index()
    {
        return view('welcome_message');
    }


    public function dashboard()
    {
        //Responsible for Admin Dashboard
        $Requests=new RequestsModel();
        if(strtoupper($this->request->getMethod())=="POST"){
            $issuerPrivateKeyPEM=<<<EOD
-----BEGIN PRIVATE KEY-----
MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQCfk3MeFv60pemk
IFwupeMiBG5vYmsSEDEzRQXTMrt3TVxmyohhBXFRx7IauDfRRnouRKdR7loHBMM9
twDMpK+sIxk/j13IN0AWgR9HRRzMQ9DWbUjZ2y8ahhUwfAjbZXzQwp15YD0G/M6t
uMivEhK5OQHIDcYJ8/Jbot/7B+O5kHsQ3MCRYrFG9+YYAk3HQpeSRc40ZkQl6lyL
LRZ7xdxxaVmKaBgZu5QhdiST88jFaCQ5ET27U1nBQZjw5cx6pp7ZKYONus9DpsRn
Vx51H7iyIJLlD1U5Tj+umq6olSe4svpkqmcduO/aI4lmGyMh0us3j5GEq3sXEhwY
o66H/Sz5AgMBAAECggEBAJwnqksTrYQRp6UYlZyAcNflBjyxTp2Kgtrs/FpEFvcU
GQvtva9TqCSjCkLjapu8H+wO+r1ORYMAwh4uavXXYqFMZ3SvUtKOXoSnLniLxTaO
Vlq+7r9hoaKO+0VK20/27EFNcNRJvO6NjaKqZJgNU401n+yordcnhU7u/8ejXNFE
aUWmT7WwEhUQx0TK1rnApFWeEfhsEZeRWP745UxFunWhrUljdbTobprdMJHpjUyk
LzdSGSP49LtqR5yEqQ8PHqBpRIyP+JR7Pm7jOpLjwFWYA7v5NHd+W2YoC/hn201C
VZ0bbJm+ctpCCJTgYPlYYtmZLDCnb8jUDH7l8KUBa9ECgYEA1Tc69USEelsJaMu1
2oAud+RA4a5xzkN4NQfSoK2/IRnjwWg5lMo0v9GVrn//I2udFL14UAEl2HXudrFa
1b62lfYF3jxEtVk82ASsmLtgVPDlhHmUD9mTPgyu1lIl101CFQD4YVL6whyP+lU8
cTv0U31QTJdX4Xzb/Wtair4/j3cCgYEAv5jGg1IbKWiv1VWNFkBLjZaJvVi6YVYd
lytmMeRmaVqB1JKWPRYFTnJqFWq6aspvWKFCKWdlZyeYKc4xB+6JXBfxWH5LdvAh
dARj0HmVKO1AIOjmKzN9jbWkj0Eq2TiYZzAeHORDFg79K2+NAAB/RL0fAjWYUg2K
zcq8N14tow8CgYAsEfBjxbfEOpDlUkXSVfBE467tdssbISL1gxpsD72Tr/A9h7dv
I6RniYBwwxAPWCztnoQBtVsHNMkHS31E9Nh0gpeP6dEh0sIavEyYfRJaPDiUezS5
WfVvO9vffLdJmzRvdvXf1/DwskqoKXoGxaeoohw42IdXmiE2bjwWtWAZ3QKBgQCI
ei/1vRfCAGM3yG/uiLAI1FGbQcfJrAj59J0gLvzQUPsoS56fNr9i6NcuGE9f4IE+
FehGC/PMbgTSyqBccQsBQcDV82iX+Wcq+DGNf/3DIHTMvHmwDkaCGgB1VstJ3imZ
X0oj9GjhHp4yQYyjkrcVZM3gygKNeD4GZ0J5Ainp+wKBgQC4MV3+EEYDv2uVJBzm
0uO2Ro2XP0qH6jjn0KAbAixrasE3Qds1Hv95NEtk3tU2XKEEDrFHMn1zd/5LALnv
ZD/C9IkekVXh91zwv15tHKwVlTQNumaGH4VYbQUHTtueJt83mlSMBm4KZnuo6Bg0
H0ex4IIUjadswgTOA2zTu4i/jg==
-----END PRIVATE KEY-----

EOD;
$issuerPublicKeyPEM=<<<EOD
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn5NzHhb+tKXppCBcLqXj
IgRub2JrEhAxM0UF0zK7d01cZsqIYQVxUceyGrg30UZ6LkSnUe5aBwTDPbcAzKSv
rCMZP49dyDdAFoEfR0UczEPQ1m1I2dsvGoYVMHwI22V80MKdeWA9BvzOrbjIrxIS
uTkByA3GCfPyW6Lf+wfjuZB7ENzAkWKxRvfmGAJNx0KXkkXONGZEJepciy0We8Xc
cWlZimgYGbuUIXYkk/PIxWgkORE9u1NZwUGY8OXMeqae2SmDjbrPQ6bEZ1cedR+4
siCS5Q9VOU4/rpquqJUnuLL6ZKpnHbjv2iOJZhsjIdLrN4+RhKt7FxIcGKOuh/0s
+QIDAQAB
-----END PUBLIC KEY-----
EOD;
            $replyJson = $this->request->getPost("replyJson");
            $request_Id = $this->request->getPost("request_id");
            $request_Data=$Requests->find($request_Id);
            $holderPublicKeyPEM=$request_Data['holderPublicKeyPEM'];
            $holderUuid=$request_Data['holderUuid'];

        $issuerPrivateKey=openssl_pkey_get_private($issuerPrivateKeyPEM);


        $holderPublicKey = PublicKeyLoader::load($holderPublicKeyPEM, $password = false);

        //Generating random key for AES encryption
        $sharedKey= substr( str_shuffle( 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789' ), 0, 16 );
    
        //Encrypting Random Key with Holder public key
        openssl_public_encrypt($sharedKey,$encryptedSharedKey,$holderPublicKey, OPENSSL_PKCS1_PADDING);
        
        $cipher = new AES('cbc');
        $cipher->setIV(substr('ThisIsASecuredBlock', 0, 16));
        $cipher->setKey($sharedKey);

        //Encrypted Credential Data In JSON string
        $encryptedCredential=$cipher->encrypt($replyJson);
        
        //Signing Credential Data
        openssl_sign($replyJson,$signedCredential,$issuerPrivateKey,OPENSSL_ALGO_SHA256);

        //Signing Individual Fields 
        $phpArray=json_decode($replyJson,$associative = true);
        $individualSignatures=[];        
        foreach ($phpArray as $key => $value) {
            openssl_sign($value,$individualSig,$issuerPrivateKey,OPENSSL_ALGO_SHA256 );
            $individualSignatures[$key]=base64_encode($individualSig);
        }

        //putting data in JSON
        $responseJson=[
            "issuer"=>["uuid"=>$this->issuerUuid,"publicKey"=>$issuerPublicKeyPEM,"name"=>"DVLA UK","website"=>"gov.uk"],
            "credentialSubject"=>["uuid"=>$holderUuid,"publicKey"=>$holderPublicKeyPEM],
            "proof"=>["type"=>"RSA","created"=>date('Y-m-d H:i:s'),"proofValue"=>base64_encode($signedCredential)],
            "credentialData"=>["data"=>base64_encode($encryptedCredential),"encryptionKey"=>base64_encode($encryptedSharedKey),"encryptionType"=>"AES-128-CBC","selectiveFieldsproof"=>$individualSignatures]
        ];
        $uuid= substr( str_shuffle( 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789' ), 0, 16 );

        $jsonData=json_encode($responseJson);

        //Sending Issued Credential
        $issusedCredentialData=[
            'uuid'=>$uuid,
            'holder_uuid'=>$holderUuid,
            'data'=>$jsonData
        ];
        $issuedCredentials=new IssuedCredentials();
        $issuedCredentials->insert($issusedCredentialData);
        write_file("new_credential.json", $jsonData);

        $Requests->where('id',$request_Id )->set(['request_served' => 1])->update();

        echo '<div class="alert alert-success alert-dismissible fade show" role="alert">
        <strong>Great!</strong> Credentail has been sent.
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
            <span aria-hidden="true">&times;</span>
        </button>
        </div>';
}

        $data['requests'] = $Requests->where('request_served', 0)->orderBy('id', 'DESC')->findAll();
        return view('dashboard',$data);
    }

    public function sendDocuments()
    {
        //Handels when people send document request
        $Requests=new RequestsModel();

        if(strtoupper($this->request->getMethod())=="POST"){
            $filesData=[];
            try{
                $holderPublicKeyPEM = $this->request->getPost("holderPublicKeyPEM");
                $holderUuid = $this->request->getPost("holderUuid");
                $returnAPI = $this->request->getPost("returnAPI");
                $totalFiles = (int) $this->request->getPost("totalFiles");

                for ($x = 0; $x < $totalFiles; $x++) {
                $file = $this->request->getFile('file'.$x);
                $fileName=$file->getName();
 
                $filesData[$x]=$fileName; 
                $file->move('../public/uploads/',$fileName);  
                }
              

            $dataInsert=array(
            'holderPublicKeyPEM'=>$holderPublicKeyPEM,
            'holderUuid' =>$holderUuid,
            'returnAPI' => $returnAPI,
            'totalFiles' => $totalFiles,
            'files'=>implode('-**||**-',$filesData)); 

        $queryResult=$Requests->insert($dataInsert);
        if($queryResult!=0){
            $data = ['success' => true,'insert_id' => $queryResult];
        }
        else{
            $data = ['success' => false];
        }

            }
            catch (Exception $e){
                        $data = ['success' => false];
            }

        return $this->response->setJSON($data);

        }
        return view('send_docs_instructions');
    }

    public function getMyIssuedCredentials(){
        if(strtoupper($this->request->getMethod())=="POST"){
            $user_uuid=$this->request->getPost("userUuid");  
            $issuedCredentials=  new IssuedCredentials();
            $result=$issuedCredentials->where('holder_uuid', $user_uuid)->findAll();
            if(!empty($result)){
                return $this->response->setJSON($result);
            }
        }
        return $this->response->setJSON([]);
 
    }


    public function getIssuers(){

        $Issuers=new Issuers();
        return $this->response->setJSON($Issuers->findAll());

    }

    public function deleteMyCredential(){
         if(strtoupper($this->request->getMethod())=="POST"){
            try{
                $request_Id = $this->request->getPost("delete_id");
                $issuedCredentials=new IssuedCredentials();
                $issuedCredentials->where('uuid', $request_Id)->delete();
                return $this->response->setJSON(['success'=>true]);
            }
            catch(Exception $err){
                return $this->response->setJSON(['msg'=>var_dump($err)]);
            }
         
        }
    }


    public function showCredDataSave(){


        if(strtoupper($this->request->getMethod())=="POST"){
            try{

                $ShowCredentials=new ShowCredentials();
                $docId= substr( str_shuffle( 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789' ), 0, 16 );

                $showCredentailDoc = $this->request->getPost("data");
                $dataForDb=[
                    "uuid"=>$docId,
                    "data"=>$showCredentailDoc
                ];
                $insertId=$ShowCredentials->save($dataForDb);
                if($insertId){
                return $this->response->setJSON(["docId"=>$docId]);
                }


            }
            catch(Exception $err){
                return $this->response->setJSON(['msg'=>var_dump($err)]);
            }
        }
        return $this->response->setJSON(['success'=>'false']);
    }

    public function loadShowCredential($id=null,$requester_id=null){

        if($id==null || $requester_id==null){
            return $this->response->setJSON([]);
        }

        $showCredentials=  new ShowCredentials();
        $result=$showCredentials->where('uuid', $id)->first();
        if($result){
            $previous_accessed_by=$result['accessed_by'];
            $accessed_by_data=['accessed_at'=>date('Y-m-d H:i:s'),'uuid'=>$requester_id];
            if($previous_accessed_by==''){
                $showCredentials->where('uuid', $id)->set(["accessed_by"=>json_encode([$accessed_by_data])])->update();
            }
            else{
                $decoded_previous=json_decode($previous_accessed_by);
                $decoded_previous[]=$accessed_by_data;
                // var_dump($decoded_previous);
                $showCredentials->where('uuid', $id)->set(["accessed_by"=>json_encode($decoded_previous)])->update();
            }
        $result=$showCredentials->where('uuid', $id)->first();
        if($result){
        return $this->response->setJSON($result);}
        }
        return $this->response->setJSON([]);


    }

    public function show_activities(){
         if(strtoupper($this->request->getMethod())=="POST"){
            $request_uuids=$this->request->getPost("uuids");
            $uuids=json_decode($request_uuids);
            $db      = \Config\Database::connect();
            $builder = $db->table('ShowCredential');
                     $builder = $db->table('ShowCredential')->select('id, uuid, accessed_by')->whereIn('uuid', $uuids);
                    // // $builder->from('mytable');
                    $query = $builder->get();
                    return $this->response->setJSON($query->getResult());
         }
    }

    public function docs(){

        return view('send_docs_instructions');
    }


    public function Verify(){

        return view('verify');
    }


}
