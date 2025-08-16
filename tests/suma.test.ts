import { suma } from "../src/suma";

test("suma de 2 + 3 = 5", () => {
  expect(suma(2, 3)).toBe(5);
});
