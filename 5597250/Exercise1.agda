--Name:       Matthew Swart
--studentnr: 5597250
module Exercise1 where

{- Instruction: Fill in all the missing definitions. In most cases,
the type signature enforces that there should be a single unique
definition that fits.

If you have any questions, don't hesitate to email me or ask in class.
-}


---------------------
------ Prelude ------
---------------------

data Bool : Set where
  True : Bool
  False : Bool

data Nat : Set where
  Zero : Nat
  Succ : Nat -> Nat

{-# BUILTIN NATURAL Nat #-}

_+_ : Nat -> Nat -> Nat
Zero + m = m
Succ k + m = Succ (k + m)


_*_ : Nat -> Nat -> Nat
Zero * n = Zero
(Succ k) * n = n + (k * n)

data List (a : Set) : Set where
  Nil : List a
  Cons : a -> List a -> List a

data Vec (a : Set) : Nat -> Set where
  Nil : Vec a 0
  Cons : {n : Nat} -> (x : a) -> (xs : Vec a n) -> Vec a (Succ n)

head : {a : Set} {n : Nat}-> Vec a (Succ n) -> a
head (Cons x xs) = x

append : {a : Set} {n m : Nat} -> Vec a n -> Vec a m -> Vec a (n + m)
append Nil ys = ys
append (Cons x xs) ys = Cons x (append xs ys)

data _==_ {a : Set} (x : a) : a -> Set where
  Refl : x == x

cong : {a b : Set} {x y : a} -> (f : a -> b) -> x == y -> f x == f y
cong f Refl = Refl

data Unit : Set where
  unit : Unit

data Empty : Set where

magic : {a : Set} -> Empty -> a
magic ()

data Pair (a b : Set) : Set where
  _,_ : a -> b -> Pair a b

data Fin : Nat -> Set where
  Fz : forall {n} -> Fin (Succ n)
  Fs : forall {n} -> Fin n -> Fin (Succ n)

data Maybe (a : Set) : Set where
  Just : a -> Maybe a
  Nothing : Maybe a

----------------------
----- Exercise 1 -----
----------------------

--Show that the Vec a n type is applicative

pure : {n : Nat} {a : Set} -> a -> Vec a n
pure {Zero} x = Nil
pure {Succ n} x = Cons x (pure x)

_<*>_ : {a b : Set} {n : Nat} -> Vec (a -> b) n -> Vec a n -> Vec b n
_<*>_ Nil Nil = Nil
_<*>_ (Cons f xs) (Cons y ys) = Cons (f y) (xs <*> ys)

vmap : {a b : Set} {n : Nat} -> (a -> b) -> Vec a n -> Vec b n
vmap f Nil = Nil
vmap f (Cons x xs) = Cons (f x) (vmap f xs)

----------------------
----- Exercise 2 -----
----------------------

-- Using the Vector definitions, define a type for matrices;
-- matrix addition; the identity matrix; and matrix transposition.

Matrix : Set -> Nat -> Nat -> Set
Matrix a n m = Vec (Vec a n) m

madd : {n m : Nat} -> Matrix Nat m n -> Matrix Nat m n -> Matrix Nat m n
madd Nil Nil = Nil
madd (Cons xs xss) (Cons ys yss) = Cons (vmap _+_  xs <*> ys) (madd xss yss)

mmul : {n m  : Nat} -> Matrix Nat m n -> Matrix Nat m n -> Matrix Nat m n
mmul Nil Nil = Nil
mmul (Cons  xs xss) (Cons ys yss) = Cons (vmap  _*_  xs <*> ys) (mmul xss yss)

-- Define the identity matrix
idMatrix : {n : Nat} -> Matrix Nat n n
idMatrix {Zero} = Nil
idMatrix {Succ _} = pure (pure 1)

headMatrix : {n m : Nat} -> {a : Set} -> Matrix a (Succ n) m -> Vec a m
headMatrix {_} {Zero} Nil = Nil
headMatrix {_} {Succ _} (Cons (Cons x xs) xss) = Cons x (headMatrix xss)

tailMatrix : {n m : Nat} -> {a : Set} -> Matrix a (Succ n) m -> Matrix a n m
tailMatrix {_} {Zero} Nil = Nil
tailMatrix {_} {Succ _} (Cons (Cons x xs) xss) = Cons xs (tailMatrix xss)

-- Define matrix transposition
transpose : {n m : Nat} {a : Set} -> Matrix a m n -> Matrix a n m
transpose {Zero} {Zero} Nil = Nil
transpose {Zero} {Succ _} Nil = pure Nil
transpose {Succ _} {Zero} (Cons Nil xs) = Nil
transpose {Succ Zero} {Succ _} (Cons (Cons x xs) Nil) = Cons  (Cons x Nil) (transpose (Cons xs Nil))
transpose {Succ (Succ _)} {Succ _} (Cons (Cons x xs) yss) = Cons (Cons x (headMatrix yss)) (transpose (Cons xs (tailMatrix yss)))



----------------------
----- Exercise 3 -----
----------------------

-- Define a few functions manipulating finite types.

-- The result of "plan {n}" should be a vector of length n storing all
-- the inhabitants of Fin n in increasing order.
-- The result of "plan {n}" should be a vector of length n storing all
-- the inhabitants of Fin n in increasing order.
plan : {n : Nat} -> Vec (Fin n) n
plan {Zero} = Nil
plan {Succ _} =  pure Fz

-- Define a forgetful map, mapping Fin to Nat
forget : {n : Nat} -> Fin n -> Nat
forget Fz = Zero
forget (Fs n) = forget n

-- There are several ways to embed Fin n in Fin (Succ n).  Try to come
-- up with one that satisfies the correctness property below (and
-- prove that it does).
embed : {n : Nat} -> Fin n -> Fin (Succ n)
embed Fz = Fs Fz
embed (Fs n) = Fs (Fs n)

correct : {n : Nat} -> (i : Fin n) -> forget i == forget (embed i)
correct Fz = Refl
correct (Fs n) = Refl

----------------------
----- Exercise 4 -----
----------------------

-- Given the following data type definition:


data Compare : Nat -> Nat -> Set where
  LessThan : forall {n} k -> Compare n (n + Succ k)
  Equal : forall {n} -> Compare n n
  GreaterThan : forall {n} k -> Compare (n + Succ k) n

-- Show that there is a 'covering function'
cmp : (n m : Nat) -> Compare n m
cmp Zero Zero = Equal
cmp (Succ n) Zero = GreaterThan n
cmp Zero (Succ m) = LessThan m
cmp (Succ n) (Succ m) with cmp n m
cmp (Succ n) (Succ .(n + Succ k)) | LessThan k = LessThan k
cmp (Succ n) (Succ .n) | Equal = Equal
cmp (Succ .(m + Succ k)) (Succ m) | GreaterThan k = GreaterThan k


-- Use the cmp function you defined above to define the absolute
-- difference between two natural numbers.
difference : (n m : Nat) -> Nat
difference Zero Zero = Zero
difference (Succ n) Zero = Succ n
difference Zero (Succ m) = Succ m
difference (Succ n) (Succ m) with cmp n m
difference (Succ n) (Succ .(n + Succ k)) | LessThan k = k
difference (Succ n) (Succ .n) | Equal = Zero
difference (Succ .(m + Succ k)) (Succ m) | GreaterThan k = k

----------------------
----- Exercise 5 -----
----------------------

-- Prove the following equalities.  You may want to define auxiliary
-- lemmas or use the notation intoduced in the lectures.

sym : {a : Set} {x y : a} -> x == y -> y == x
sym Refl = Refl

trans : {a : Set} {x y z : a} -> x == y -> y == z -> x == z
trans Refl Refl = Refl


plusZero : (n : Nat) -> (n + 0) == n
plusZero Zero = Refl
plusZero (Succ n) = cong Succ (plusZero n)

plusSucc : (n m : Nat) -> Succ (n + m) == (n + Succ m)
plusSucc Zero Zero = Refl
plusSucc Zero (Succ m) = Refl
plusSucc (Succ n) m = cong Succ (plusSucc n m)

plusCommutes : (n m : Nat) -> (n + m) == (m + n)
plusCommutes Zero Zero = Refl
plusCommutes Zero (Succ m) = cong Succ (plusCommutes Zero m)
plusCommutes n Zero = plusZero n
plusCommutes n (Succ m) = trans (sym (plusSucc n m)) (cong Succ (plusCommutes n m))

assoc' : (n m k : Nat) -> ((n + m) + k) == (n + (m + k))
assoc' Zero m k = Refl
assoc' (Succ n) m k = cong Succ (assoc' n m k)

assoc : (n m k : Nat) -> (n + (m + k)) == ((n + m) + k)
assoc Zero m k = Refl
assoc (Succ n) m k = cong Succ (assoc n m k)

infixr 2 _⟨_⟩_
_⟨_⟩_ : (x : Nat) -> {y z : Nat} -> (x == y) -> (y == z) -> x == z
x ⟨ p ⟩ q = trans p q

_■ : (x : Nat) -> x == x
_■ x = Refl


distributivity : (n m k : Nat) -> (n * (m + k)) == ((n * m) + (n * k))
distributivity Zero Zero k = Refl
distributivity Zero (Succ m) Zero = Refl
distributivity Zero (Succ m) (Succ k) = Refl
distributivity (Succ n) m k = Succ n * (m + k) 
                                           ⟨ cong (_+_ (m + k)) (distributivity n m k) ⟩
                                             (m + k) + ((n * m) + (n * k))
                                           ⟨ cong (λ x → x) (assoc (m + k) (n * m) (n * k)) ⟩
                                             ((m + k) + (n * m)) + (n * k)
                                           ⟨ cong (λ x → (x + (n * m)) + (n * k)) (plusCommutes m k) ⟩
                                          ((k + m) + (n * m)) + (n * k)
                                            ⟨ cong (λ x → x + (n * k)) (assoc' k m (n * m)) ⟩
                                           (k + (m + (n * m))) + (n * k)
                                          ⟨ cong (λ x → x + (n * k)) (plusCommutes k (m + (n * m))) ⟩
                                            ((m + (n * m)) + k) + (n * k)
                                          ⟨ cong (λ x → x) (assoc' (m + (n * m)) k (n * k)) ⟩ 
                                            (m + (n * m)) + (k + (n * k)) ⟨ Refl ⟩ ((Succ n * m) + (Succ n * k)) ■

----------------------
----- Exercise 6 -----
----------------------

-- Prove that the sublist relation defined below is transitive and reflexive.
data SubList {a : Set} : List a -> List a -> Set where
  Base : SubList Nil Nil
  Keep : forall {x xs ys} -> SubList xs ys -> SubList (Cons x xs) (Cons x ys)
  Drop : forall {y zs ys} -> SubList zs ys -> SubList zs (Cons y ys)

SubListRefl : {a : Set} {xs : List a} -> SubList xs xs
SubListRefl {_} {Nil} = Base
SubListRefl {_} {Cons x xs} = Keep SubListRefl

SubListTrans : {a : Set} {xs ys zs : List a} -> SubList xs ys -> SubList ys zs -> SubList xs zs
SubListTrans Base Base = Base
SubListTrans Base (Drop x) = Drop x
SubListTrans (Keep x) (Keep y) = Keep (SubListTrans x y)
SubListTrans (Keep x) (Drop y) = Drop (SubListTrans (Keep x) y)
SubListTrans (Drop x) (Keep y) = Drop (SubListTrans x y) --How is this correct?
SubListTrans (Drop x) (Drop y) = Drop (SubListTrans (Drop x) y)


SubListSubset : {a : Set} {x : a} {xs ys : List a} -> SubList (Cons x xs) ys -> SubList xs ys
SubListSubset l = SubListTrans (Drop SubListRefl) l

SubListEmpty : {a : Set} {x : a} {xs : List a} -> SubList (Cons x xs) xs -> Empty
SubListEmpty (Keep l) = SubListEmpty l
SubListEmpty (Drop r) = SubListEmpty (SubListSubset r)


SubListAntiSym : {a : Set} {xs ys : List a} ->  SubList xs ys -> SubList ys xs -> xs == ys
SubListAntiSym  Base Base = Refl
SubListAntiSym {_} {Cons x xs} (Keep n) (Keep m) = cong (Cons x) (SubListAntiSym n m)
SubListAntiSym {_} {Cons x xs} (Keep n) (Drop m) = cong (Cons x) (SubListAntiSym n (SubListSubset m))
SubListAntiSym {_} {Cons x xs} (Drop n) (Keep m) = cong (Cons x)  (SubListAntiSym (SubListSubset n) m)
SubListAntiSym {_} {Cons x xs} (Drop n) (Drop m) with SubListEmpty (SubListTrans n (SubListSubset m))
SubListAntiSym {a} {Cons x xs} (Drop n) (Drop m) | ()

----------------------
----- Exercise 7 -----
----------------------

-- Define the constructors of a data type
data LEQ : Nat -> Nat -> Set where
  Step : {n m : Nat} →  LEQ n  m → LEQ (Succ n) (Succ m) 
  Base : ∀ {n} → LEQ Zero n 

-- (Alternative correct definitions exist - this one is the easiest to
-- work with for the rest of this exercise)

leqRefl : (n : Nat) -> LEQ n n
leqRefl Zero = Base
leqRefl (Succ n) = Step (leqRefl n)

leqTrans : {n m k : Nat} -> LEQ n m -> LEQ m k -> LEQ n k
leqTrans (Step x) (Step y) = Step (leqTrans x y)
leqTrans Base (Step y) = Base
leqTrans Base Base = Base

leqAntiSym : {n m : Nat} -> LEQ n m -> LEQ m n -> n == m
leqAntiSym (Step x) (Step y) = cong Succ (leqAntiSym x y)
leqAntiSym Base Base = Refl

-- Given the following function:
_<=_ : Nat -> Nat -> Bool
Zero <= y = True
Succ x <= Zero = False
Succ x <= Succ y = x <= y

-- Now show that this function behaves as the LEQ data type

leq<= : {n m : Nat} -> LEQ n m -> (n <= m) == True
leq<= (Step x) = leq<= x
leq<= Base = Refl

<=leq : (n m : Nat) -> (n <= m) == True -> LEQ n m
<=leq Zero Zero Refl = Base
<=leq Zero (Succ m) Refl = Base
<=leq (Succ n) Zero ()
<=leq (Succ n) (Succ m) x = Step (<=leq n m x)

----------------------
----- Exercise 8 -----
----------------------

-- We can define negation as follows
Not : Set -> Set
Not P = P -> Empty

-- Agda's logic is *constructive*, meaning some properties you may be
-- familiar with from classical logic do not hold.

notNotP : {P : Set} -> P -> Not (Not P)
notNotP x y = y x

-- The reverse does not hold: Not (Not P) does not imply P

-- Similarly, P or Not P doesn't hold for all statements P, but we can
-- prove the statement below. It's an amusing brainteaser.

data Or (a b : Set) : Set where
  Inl : a -> Or a b
  Inr : b -> Or a b

orCase : {a b c : Set} -> (a -> c) -> (b -> c) -> Or a b -> c
orCase f g (Inl x) = f x
orCase f g (Inr x) = g x

notNotExcludedMiddle : {P : Set} -> Not (Not (Or P (Not P)))
notNotExcludedMiddle x = x (Inr (λ y → x (Inl y)))

-- There are various different axioms that can be added to a
-- constructive logic to get the more familiar classical logic.


doubleNegation = {P : Set} -> Not (Not P) -> P
excludedMiddle = {P : Set} -> Or P (Not P)
impliesToOr = {P Q : Set} -> (P -> Q) -> Or (Not P) Q
-- Let's try to prove these three statements are equivalent...  you
--  may find it helpful to replace the 'doubleNegation' and others
--  with their definition in the type signatures below.
--  This is not always easy...


step1 : doubleNegation -> excludedMiddle
step1 dn = dn notNotExcludedMiddle


step2 : excludedMiddle -> impliesToOr
step2 em {P} {Q} ito with em {P}
step2 em ito | Inl x₁ = Inr (ito x₁)
step2 em ito | Inr x₁ = Inl x₁
 

step3 : impliesToOr -> doubleNegation
step3  ito {P} h = orCase (λ z → magic (h z) ) (λ z → z) (ito (λ z → z))


-- HARDER: show that these are equivalent to Pierces law:
piercesLaw = {P Q : Set} -> ((P -> Q) -> P) -> P

step4 : excludedMiddle → piercesLaw
step4 em {P} {Q}  pl with em {P}
step4 em pl | Inl x = x
step4 em pl | Inr x = pl (λ p → magic (x p))

step5 : piercesLaw → excludedMiddle
step5 pl {P} = orCase (λ x → (λ y → Inl y) x) (λ z → z) (Inr (pl (λ z → Inr (λ x → z (Inl x)))))


----------------------
----- Exercise 9 -----
----------------------

-- Given the following data type for expressions

data Expr : Set where
  Add : Expr -> Expr -> Expr
  Val : Nat -> Expr

-- We can write a sim1ple evaluator as follows
eval : Expr -> Nat
eval (Add l r) = eval l + eval r
eval (Val x) = x

-- We can also compile such expressions to stack machine code
data Cmd : Set where
  -- stop execution and return the current stack
  HALT : Cmd
  -- push a new number on the  stack
  PUSH : Nat -> Cmd -> Cmd
  -- replace the top two elements of the stack with their sum
  ADD : Cmd -> Cmd

Stack : Set
Stack = List Nat

addExec : Nat →  Stack → Stack
addExec x Nil = Cons x Nil
addExec x (Cons y st) = Cons (x + y) st

-- Complete the following definition, executing a list of instructions
-- Note: there 'obvious' definition is not total -- how can you fix
-- things so that it is?
exec : Cmd -> Stack -> Stack
exec HALT st = st
exec (PUSH x c) st = exec c (Cons x st)
exec (ADD c) Nil = exec c Nil
exec (ADD c) (Cons x st) = exec c (addExec x st)

compile' : Expr → Cmd → Cmd
compile' (Add e1 e2) c = compile' e1 (compile' e2 c)
compile' (Val x) c = PUSH x c

-- Define a compiler from expresions to instructions
compile : Expr -> Cmd
compile e = compile' e HALT

correctness' : (e : Expr) (s : Stack) (c : Cmd)  → exec c (Cons (eval e) s) == exec (compile' e c) s
correctness' (Add e1 e2) s c = trans (correctness' {!!} {!!} {!!}) (correctness' {!!} {!!} {!!})
correctness' (Val x) s c = Refl

-- And prove your compiler correct
correctness : (e : Expr) (s : Stack) -> Cons (eval e) s == exec (compile e) s
correctness e s = correctness' e s HALT

--BONUS exercises: extend the language with new constructs for let
--bindings, variables, new operators, mutable references, assignment,
--functions, ..
