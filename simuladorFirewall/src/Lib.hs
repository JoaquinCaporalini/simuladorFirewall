module Lib
    ( intToIp, showIp, subnetCount, h, miIp
    ) where

import AST
import Data.Bits
import Data.Word

someFunc :: IO ()
someFunc = putStrLn "someFunc"

intToIp' :: [Word32] -> Word32
intToIp' [] = zeroBits
intToIp' (x:xs) = x .|. (shift (intToIp' xs) 8)

intToIp :: [Word32] -> Ip
intToIp x = Ip (intToIp' (reverse x)) 0

subnetCount' :: Word32 -> Int -> Int -> Int
subnetCount' ip 0 32 = 0
subnetCount' ip stop count | not (testBit ip count) = subnetCount' ip (stop - 1) (count + 1)
                           | True                   = stop

subnetCount :: Ip -> Ip
subnetCount (Ip ip _) = Ip ip $ subnetCount' ip 32 0

showIp (Ip ip subnet) | 0 == subnet = show ip
                      | True        = do {show ip;  show "/"; show subnet}

miIp = [45, 230, 60, 0] -- miIp 0010 1101 1110 0110 0011 1100 0000 0000

h = testBit ((\(Ip x _) -> x) (intToIp [45, 230, 60,0])) 24
