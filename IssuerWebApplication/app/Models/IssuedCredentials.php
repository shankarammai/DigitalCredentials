<?php 
namespace App\Models;
use CodeIgniter\Model;

class IssuedCredentials extends Model {
    protected $table='IssuedCredentials';
    protected $primaryKey='id';
    protected $allowedFields= [
        'id',
        'holder_uuid',
        'uuid',
        'data' ,
        ];
    protected $useAutoIncrement = true;
    protected $returnType     = 'array';
    


    function __construct()
    {
        parent::__construct();
    }
}

