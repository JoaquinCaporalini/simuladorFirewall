-- Haskell data types for the abstract syntax.
-- Generated by the BNF converter.

module AbsSimFirewall where

import Data.Bits

data Program = Prog [Function]
  deriving (Eq, Ord, Show, Read)

data Function
    = Rules [Rule]
    | Host [Inter]
    | Packages [Package]
    | Connections [Connection]
  deriving (Eq, Ord, Show, Read)

data Connection = C Ip Integer Ip Integer State
  deriving (Eq, Ord, Show, Read)

data Rule = Rul Tab Com Mat Target
  deriving (Eq, Ord, Show, Read)

data Inter = Intrface String Ip String
  deriving (Eq, Ord, Show, Read)

data Package
    = Tcp IntEstTCP Ip String Ip Integer Integer Integer Integer String
    | Udp Ip String Ip Integer Integer Integer String
    | Icmp Ip String Ip Integer Integer Integer Integer Integer Integer Integer String
  deriving (Eq, Ord, Read)

data Tab = TNat | TMan | TFil
  deriving (Eq, Ord, Show, Read)

data Com
    = CApp Cha
    | CDel Cha
    | CRep Cha Integer
    | CIns Cha Integer
    | CFlu Cha
    | CPol Target
    | CNil
  deriving (Eq, Ord, Show, Read)

data Cha = DInp | DOut | DFor | DPre | DPos
  deriving (Eq, Ord, Show, Read)

data Mat
    = MPro [Protocolo] [Pop]
    | MNPro [Protocolo] [Pop]
    | MSrc Ip
    | MDst Ip
    | MInt String
    | MOut String
    | MState State
    | MMacS String
    | MNMacS String
    | MNil
  deriving (Eq, Ord, Show, Read)

data Protocolo = PUdp | PTcp | PIcmp | PAll
  deriving (Eq, Ord, Show, Read)

data Ip
    = IpR Integer Integer Integer Integer Integer
    | IpU Integer Integer Integer Integer
  deriving (Ord, Read)

data Pop
    = ODPortS Integer
    | ONDPortS Integer
    | OSPortS Integer
    | ONSPortS Integer
    | ODPortR Integer Integer
    | ONDPortR Integer Integer
    | OSPortR Integer Integer
    | ONSPortR Integer Integer
    | OTCPFlag IntEstTCP
    | OTCPNFlag IntEstTCP
    | OICMPFlag Integer
    | OICMPNFlag Integer
    | ONil
  deriving (Eq, Ord, Show, Read)

data State = SNew | SInv | SEst | SRel
  deriving (Eq, Ord, Show, Read)

data Target = TgAccept | TgDrop | TgRegect | TgReturn | TgNill
  deriving (Eq, Ord, Show, Read)

data IntEstTCP
    = None
    | Established
    | SynSent
    | SynRecv
    | FinWait
    | TimeWait
    | Close
    | CloseWait
    | LastAck
    | Listen
  deriving (Eq, Ord, Show, Read)

instance Show Package where
  show (Tcp e src mac dst sport dport ttl us int) =
    "TCP  " ++ show e ++ " interfaz de entrada " ++ int ++
    "\n    src=" ++ show src ++ " dst=" ++ show dst ++ " sport=" ++ show sport ++ " dport=" ++ show dport ++
    "\n    srcMac: " ++ mac ++ " ttl: " ++ show ttl ++ " use: " ++ show us
  show (Udp src mac dst sport dport us int) =
    "UDP  " ++ " interfaz de entrada " ++ show int ++
    "\n    src=" ++ show src ++ " dst=" ++ show dst ++ " sport=" ++ show sport ++ " dport=" ++ show dport ++
    "\n    srcMac: " ++ mac ++ " use: " ++ show us
  show (Icmp src mac dst st sc sid dt dc did us int ) =
    "Icmp  " ++ " interfaz de entrada " ++ show int ++
    "\n    src=" ++ show src ++ " dst=" ++ show dst ++
    "\n    srcMac: " ++ mac ++ " use: " ++ show us ++ " stype=" ++ show st ++ " dtype=" ++
    show dt ++ " sid=" ++ show sid ++ " did=" ++ show did ++ " sc=" ++ show sc ++ " dc=" ++ show dc

instance Show Ip where
  show (IpR a b c d r) =
    show a ++ "." ++ show b ++ "." ++ show c ++ "." ++ show d ++ "/" ++ show r
  show (IpU a b c d) =
    show a ++ "." ++ show b ++ "." ++ show c ++ "." ++ show d

instance Eq Ip where
  (==) (IpR a1 b1 c1 d1 r1) (IpR a2 b2 c2 d2 r2) =
    a1 == a2 && b1 == b2 && c1 == c2 && c1 == c2 && d1 == d2 && r1 ==r2
  (==) (IpU a1 b1 c1 d1) (IpU a2 b2 c2 d2) =
    a1 == a2 && b1 == b2 && c1 == c2 && c1 == c2 && d1 == d2
  (==) i1@(IpU a1 b1 c1 d1) i2@(IpR a2 b2 c2 d2 r2) =
    (==) i2 i1
  (==) (IpR a2 b2 c2 d2 r2) i1@(IpU a1 b1 c1 d1) =
    if r2 == 0
    then (==) i1 (IpU a2 b2 c2 d2)
    else shiftR ip1 (32 - fromIntegral r2) == shiftR ip2 (32 - fromIntegral r2)
    where real x [] = x
          real x (y:ys) = real (shiftL x 8 .|. y) ys
          ip2 = real a1 [b2,c2,d2]
          ip1 = real a1 [b1,c1,d1]