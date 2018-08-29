{-# LANGUAGE RankNTypes #-}
module Ouroboros.Chi_Calculus.Process.Run (

    run

) where

import Prelude hiding (map)

import Control.Concurrent (forkIO)
import Control.Concurrent.MVar (MVar, putMVar, takeMVar, newEmptyMVar)
import Control.Monad (void)

import Data.Function (fix)
import Data.Functor.Identity (Identity (Identity, runIdentity))
import Data.List.FixedLength (map)

import Ouroboros.Chi_Calculus.Process (Process (..), Interpretation)

run :: Interpretation MVar Identity (IO ())
run dataInter = void . forkIO . worker

    where

    worker Stop              = return ()
    worker (Guard cond cont) = if runIdentity (dataInter cond)
                                   then worker cont
                                   else return ()
    worker (chan :<: val)    = putMVar chan (runIdentity (dataInter val))
    worker (chan :>: cont)   = takeMVar chan >>= worker . cont . Identity
    worker (prc1 :|: prc2)   = do
                                   void $ forkIO $ worker prc1
                                   void $ forkIO $ worker prc2
    worker (NewChannel cont) = newEmptyMVar >>= worker . cont
    worker (Var meaning)     = meaning
    worker (Letrec defs res) = worker (res (fix (map worker . defs)))