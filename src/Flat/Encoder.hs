{-# LANGUAGE CPP   ,NoMonomorphismRestriction    #-}
-- |Encoder and encoding primitives
module Flat.Encoder (
    Encoding,
    (<>),
    NumBits,
    encodersS,
    mempty,
    strictEncoder,
    eTrueF,
    eFalseF,
    eFloat,
    eDouble,
    eInteger,
    eNatural,
    eWord16,
    eWord32,
    eWord64,
    eWord8,
    eBits,
    eBits16,
    eFiller,
    eBool,
    eTrue,
    eFalse,
    eBytes,
#if! defined(ghcjs_HOST_OS) && ! defined (ETA_VERSION)
    eUTF16,
#endif
    eLazyBytes,
    eShortBytes,
    eInt,
    eInt8,
    eInt16,
    eInt32,
    eInt64,
    eWord,
    eChar,
    encodeArrayWith,
    encodeListWith,
    Size,
    arrayBits,
    sWord,
    sWord8,
    sWord16,
    sWord32,
    sWord64,
    sInt,
    sInt8,
    sInt16,
    sInt32,
    sInt64,
    sNatural,
    sInteger,
    sFloat,
    sDouble,
    sChar,
    sBytes,
    sLazyBytes,
    sShortBytes,
#ifndef ghcjs_HOST_OS
    sUTF16,
#endif
    sFillerMax,
    sBool,
    sUTF8Max,
    eUTF8,
#ifdef ETA_VERSION
    trampolineEncoding,
#endif
    ) where

import           Flat.Encoder.Prim
import           Flat.Encoder.Size(arrayBits)
import           Flat.Encoder.Strict
import           Flat.Encoder.Types

#if ! MIN_VERSION_base(4,11,0)
import           Data.Semigroup((<>))
#endif
