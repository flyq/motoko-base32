import M "mo:matchers/Matchers";
import Base32 "../src/Base32";
import S "mo:matchers/Suite";
import T "mo:matchers/Testable";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Nat8 "mo:base/Nat8";

type TestEncode = {
  alphabet: Base32.Alphabet;
  data: [Nat8];
  expect: Text;
};

type TestDecode = {
  alphabet: Base32.Alphabet;
  data: Text;
  expect: [Nat8];
};

let ParamsInit = S.suite("ParamInit", do {
  var tests : [S.Suite] = [];

  let encode_test_datas = [
    {
      alphabet = #Crockford;
      data = [0xF8, 0x3E, 0x0F, 0x83, 0xE0] : [Nat8];
      expect = "Z0Z0Z0Z0";
    },
    {
      alphabet = #Crockford;
      data = [0x07, 0xC1, 0xF0, 0x7C, 0x1F] : [Nat8];
      expect = "0Z0Z0Z0Z";
    },
    {
      alphabet = #RFC4648 {padding=true};
      data = [0xF8, 0x3E, 0x7F, 0x83, 0xE7] : [Nat8];
      expect = "7A7H7A7H";
    },
    {
      alphabet = #RFC4648 {padding=true};
      data = [0x77, 0xC1, 0xF7, 0x7C, 0x1F] : [Nat8];
      expect = "O7A7O7A7";
    },
    {
      alphabet = #RFC4648 {padding=true};
      data = [0xF8, 0x3E, 0x7F, 0x83] : [Nat8];
      expect = "7A7H7AY=";
    },
    {
      alphabet = #RFC4648 {padding=false};
      data = [0xF8, 0x3E, 0x7F, 0x83, 0xE7] : [Nat8];
      expect = "7A7H7A7H";
    },
    {
      alphabet = #RFC4648 {padding=false};
      data = [0x77, 0xC1, 0xF7, 0x7C, 0x1F] : [Nat8];
      expect = "O7A7O7A7";
    },
    {
      alphabet = #RFC4648 {padding=false};
      data = [0xF8, 0x3E, 0x7F, 0x83] : [Nat8];
      expect = "7A7H7AY";
    },                        
  ];
  let decode_test_datas = [
    {
      alphabet = #Crockford;
      data = "Z0Z0Z0Z0";
      expect = [0xF8, 0x3E, 0x0F, 0x83, 0xE0] : [Nat8];
    },
    {
      alphabet = #Crockford;
      data = "0Z0Z0Z0Z";
      expect = [0x07, 0xC1, 0xF0, 0x7C, 0x1F] : [Nat8];
    },
    {
      alphabet = #RFC4648 {padding=true};
      data = "7A7H7A7H";
      expect = [0xF8, 0x3E, 0x7F, 0x83, 0xE7] : [Nat8];
    },
    {
      alphabet = #RFC4648 {padding=true};
      data = "O7A7O7A7";
      expect = [0x77, 0xC1, 0xF7, 0x7C, 0x1F] : [Nat8];
    },
    {
      alphabet = #RFC4648 {padding=false};
      data = "7A7H7A7H";
      expect = [0xF8, 0x3E, 0x7F, 0x83, 0xE7] : [Nat8];
    },
    {
      alphabet = #RFC4648 {padding=false};
      data = "O7A7O7A7";
      expect = [0x77, 0xC1, 0xF7, 0x7C, 0x1F] : [Nat8];
    },    
  ];

  for (testD in encode_test_datas.vals()) {
    tests := Array.append(tests, [S.test("ok", Text.equal(testD.expect, Base32.encode(testD.alphabet, testD.data)), M.equals(T.bool(true)))]);
  };

  for (testD in decode_test_datas.vals()) {
    tests := Array.append(tests, [S.test("ok", Array.equal<Nat8>(testD.expect, Option.unwrap(Base32.decode(testD.alphabet, testD.data)), Nat8.equal), M.equals(T.bool(true)))]);
  };
  tests
});

let suite = S.suite("base32", [
  ParamsInit
]);

S.run(suite);
