// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Beca is ERC20, Ownable {
    mapping(address => bool) public registeredStudents;
    mapping(address => bool) public authorizedBusinesses;
    bool public B2B_transfersAllowed;
    //mapping(address => uint) public biz2bizTickets; 
    //mapping(address => address) public authorizedBisList;      /// Este mapping guarda la lista de BIS autorizadas, para que puedan pedir acceso a sus contratos.  
    
    // Solo permitimos que se le haga un transferencia entre negocios si el flag está activado (desactivado por default)
    constructor() ERC20("BecaUSDC", "bUSDC") Ownable(msg.sender) {
        B2B_transfersAllowed = false; // Inicialmente desactivado
    }



    // Función para registrar alumnos (solo dueño)
    function registerStudent(address _alumno) external onlyOwner{
        registeredStudents[_alumno] = true;
    }

    // Función para autorizar negocios (solo dueño)
    function authorizeBisness(address _negocio, bool _autorizado) external{
        authorizedBusinesses[_negocio] = _autorizado;
    }

    // Emitir becas en USDT (solo dueño)
    function otorgarBeca(address _alumno, uint256 _monto) external onlyOwner {
        require(registeredStudents[_alumno], "Beca: Alumno no registrado");
        _mint(_alumno, _monto);
    }

    // Transferencias entre negocios (opcional)
    function B2B(address _destino, uint256 _monto) external {
        require(authorizedBusinesses[msg.sender] && authorizedBusinesses[_destino], "BecaToken: Negocio no autorizado");
        require(B2B_transfersAllowed, "BecaToken: Transferencias bloqueadas");
        _transfer(msg.sender, _destino, _monto);
    }

    // Activar/desactivar transferencias entre negocios (solo dueño)
    function toggleB2Btransfers() external{
        B2B_transfersAllowed = !B2B_transfersAllowed;
    }
}