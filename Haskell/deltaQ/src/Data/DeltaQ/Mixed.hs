{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE TypeSynonymInstances       #-}

module Data.DeltaQ.Mixed
    ( Q (..)
    , Mixed (..)
    , uniformMixed
    , meanMixed
    ) where

import           Data.DeltaQ.Core
import           Data.DeltaQ.Probability
import           Data.Maybe              (fromJust)
import qualified Data.Polynomial         as P

newtype Q = Q {getQ :: Rational}
    deriving (Eq, Ord, Num, Fractional, Real)

instance Show Q where
    show = show . getQ

instance Semigroup Q where
    Q x <> Q y = Q $ x + y

instance Monoid Q where
    mempty = Q 0

instance Time Q where

    fromTime = fromRational . getQ

    diff (Q m) (Q n)
        | m >= n    = Just $ Q $ m - n
        | otherwise = Nothing

newtype Mixed = Mixed {getMixed :: P.Mixed Rational}
    deriving (Show, Eq, Ord)

instance Semigroup Mixed where
    Mixed x <> Mixed y = Mixed $ x * y

instance Monoid Mixed where
    mempty = Mixed 1

instance DeltaQ Rational Q Mixed where

    massive (Mixed x) = do
        x' <- P.massive x
        return (prob $ P.mass x, Mixed x')

    exact (Finite (Q t)) = Mixed $ P.exactMixed t
    exact Infinity       = Mixed 0

    mix p (Mixed x) (Mixed y) =
        let px = getProb p
            py = 1 - px
        in Mixed $ P.scale px x + P.scale py y

    before (Mixed x) (Mixed y) =
        let b = P.before x y
        in  case P.mass b of
                0 -> Nothing
                m -> Just ( prob m
                          , Mixed $ fromJust $ P.massive b
                          , Mixed $ fromJust $ P.massive $ P.residual x y
                          )

    after (Mixed x) (Mixed y) = Mixed <$> P.massive (P.after x y)

uniformMixed :: Rational -> Rational -> Mixed
uniformMixed a b
    | a < b     = Mixed $ P.uniformMixed a b
    | a > b     = never
    | otherwise = exact $ Finite $ Q a

meanMixed :: Mixed -> Ext Q
meanMixed (Mixed x) = case P.mean x of
    Nothing -> Infinity
    Just t  -> Finite $ Q t
