<?php 
namespace App\Models;
use CodeIgniter\Model;

class RequestsModel extends Model {
    protected $table='credentials_requests';
    protected $primaryKey='id';
    protected $allowedFields= [
            'id',
            'holderPublicKeyPEM',
            'holderUuid' ,
            'returnAPI',
            'totalFiles',
            'files',
            'created_at',
            'request_served'];
    protected $createdField='created_at';
    protected $useAutoIncrement = true;
    protected $returnType     = 'array';
    


    function __construct()
    {
        parent::__construct();
    }
}

