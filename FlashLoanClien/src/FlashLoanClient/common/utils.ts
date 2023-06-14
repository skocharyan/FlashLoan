import { utils } from "ethers";

export function isEthereumAddress(address: string): boolean {
  return utils.isAddress(address);
}

export function isPathCorrect(paths: string[][]): boolean {
  // Path length should be 2 or 3
  if (paths.length > 3 || paths.length < 2) {
    return false;
  }

  // Check if the all element of paths contains valid addresses
  const flattedPaths = paths.flat();
  for (const address of flattedPaths) {
    if (!isEthereumAddress(address)) return false;
  }

  // Check if the first element of equal to to the lase element of selling path.
  if (paths.length == 2 && paths[0][paths[0].length - 1] != paths[1][0]) {
    return false;
  }

  if (paths.length == 3) {
    const firstSwap = paths[0][paths[0].length - 1] === paths[1][0];
    // Check if the the last element of  intermediate path is equal to the first element of selling path
    const secondSwap = paths[1][paths[1].length - 1] == paths[2][0];

    return firstSwap && secondSwap;
  }
  return true;
}
