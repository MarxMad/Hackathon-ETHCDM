// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract BecasAlimentarias is Ownable, Pausable {
    IERC20 public tokenMXNB;
    
    struct Alumno {
        string nombre;
        string matricula;
        bool activo;
        uint256 saldo;
    }
    
    struct Negocio {
        string nombre;
        bool activo;
        bool transferenciasHabilitadas;
    }
    
    mapping(address => Alumno) public alumnos;
    mapping(address => Negocio) public negocios;
    mapping(address => bool) public administradores;
    
    event BecaEmitida(address indexed beneficiario, uint256 cantidad);
    event AlumnoRegistrado(address indexed direccion, string nombre, string matricula);
    event NegocioRegistrado(address indexed direccion, string nombre);
    event TransferenciasHabilitadas(address indexed negocio, bool habilitado);
    
    constructor(address _tokenMXNB) Ownable(msg.sender) {
        tokenMXNB = IERC20(_tokenMXNB);
        administradores[msg.sender] = true;
    }
    
    modifier soloAdministrador() {
        require(administradores[msg.sender], "Solo administradores");
        _;
    }
    
    function registrarAlumno(
        address _direccion,
        string memory _nombre,
        string memory _matricula
    ) external soloAdministrador {
        require(!_esAlumno(_direccion), "Alumno ya registrado");
        alumnos[_direccion] = Alumno({
            nombre: _nombre,
            matricula: _matricula,
            activo: true,
            saldo: 0
        });
        emit AlumnoRegistrado(_direccion, _nombre, _matricula);
    }
    
    function registrarNegocio(
        address _direccion,
        string memory _nombre
    ) external soloAdministrador {
        require(!_esNegocio(_direccion), "Negocio ya registrado");
        negocios[_direccion] = Negocio({
            nombre: _nombre,
            activo: true,
            transferenciasHabilitadas: true
        });
        emit NegocioRegistrado(_direccion, _nombre);
    }
    
    function emitirBeca(
        address _beneficiario,
        uint256 _cantidad
    ) external soloAdministrador whenNotPaused {
        require(_esAlumno(_beneficiario), "No es un alumno registrado");
        require(alumnos[_beneficiario].activo, "Alumno inactivo");
        
        require(
            tokenMXNB.transferFrom(msg.sender, address(this), _cantidad),
            "Transferencia fallida"
        );
        
        alumnos[_beneficiario].saldo += _cantidad;
        emit BecaEmitida(_beneficiario, _cantidad);
    }
    
    function gastarBeca(
        address _negocio,
        uint256 _cantidad
    ) external whenNotPaused {
        require(_esAlumno(msg.sender), "No es un alumno registrado");
        require(alumnos[msg.sender].activo, "Alumno inactivo");
        require(_esNegocio(_negocio), "No es un negocio registrado");
        require(negocios[_negocio].activo, "Negocio inactivo");
        require(negocios[_negocio].transferenciasHabilitadas, "Transferencias deshabilitadas");
        require(alumnos[msg.sender].saldo >= _cantidad, "Saldo insuficiente");
        
        alumnos[msg.sender].saldo -= _cantidad;
        require(
            tokenMXNB.transfer(_negocio, _cantidad),
            "Transferencia fallida"
        );
    }
    
    function habilitarTransferencias(
        address _negocio,
        bool _habilitado
    ) external soloAdministrador {
        require(_esNegocio(_negocio), "No es un negocio registrado");
        negocios[_negocio].transferenciasHabilitadas = _habilitado;
        emit TransferenciasHabilitadas(_negocio, _habilitado);
    }
    
    function cambiarEstadoAlumno(
        address _alumno,
        bool _activo
    ) external soloAdministrador {
        require(_esAlumno(_alumno), "No es un alumno registrado");
        alumnos[_alumno].activo = _activo;
    }
    
    function cambiarEstadoNegocio(
        address _negocio,
        bool _activo
    ) external soloAdministrador {
        require(_esNegocio(_negocio), "No es un negocio registrado");
        negocios[_negocio].activo = _activo;
    }
    
    function agregarAdministrador(address _admin) external onlyOwner {
        administradores[_admin] = true;
    }
    
    function removerAdministrador(address _admin) external onlyOwner {
        administradores[_admin] = false;
    }
    
    function _esAlumno(address _direccion) internal view returns (bool) {
        return bytes(alumnos[_direccion].matricula).length > 0;
    }
    
    function _esNegocio(address _direccion) internal view returns (bool) {
        return bytes(negocios[_direccion].nombre).length > 0;
    }
} 