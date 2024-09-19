import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const OrderBookDexModule = buildModule("OrderBookDexModule", (m) => {
  const orderBookDex = m.contract("OrderBookDex");

  return {
    orderBookDex,
  };
});

export default OrderBookDexModule;
