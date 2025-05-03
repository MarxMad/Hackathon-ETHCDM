import { ethers } from "hardhat";
import { writeFileSync } from "fs";
import { join } from "path";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Desplegando con la cuenta:", deployer.address);

  // Dirección del token MXNB en Arbitrum One
  const tokenMXNBAddress = "0x123..."; // Reemplaza con la dirección real del token MXNB

  const BecasAlimentarias = await ethers.getContractFactory("BecasAlimentarias");
  const becas = await BecasAlimentarias.deploy(tokenMXNBAddress);
  await becas.deployed();

  console.log("BecasAlimentarias desplegado en:", becas.address);

  // Guardar la dirección del contrato
  const deployedContracts = {
    42161: {
      BecasAlimentarias: {
        address: becas.address,
        abi: JSON.parse(becas.interface.formatJson()),
      },
    },
  };

  writeFileSync(
    join(__dirname, "../nextjs/contracts/deployedContracts.ts"),
    `export default ${JSON.stringify(deployedContracts, null, 2)} as const;`
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 