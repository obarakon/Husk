module Builtins (bins, cmd, commands) where

import Expr

-- Utilities for writing types
[x,y,z,u,v,w,n,m] = map (TVar . pure) "xyzuvwnm"

num :: Type
num = TConc TNum

chr :: Type
chr = TConc TChar

lst :: Type -> Type
lst = TList

tup :: Type -> Type -> Type
tup = TPair

con :: Type -> TClass
con = Concrete

vec :: Type -> Type -> Type -> Type -> TClass
vec = Vect

vec2 :: Type -> Type -> Type -> Type -> Type -> Type -> TClass
vec2 = Vect2

forall :: String -> [TClass] -> Type -> Scheme
forall vars cons typ = Scheme (map pure vars) $ CType cons typ

simply :: Type -> Scheme
simply typ = forall "" [] typ

-- Compute command from char
cmd :: Char -> Exp [Lit Scheme]
cmd char | Just exp <- lookup char commandsList = exp
cmd char = error $ "No builtin bound to character " ++ [char]

-- List of commands
commands :: String
commands = map fst commandsList

-- Assoc list of commands that can occur in source
commandsList :: [(Char, Exp [Lit Scheme])]
commandsList = [
  ('+', bins "add cat"),
  ('-', bins "sub diffl del"),
  ('*', bins "mul"),
  ('/', bins "div"),
  ('÷', bins "idiv"),
  ('%', bins "mod"),
  ('_', bins "neg tolowr"),
  ('\\', bins "inv swcase"),
  (';', bins "pure"),
  (',', bins "pair"),
  (':', bins "cons snoc"),
  ('m', bins "map mapr"),
  ('z', bins "zip"),
  ('F', bins "foldl foldl1"),
  ('Ḟ', bins "foldr foldr1"),
  ('G', bins "scanl scanl1"),
  ('Ġ', bins "scanr scanr1"),
  ('f', bins "filter select"),
  ('L', bins "len nlen"),
  ('#', bins "countf count"),
  ('N', bins "nats"),
  ('!', bins "index index2"),
  ('↑', bins "take take2 takew"),
  ('↓', bins "drop drop2 dropw"),
  ('↕', bins "span"),
  ('←', bins "head fst predN predC"),
  ('→', bins "last snd succN succC"),
  ('↔', bins "swap rev"),
  ('h', bins "init"),
  ('t', bins "tail"),
  ('ƒ', bins "fix"),
  ('ω', bins "fixp fixpL"),
  ('<', bins "lt"),
  ('>', bins "gt"),
  ('≤', bins "le"),
  ('≥', bins "ge"),
  ('=', bins "eq"),
  ('≠', bins "neq"),
  ('?', bins "if if2 fif"),
  ('¬', bins "not"),
  ('|', bins "or or'"),
  ('&', bins "and and'"),
  ('S', bins "hook"),
  ('Ṡ', bins "hookf"),
  ('K', bins "const"),
  ('I', bins "id"),
  ('`', bins "flip"),
  ('Γ', bins "list listN listF listNF"),
  ('Σ', bins "sum trian concat"),
  ('Π', bins "prod fact cartes"),
  ('§', bins "fork fork2"),
  ('´', bins "argdup"),
  ('∞', bins "rep"),
  ('¡', bins "iter iterP iterL"),
  ('c', bins "chr ord"),
  ('s', bins "show"),
  ('r', bins "read"),
  ('ø', bins "empty"),
  ('€', bins "elem elem' subl"),
  ('o', bins "com com2 com3 com4"),
  ('ȯ', EAbs "x" $ EAbs "y" $ EAbs "z" $
        EOp (bins "com com2 com3 com4") (EVar "x") $
        EOp (bins "com com2 com3 com4") (EVar "y") (EVar "z")),
  ('ö', EAbs "x" $ EAbs "y" $ EAbs "z" $ EAbs "u" $
        EOp (bins "com com2 com3 com4") (EVar "x") $
        EOp (bins "com com2 com3 com4") (EVar "y") $
        EOp (bins "com com2 com3 com4") (EVar "z") (EVar "u")),
  ('†', bins "vec"),
  ('‡', bins "vec2"),
  ('O', bins "sort"),
  ('Ö', bins "sorton sortby"),
  ('▲', bins "max maxl"),
  ('▼', bins "min minl"),
  ('u', bins "nub"),
  ('ü', bins "nubon nubby"),
  ('U', bins "nubw"),
  ('w', bins "words unwords"),
  ('¶', bins "lines unlines"),
  ('p', bins "pfac"),
  ('~', bins "subs subs2"),
  ('g', bins "group"),
  ('ġ', bins "groupOn groupBy"),
  ('ḣ', bins "heads"),
  ('ṫ', bins "tails"),
  ('¦', bins "divds"),
  ('P', bins "perms"),
  ('V', bins "any"),
  ('Λ', bins "all"),
  ('T', bins "trsp trspw"),
  ('ż', bins "zip'"),
  ('ṁ', bins "cmap cmapr smap smapr"),
  ('≡', bins "congr"),
  ('¤', bins "combin"),
  ('i', bins "n2i c2i s2i"),
  ('e', bins "list2"),
  ('ė', bins "list3"),
  ('ë', bins "list4"),
  ('Ṫ', bins "table"),
  ('Ṁ', bins "rmap"),
  ('M', bins "lmap"),
  ('«', bins "mapacL"),
  ('»', bins "mapacR"),
  ('R', bins "replic replif"),
  ('a', bins "abs touppr"),
  ('±', bins "sign isdigt"),
  ('B', bins "base abase"),
  ('d', bins "base10 abas10"),
  ('ḋ', bins "base2 abase2"),
  ('D', bins "double isuppr"),
  ('½', bins "halve islowr"),
  ('^', bins "power"),
  ('□', bins "square isanum"),
  ('√', bins "sqrt isalph"),
  ('C', bins "cut cuts"),
  ('X', bins "slice"),
  ('Ẋ', bins "mapad2 mapad3"),
  ('J', bins "join join'"),
  ('Ṗ', bins "powset"),
  ('×', bins "mix"),
  ('£', bins "oelem oelem'"),
  ('ṗ', bins "isprime"),
  ('Q', bins "slices"),
  ('Ṙ', bins "clone clone' clones"),
  ('¢', bins "cycle"),
  ('∫', bins "cumsum"),
  ('⌈', bins "ceil"),
  ('⌊', bins "floor"),
  ('⌋', bins "gcd"),
  ('⌉', bins "lcm"),
  ('ε', bins "small")
  ]

-- Compute builtins from space-delimited list
bins :: String -> Exp [Lit Scheme]
bins names = ELit $ map getBuiltin $ words names
  where getBuiltin "vec" = Vec $ forall "xyuv" [vec x y u v] $ (x ~> y) ~> (u ~> v)
        getBuiltin "vec2" = Vec2 False $ forall "xyzuvw" [vec2 x y z u v w] $ (x ~> y ~> z) ~> (u ~> v ~> w)
        getBuiltin "vec2'" = Vec2 True $ forall "xuvw" [vec2 x x x u v w] $ (x ~> x ~> x) ~> (u ~> v ~> w)
        getBuiltin name | Just typ <- lookup name builtinsList = Builtin name typ
        getBuiltin name = error $ "No builtin named " ++ name

-- Assoc list of builtins
builtinsList :: [(String, Scheme)]
builtinsList = [

  ("intseq", simply $ chr ~> lst num),

  -- Arithmetic
  ("add",   simply $ num ~> num ~> num),
  ("sub",   simply $ num ~> num ~> num),
  ("mul",   simply $ num ~> num ~> num),
  ("div",   simply $ num ~> num ~> num),
  ("idiv",  simply $ num ~> num ~> num),
  ("mod",   simply $ num ~> num ~> num),
  ("neg",   simply $ num ~> num),
  ("inv",   simply $ num ~> num),
  ("trian", simply $ num ~> num),
  ("fact",  simply $ num ~> num),
  ("predN", simply $ num ~> num),
  ("succN", simply $ num ~> num),
  ("pfac",  simply $ num ~> lst num),
  ("divds", simply $ num ~> num ~> num),
  ("sign",  simply $ num ~> num),
  ("abs",   simply $ num ~> num),
  ("base",  simply $ num ~> num ~> lst num),
  ("base2", simply $ num ~> lst num),
  ("base10",simply $ num ~> lst num),
  ("abase", simply $ num ~> lst num ~> num),
  ("abase2",simply $ lst num ~> num),
  ("abas10",simply $ lst num ~> num),
  ("double",simply $ num ~> num),
  ("halve", simply $ num ~> num),
  ("power", simply $ num ~> num ~> num),
  ("square",simply $ num ~> num),
  ("sqrt",  simply $ num ~> num),
  ("isprime",simply$ num ~> num),
  ("ceil",  simply $ num ~> num),
  ("floor", simply $ num ~> num),
  ("gcd",   simply $ num ~> num ~> num),
  ("lcm",   simply $ num ~> num ~> num),
  ("small", simply $ num ~> num),

  -- List and pair manipulation
  ("empty", forall "x" [] $ lst x),
  ("pure",  forall "x" [] $ x ~> lst x),
  ("pair",  forall "xy" [] $ x ~> y ~> tup x y),
  ("swap",  forall "xy" [] $ tup x y ~> tup y x),
  ("cons",  forall "x" [] $ x ~> lst x ~> lst x),
  ("cat",   forall "x" [] $ lst x ~> lst x ~> lst x),
  ("snoc",  forall "x" [] $ lst x ~> x ~> lst x),
  ("len",   forall "x" [] $ lst x ~> num),
  ("nlen",  simply $ num ~> num),
  ("countf",forall "xy" [con y] $ (x ~> y) ~> lst x ~> num),
  ("count", forall "x" [con x] $ x ~> lst x ~> num),
  ("head",  forall "x" [] $ lst x ~> x),
  ("last",  forall "x" [] $ lst x ~> x),
  ("init",  forall "x" [] $ lst x ~> lst x),
  ("tail",  forall "x" [] $ lst x ~> lst x),
  ("fst",   forall "xy" [] $ tup x y ~> x),
  ("snd",   forall "xy" [] $ tup x y ~> y),
  ("indexC",forall "x" [con x] $ num ~> lst x ~> x),
  ("indexC2",forall "x" [con x] $ lst x ~> num ~> x),
  ("index", forall "x" [] $ num ~> lst x ~> x),
  ("index2",forall "x" [] $ lst x ~> num ~> x),
  ("take",  forall "x" [] $ num ~> lst x ~> lst x),
  ("take2",  forall "x" [] $ lst x ~> num ~> lst x),
  ("takew", forall "xy" [con y] $ (x ~> y) ~> lst x ~> lst x),
  ("drop",  forall "x" [] $ num ~> lst x ~> lst x),
  ("drop2",  forall "x" [] $ lst x ~> num ~> lst x),
  ("dropw", forall "xy" [con y] $ (x ~> y) ~> lst x ~> lst x),
  ("span",  forall "xy" [con y] $ (x ~> y) ~> lst x ~> tup (lst x) (lst x)),
  ("rev",   forall "x" [] $ lst x ~> lst x),
  ("heads", forall "x" [con x] $ x ~> lst x),
  ("tails", forall "x" [con x] $ x ~> lst x),
  ("nats",  simply $ lst num),
  ("concat",forall "x" [] $ lst (lst x) ~> lst x),
  ("sum",   simply $ lst num ~> num),
  ("prod",  simply $ lst num ~> num),
  ("cartes",forall "x" [] $ lst (lst x) ~> lst (lst x)),
  ("elem",  forall "x" [con x] $ lst x ~> x ~> num),
  ("elem'",  forall "x" [con x] $ x ~> lst x ~> num),
  ("sort",  forall "x" [con x] $ lst x ~> lst x),
  ("sorton",forall "xy" [con y] $ (x ~> y) ~> lst x ~> lst x),
  ("sortby",forall "x" [] $ (x ~> x ~> num) ~> lst x ~> lst x),
  ("maxl",  forall "x" [con x] $ lst x ~> x),
  ("minl",  forall "x" [con x] $ lst x ~> x),
  ("diffl", forall "x" [con x] $ lst x ~> lst x ~> lst x),
  ("del",   forall "x" [con x] $ x ~> lst x ~> lst x),
  ("nub",   forall "x" [con x] $ lst x ~> lst x),
  ("nubon", forall "xy" [con y] $ (x ~> y) ~> lst x ~> lst x),
  ("nubby", forall "xy" [con y] $ (x ~> x ~> y) ~> lst x ~> lst x),
  ("nubw",  forall "x" [con x] $ lst x ~> lst x),
  ("subs",  forall "x" [con x] $ x ~> x ~> lst x ~> lst x),
  ("subs2", forall "x" [con x] $ lst x ~> lst x ~> lst x ~> lst x),
  ("group", forall "x" [con x] $ lst x ~> lst (lst x)),
  ("groupOn",forall "xy" [con y] $ (x ~> y) ~> lst x ~> lst (lst x)),
  ("groupBy",forall "xy" [con y] $ (x ~> x ~> y) ~> lst x ~> lst (lst y)), 
  ("perms", forall "x" [] $ lst x ~> lst (lst x)),
  ("trsp",  forall "x" [] $ lst (lst x) ~> lst (lst x)),
  ("trspw", forall "x" [] $ x ~> lst (lst x) ~> lst (lst x)),
  ("list2", forall "x" [] $ x ~> x ~> lst x),
  ("list3", forall "x" [] $ x ~> x ~> x ~> lst x),
  ("list4", forall "x" [] $ x ~> x ~> x ~> x ~> lst x),
  ("replic",forall "x" [] $ num ~> x ~> lst x),
  ("replif",forall "x" [] $ x ~> num ~> lst x),
  ("cuts",  forall "x" [] $ lst num ~> lst x ~> lst (lst x)),
  ("cut",   forall "x" [] $ num ~> lst x ~> lst (lst x)),
  ("slice", forall "x" [] $ num ~> lst x ~> lst (lst x)),
  ("join",  forall "x" [] $ lst x ~> lst (lst x) ~> lst x),
  ("join'", forall "x" [] $ x ~> lst (lst x) ~> lst x),
  ("powset",forall "x" [] $ lst x ~> lst (lst x)),
  ("oelem", forall "x" [con x] $ lst x ~> x ~> num),
  ("oelem'",forall "x" [con x] $ x ~> lst x ~> num),
  ("slices",forall "x" [] $ lst x ~> lst (lst x)),
  ("clone", forall "x" [] $ num ~> lst x ~> lst x),
  ("clone'",forall "x" [] $ lst x ~> num ~> lst x),
  ("clones",forall "x" [] $ lst num ~> lst x ~> lst x),
  ("cycle", forall "x" [] $ lst x ~> lst x),
  ("cumsum",simply $ lst num ~> lst num),

  -- Higher order functions
  ("map",   forall "xy" [] $ (x ~> y) ~> (lst x ~> lst y)),
  ("mapr",  forall "xy" [] $ lst (x ~> y) ~> x ~> lst y),
  ("zip",   forall "xyz" [] $ (x ~> y ~> z) ~> (lst x ~> lst y ~> lst z)),
  ("fixp",  forall "x" [con x] $ (x ~> x) ~> x ~> x),
  ("fixpL", forall "x" [con x] $ (x ~> lst x) ~> x ~> lst x),
  ("filter",forall "xy" [con y] $ (x ~> y) ~> lst x ~> lst x),
  ("select",forall "xy" [con x] $ lst x ~> lst y ~> lst y),
  ("foldl", forall "xy" [] $ (y ~> x ~> y) ~> y ~> lst x ~> y),
  ("foldl1",forall "x" [] $ (x ~> x ~> x) ~> lst x ~> x),
  ("foldr", forall "xy" [] $ (x ~> y ~> y) ~> y ~> lst x ~> y),
  ("foldr1",forall "x" [] $ (x ~> x ~> x) ~> lst x ~> x),
  ("scanl", forall "xy" [] $ (y ~> x ~> y) ~> y ~> lst x ~> lst y),
  ("scanl1",forall "x" [] $ (x ~> x ~> x) ~> lst x ~> lst x),
  ("scanr", forall "xy" [] $ (x ~> y ~> y) ~> y ~> lst x ~> lst y),
  ("scanr1",forall "x" [] $ (x ~> x ~> x) ~> lst x ~> lst x),
  ("list",  forall "xy" [] $ y ~> (x ~> lst x ~> y) ~> lst x ~> y),
  ("listN", forall "xy" [] $ (x ~> lst x ~> y) ~> lst x ~> y),
  ("listF", forall "xy" [] $ y ~> ((lst x ~> y) ~> (x ~> lst x ~> y)) ~> lst x ~> y),
  ("listNF",forall "xy" [] $ ((lst x ~> y) ~> (x ~> lst x ~> y)) ~> lst x ~> y),
  ("iter",  forall "x" [] $ (x ~> x) ~> x ~> lst x),
  ("iterL", forall "x" [] $ (x ~> lst x) ~> lst x ~> lst x),
  ("iterP", forall "x" [] $ (lst x ~> x) ~> lst x ~> lst x),
  ("rep",   forall "x" [] $ x ~> lst x),
  ("zip'",  forall "x" [] $ (x ~> x ~> x) ~> lst x ~> lst x ~> lst x),
  ("cmap",  forall "xy" [] $ (x ~> lst y) ~> lst x ~> lst y),
  ("smap",  forall "x" [] $ (x ~> num) ~> lst x ~> num),
  ("cmapr", forall "xy" [] $ lst (x ~> lst y) ~> x ~> lst y),
  ("smapr", forall "x" [] $ lst (x ~> num) ~> x ~> num),
  ("table", forall "xyz" [] $ (x ~> y ~> z) ~> lst x ~> lst y ~> lst (lst z)),
  ("rmap",  forall "xyz" [] $ (x ~> y ~> z) ~> x ~> lst y ~> lst z),
  ("lmap",  forall "xyz" [] $ (x ~> y ~> z) ~> lst x ~> y ~> lst z),
  ("mapacL",forall "xyz" [] $ (x ~> y ~> x) ~> (x ~> y ~> z) ~> x ~> lst y ~> lst z),
  ("mapacR",forall "xyz" [] $ (y ~> x ~> x) ~> (y ~> x ~> z) ~> x ~> lst y ~> lst z),
  ("mapad2",forall "xy" [] $ (x ~> x ~> y) ~> lst x ~> lst y),
  ("mapad3",forall "xy" [] $ (x ~> x ~> x ~> y) ~> lst x ~> lst y),
  ("mix",   forall "xyz" [] $ (x ~> y ~> z) ~> lst x ~> lst y ~> lst z),
  
  -- Combinators
  ("hook",  forall "xyz" [] $ (x ~> y ~> z) ~> (x ~> y) ~> x ~> z),
  ("hookf", forall "xyz" [] $ (x ~> y ~> z) ~> (y ~> x) ~> y ~> z),
  ("const", forall "xy" [] $ x ~> y ~> x),
  ("id",    forall "x" [] $ x ~> x),
  ("fix",   forall "x" [] $ (x ~> x) ~> x),
  ("flip",  forall "xyz" [] $ (x ~> y ~> z) ~> (y ~> x ~> z)),
  ("com4",  forall "xyzuvw" [] $ (v ~> w) ~> (x ~> y ~> z ~> u ~> v) ~> (x ~> y ~> z ~> u ~> w)),
  ("com3",  forall "xyzuv" [] $ (u ~> v) ~> (x ~> y ~> z ~> u) ~> (x ~> y ~> z ~> v)),
  ("com2",  forall "xyzu" [] $ (z ~> u) ~> (x ~> y ~> z) ~> (x ~> y ~> u)),
  ("com",   forall "xyz" [] $ (y ~> z) ~> (x ~> y) ~> (x ~> z)),
  ("app",   forall "xy" [] $ (x ~> y) ~> x ~> y),
  ("fork",  forall "xyzu" [] $ (x ~> y ~> z) ~> (u ~> x) ~> (u ~> y) ~> u ~> z),
  ("fork2", forall "xyzuv" [] $ (x ~> y ~> z) ~> (u ~> v ~> x) ~> (u ~> v ~> y) ~> u ~> v ~> z),
  ("argdup",forall "xy" [] $ (x ~> x ~> y) ~> x ~> y),
  ("combin",forall "xyz" [] $ (y ~> y ~> z) ~> (x ~> y) ~> (x ~> x ~> z)),

  -- Boolean functions and comparisons
  ("lt",    forall "x" [con x] $ x ~> x ~> num),
  ("gt",    forall "x" [con x] $ x ~> x ~> num),
  ("le",    forall "x" [con x] $ x ~> x ~> num),
  ("ge",    forall "x" [con x] $ x ~> x ~> num),
  ("eq",    forall "x" [con x] $ x ~> x ~> num),
  ("neq",   forall "x" [con x] $ x ~> x ~> num),
  ("if",    forall "xy" [con x] $ y ~> y ~> x ~> y),
  ("if2",   forall "xy" [con x] $ (x ~> y) ~> y ~> x ~> y),
  ("fif",   forall "xyz" [con x] $ (z ~> y) ~> (z ~> y) ~> (z ~> x) ~> z ~> y),
  ("not",   forall "x" [con x] $ x ~> num),
  ("fnot",  forall "xy" [con y] $ (x ~> y) ~> (x ~> num)),
  ("or",    forall "x" [con x] $ x ~> x ~> x),
  ("or'",   forall "x" [con x, con y] $ x ~> y ~> num),
  ("and",   forall "x" [con x] $ x ~> x ~> x),
  ("and'",  forall "x" [con x, con y] $ x ~> y ~> num),
  ("max",   forall "x" [con x] $ x ~> x ~> x),
  ("min",   forall "x" [con x] $ x ~> x ~> x),
  ("any",   forall "xy" [con y] $ (x ~> y) ~> lst x ~> num),
  ("all",   forall "xy" [con y] $ (x ~> y) ~> lst x ~> num),
  ("subl",  forall "x" [con x] $ lst x ~> lst x ~> num),
  ("congr", forall "x" [con x] $ x ~> x ~> num),
  
  -- Chars and strings
  ("chr",   simply $ num ~> chr),
  ("ord",   simply $ chr ~> num),
  ("predC", simply $ chr ~> chr),
  ("succC", simply $ chr ~> chr),
  ("show",  forall "x" [con x] $ x ~> lst chr),
  ("read",  forall "x" [con x] $ lst chr ~> x),
  ("words", simply $ lst chr ~> lst (lst chr)),
  ("unwords", simply $ lst (lst chr) ~> lst chr),
  ("lines", simply $ lst chr ~> lst (lst chr)),
  ("unlines", simply $ lst (lst chr) ~> lst chr),
  ("isanum",simply $ chr ~> num),
  ("isalph",simply $ chr ~> num),
  ("isuppr",simply $ chr ~> num),
  ("islowr",simply $ chr ~> num),
  ("isdigt",simply $ chr ~> num),
  ("touppr",simply $ chr ~> chr),
  ("tolowr",simply $ chr ~> chr),
  ("swcase",simply $ chr ~> chr),
  
  -- Type conversions
  ("n2i",   simply $ num ~> num),
  ("c2i",   simply $ chr ~> num),
  ("s2i",   simply $ lst chr ~> num)
  ]
