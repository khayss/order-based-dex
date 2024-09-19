import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const initialOwnerAddress = "";

const TestERC20Module = buildModule("TestERC20Module", (m) => {
  const ownerArg = m.getParameter("_initialOwner", initialOwnerAddress);

  const testERC20 = m.contract("TestERC20", [ownerArg]);

  return {
    testERC20,
  };
});

export default TestERC20Module;
