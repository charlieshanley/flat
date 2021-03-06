{-# LANGUAGE FlexibleInstances         #-}
{-# LANGUAGE MultiParamTypeClasses     #-}
{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE PackageImports            #-}
module PkgBinary(PkgBinary(..),Binary,sd,serlN2) where

import           Test.Data
import           Types
-- import BinaryDerive
import           "binary" Data.Binary
import           "binary" Data.Binary          as Binary
import qualified Data.ByteString.Lazy as BS
import           Test.Data.Values

data PkgBinary a = PkgBinary {unPkg::a} deriving (Eq,Show)

instance Arbitrary a => Arbitrary (PkgBinary a) where arbitrary = fmap PkgBinary arbitrary

{-
instance Binary.Binary a => Serialize (PkgBinary a) where
  serialize (PkgBinary a) = Binary.encode $ a
  deserialize = either (Left . error . show) (\(_,_,v) -> Right $ PkgBinary v) . Binary.decodeOrFail
-}

name = "binary"
sd = (name,name,serializeF,deserializeF)

instance Binary a => Serialize PkgBinary a where
  serialize (PkgBinary a) = serializeF a
  deserialize = (PkgBinary <$>) . deserializeF
  pkg = PkgBinary
  unpkg (PkgBinary a) = a

serializeF = Binary.encode
deserializeF = either (Left . error . show)  (\(_,_,v) -> Right v) . Binary.decodeOrFail

-- Tests
tt = ser $ PkgBinary tree1
-- x = Prelude.putStrLn $ derive lBool -- (undefined :: Engine)

t =  ((ss1 == [128+64+16,64],ss1 == [1,1,0,1,0,0,0,0,0,1])
     ,(ss2 == [34,0,35,4,18,49,68,19,32,52,20,4,16,1,56],ss2==[0,2,0,2,0,0,0,0,0,2,0,3,0,0,0,4,0,1,0,2,0,3,0,1,0,4,0,4,0,1,0,3,0,2,0,0,0,3,0,4,0,1,0,4,0,0,0,4,0,1,0,0,0,0,0,1,0,3,1]))

ss1 = e (True,True,False,True,False,False,False,False,False,True)
ss2 = e lN2
e = BS.unpack . Binary.encode

z = (\v-> let Right (PkgBinary a) = deserialize PkgBinary.serlN2 in a == v) lN2

{- hand made to test performance, <10% gain
instance Binary N where
    put One = putWord8 0
    put Two = putWord8 1
    put Three = putWord8 2
    put Four = putWord8 3
    put Five = putWord8 4


instance Binary a => Binary (List a) where
  put (C v l) = putWord8 0 >> put v >> put l
  put N = putWord8 1
-}

instance Binary N
instance Binary a => Binary (List a)
instance Binary Car
instance Binary Acceleration
instance Binary Consumption
instance Binary CarModel
instance Binary OptionalExtra
instance Binary Engine
instance Binary Various
instance {-# OVERLAPPABLE #-} Binary a => Binary (Tree a)

-- Specialised instances
-- instance {-# OVERLAPPING #-} Binary (Tree N)
-- -- Slower
-- instance {-# OVERLAPPING #-} Binary (Tree (N,N,N))
-- instance {-# OVERLAPPING #-} Binary [N]
instance {-# OVERLAPPING #-} Binary (N,N,N)


-- !! Apparently Generics based derivation is as fast as hand written one.

{-

benchmarking serialize/deserialise/tree1
mean: 5.103695 us, lb 4.868698 us, ub 5.414622 us, ci 0.950
std dev: 1.373780 us, lb 1.141381 us, ub 1.700686 us, ci 0.950
found 18 outliers among 100 samples (18.0%)
  5 (5.0%) high mild
  13 (13.0%) high severe
variance introduced by outliers: 96.797%
variance is severely inflated by outliers

benchmarking serialize/deserialise/tree2
mean: 1.136065 us, lb 1.120947 us, ub 1.159394 us, ci 0.950
std dev: 95.01065 ns, lb 68.06466 ns, ub 137.1691 ns, ci 0.950
found 7 outliers among 100 samples (7.0%)
  3 (3.0%) high mild
  4 (4.0%) high severe
variance introduced by outliers: 72.777%
variance is severely inflated by outliers

benchmarking serialize/deserialise/car1
mean: 15.31410 us, lb 15.21677 us, ub 15.52387 us, ci 0.950
std dev: 699.8115 ns, lb 403.9063 ns, ub 1.387295 us, ci 0.950
found 4 outliers among 100 samples (4.0%)
  3 (3.0%) high mild
  1 (1.0%) high severe
variance introduced by outliers: 43.485%
variance is moderately inflated by outliers
-}


{-
benchmarking serialize/deserialise/tree1
mean: 4.551243 us, lb 4.484404 us, ub 4.680212 us, ci 0.950
std dev: 459.9530 ns, lb 260.7037 ns, ub 704.4624 ns, ci 0.950
found 9 outliers among 100 samples (9.0%)
  5 (5.0%) high mild
  4 (4.0%) high severe
variance introduced by outliers: 79.996%
variance is severely inflated by outliers

benchmarking serialize/deserialise/tree2
mean: 1.148759 us, lb 1.138991 us, ub 1.183448 us, ci 0.950
std dev: 83.66155 ns, lb 25.57640 ns, ub 190.4369 ns, ci 0.950
found 7 outliers among 100 samples (7.0%)
  4 (4.0%) high mild
  2 (2.0%) high severe
variance introduced by outliers: 66.638%
variance is severely inflated by outliers

benchmarking serialize/deserialise/car1
mean: 15.67617 us, lb 15.57603 us, ub 15.82105 us, ci 0.950
std dev: 611.6098 ns, lb 450.8581 ns, ub 853.6561 ns, ci 0.950
found 6 outliers among 100 samples (6.0%)
  3 (3.0%) high mild
  3 (3.0%) high severe
variance introduced by outliers: 35.595%
variance is moderately inflated by outliers


instance (Binary a) => Binary (Tree a) where
  put (Node a b) = putWord8 0 >> put a >> put b
  put (Leaf a) = putWord8 1 >> put a
  get = do
    tag_ <- getWord8
    case tag_ of
      0 -> get >>= \a -> get >>= \b -> return (Node a b)
      1 -> get >>= \a -> return (Leaf a)
      _ -> fail "no decoding"

instance Binary Car where
  put (Car a b c d e f g h i j k l) = put a >> put b >> put c >> put d >> put e >> put f >> put g >> put h >> put i >> put j >> put k >> put l
  get = get >>= \a -> get >>= \b -> get >>= \c -> get >>= \d -> get >>= \e -> get >>= \f -> get >>= \g -> get >>= \h -> get >>= \i -> get >>= \j -> get >>= \k -> get >>= \l -> return (Car a b c d e f g h i j k l)

instance Binary Acceleration where
  put (Acceleration a b) = put a >> put b
  get = get >>= \a -> get >>= \b -> return (Acceleration a b)

instance Binary Consumption where
  put (Consumption a b) = put a >> put b
  get = get >>= \a -> get >>= \b -> return (Consumption a b)

instance Binary Model where
  put A = putWord8 0
  put B = putWord8 1
  put C = putWord8 2
  get = do
    tag_ <- getWord8
    case tag_ of
      0 -> return A
      1 -> return B
      2 -> return C
      _ -> fail "no decoding"

instance Binary OptionalExtra where
  put SunRoof = putWord8 0
  put SportsPack = putWord8 1
  put CruiseControl = putWord8 2
  get = do
    tag_ <- getWord8
    case tag_ of
      0 -> return SunRoof
      1 -> return SportsPack
      2 -> return CruiseControl
      _ -> fail "no decoding"

instance Binary Engine where
  put (Engine a b c d e) = put a >> put b >> put c >> put d >> put e
  get = get >>= \a -> get >>= \b -> get >>= \c -> get >>= \d -> get >>= \e -> return (Engine a b c d e)
-}

serlN2 = BS.pack [0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,0,0,0,1,0,2,0,3,0,4,1]
