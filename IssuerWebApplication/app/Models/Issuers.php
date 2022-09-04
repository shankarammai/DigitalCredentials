<?php 
namespace App\Models;
use CodeIgniter\Model;

class Issuers extends Model {
    protected $table='Issuers';
    protected $primaryKey='id';
    protected $allowedFields= [
        'id',
            'uuid',
            'documentAPI' ,
            'returnAPI',
            'name',
            'publicKeyPEM',
        ];
    protected $useAutoIncrement = true;
    protected $returnType     = 'array';
    


    function __construct()
    {
        parent::__construct();
    }
}

