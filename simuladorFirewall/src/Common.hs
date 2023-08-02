module Common where

import Data.Word

import AbsSimFirewall

type Mac = String

data StatusPackege = ForCheck | Accept | Drop | Regect | Return

data Interfaz = Interfaz
    { nombre :: String
    , mac    :: Mac
    , ip     :: Ip
    }
    deriving Show

data Chain = Chain
    { input     :: [(Mat, Target)]
    , output    :: [(Mat, Target)]
    , fordware  :: [(Mat, Target)]
    , politica  :: Target
    }
    deriving Show

data Table = Table
    { filterT :: Chain
    , nat     :: Chain
    , mangle  :: Chain
    }
    deriving Show

data State = State
    { tablas    :: Table
    , packages  :: [(Package, StatusPackege)]
    , host      :: [Interfaz]
    }
-- data Options = Options { optPrint :: Bool, optAST   :: Bool , optEval  :: Int, optHelp  :: Bool} deriving Show