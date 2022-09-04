<?php 
namespace App\Models;
use CodeIgniter\Model;

class ShowCredentials extends Model {
    protected $table='ShowCredential';
    protected $primaryKey='id';
    protected $allowedFields= [
            'id',
            'uuid',
            'data' ,
            'accessed_by'
        ];
    protected $useAutoIncrement = true;
    protected $returnType     = 'array';
    


    function __construct()
    {
        parent::__construct();
    }
}

