// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract USDC_Adapter is Ownable {
    IERC20 public usdtReal;
    IERC20 public becaUSDC;

    // Direcciones oficiales en Arbitrum:
    // USDT: 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9
    constructor(address _usdtReal, address _becaUSDC) Ownable(msg.sender) {
        usdtReal = IERC20(_usdtReal);
        becaUSDC = IERC20(_becaUSDC);
    }

    // Canjear bUSDT por USDT real (solo negocios autorizados en BecaToken)
    function canjearPorUSDC(uint256 _monto) external {
        require(becaUSDC.transferFrom(msg.sender, address(this), _monto), "USDC_Adapter: Transferencia fallida");
        require(usdtReal.transfer(msg.sender, _monto), "USDC_Adapter: Canje fallido");
    }

    // Recuperar USDC sobrantes (solo dueño)
    function retirarUSDC(address _destino, uint256 _monto) external onlyOwner{
        usdtReal.transfer(_destino, _monto);
    }
}