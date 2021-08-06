import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Char "mo:base/Char";
import Nat8 "mo:base/Nat8";
import Nat "mo:base/Nat";
import Int "mo:base/Int";

actor base32 {
  let RFC4648_ALPHABET: [Nat8]= [65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 50, 51, 52, 53, 54, 55]; // b"ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
  let CROCKFORD_ALPHABET: [Nat8] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70, 71, 72, 74, 75, 77, 78, 80, 81, 82, 83, 84, 86, 87, 88, 89, 90]; // b"0123456789ABCDEFGHJKMNPQRSTVWXYZ"
  let RFC4648_INV_ALPHABET: [Int8] = [-1, -1, 26, 27, 28, 29, 30, 31, -1, -1, -1, -1, -1, 0, -1, -1, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25];
  let CROCKFORD_INV_ALPHABET: [Int8] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, -1, -1, -1, -1, -1, -1, -1, 10, 11, 12, 13, 14, 15, 16, 17, 1, 18, 19, 1, 20, 21, 0, 22, 23, 24, 25, 26, -1, 27, 28, 29, 30, 31];


  type Alphabet = {
    #RFC4648: { padding: Bool; };
    #Crockford;
  };

  /// Convert bytes array to ascii string.       
  /// E.g `[48,65]` to "0A"
  public func ascii_encode() : async Char {
      return Char.fromNat32(48);
  };

    public func char() : async Char {
      return 'a';
  };
// Char 是 Nat32 类型，自带 ascii 编码，即 Char 'a' = 97; char 'A' = 65;
  public func ascii_decode() : async Nat32 {
      return Char.toNat32('A');
  };

//("44")
  public func nat_to_text() : async Text {
      return Nat.toText(44);
  };

  public func int_to_text() : async Text {
      return Int.toText(-44);
  };




//   /// "99" -> 153
//   func ascii_decode(t: Text) : [Nat8] {
//     var map = HashMap.HashMap<Nat, Nat8>(1, Nat.equal, Hash.hash);
//     // '0': 48 -> 0; '9': 57 -> 9
//     for (num in Iter.range(48, 57)) {
//         map.put(num, Nat8.fromNat(num-48));
//     };
//     // 'a': 97 -> 10; 'f': 102 -> 15
//     for (lowcase in Iter.range(97, 102)) {
//         map.put(lowcase, Nat8.fromNat(lowcase-97+10));
//     };
//     // 'A': 65 -> 10; 'F': 70 -> 15
//     for (uppercase in Iter.range(65, 70)) {
//         map.put(uppercase, Nat8.fromNat(uppercase-65+10));
//     };
//     var res : [Nat8] = [];

//     let p = Iter.toArray(Iter.map(Text.toIter(t), func (x: Char) : Nat { Nat32.toNat(Char.toNat32(x)) }));    
//     for i in Iter.range(0, p.size()-1) {
//       let a = Option.unwrap(map.get(p[i*2]));
//       let b = Option.unwrap(map.get(p[i*2 + 1]));
//       let c = 16*a + b;
//       res := Array.append(res, Array.make(c));
//     };
//     return res;
//   };







  public func encode(alphabet: Alphabet, data: [Nat8]) : async Text {
    let (alpha, padding) = switch alphabet {
      case (#RFC4648 { padding }) { (RFC4648_ALPHABET, padding); };
      case (#Crockford) { (CROCKFORD_ALPHABET, false); };
    };
    let len =(data.size() + 3)/4*5;
    var ret : [var Nat8] = [var];
    for (i in Iter.range(0, data.size()/5)) {
      let buf = Array.init<Nat8>(5, 0);
      // if (i != data.size()/5);
      for (j in Iter.range(0, 4)) {
        buf[j] := data[5*i+j]
      };
      ret := Array.thaw(Array.append(Array.freeze(ret), [alpha[Nat8.toNat((buf[0] & 0xF8) >> 3)]]));
      ret := Array.thaw(Array.append(Array.freeze(ret), [alpha[Nat8.toNat(((buf[0] & 0x07) << 2) | ((buf[1] & 0xC0) >> 6))]]));
      ret := Array.thaw(Array.append(Array.freeze(ret), [alpha[Nat8.toNat((buf[1] & 0x3E) >> 1)]]));
      ret := Array.thaw(Array.append(Array.freeze(ret), [alpha[Nat8.toNat(((buf[1] & 0x01) << 4) | ((buf[2] & 0xF0) >> 4))]]));
      ret := Array.thaw(Array.append(Array.freeze(ret), [alpha[Nat8.toNat(((buf[2] & 0x0F) << 1) | (buf[3] >> 7))]]));
      ret := Array.thaw(Array.append(Array.freeze(ret), [alpha[Nat8.toNat((buf[3] & 0x7C) >> 2)]]));
      ret := Array.thaw(Array.append(Array.freeze(ret), [alpha[Nat8.toNat(((buf[3] & 0x03) << 3) | ((buf[4] & 0xE0) >> 5))]]));
      ret := Array.thaw(Array.append(Array.freeze(ret), [alpha[Nat8.toNat(buf[4] & 0x1F)]]));
    };
    if ((data.size() % 5) != 0) {
      let len = ret.size();
      let num_extra  = 8 - ((data.size() % 5 * 8 + 4) / 5);
      if padding {
        for (i in Iter.range(1, num_extra)) {
          ret[len - i] := 61; // b'='
        };
      } else {
        let len_ret = len - num_extra;
      };
    };
    return "";
  };

//   public func decode(alphabet: Alphabet, data: Text) : ?[Nat8] {

//   };
}
