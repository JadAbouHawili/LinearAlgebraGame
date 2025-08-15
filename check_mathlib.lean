import Mathlib.Algebra.Module.LinearMap
import Mathlib.LinearAlgebra.Finsupp
import Mathlib.Data.Finset.Basic
import Mathlib.Algebra.BigOperators.Basic

namespace CheckMathlib

variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V]

-- Check the actual signatures of lemmas we need
#check @Finset.smul_sum
#check @Finset.sum_neg_distrib  
#check @neg_sum
#check @mul_smul
#check @smul_neg
#check @inv_mul_cancel₀
#check @add_eq_zero_iff_eq_neg
#check @neg_eq_iff_add_eq_zero

-- Check what's available for linear combinations
#check @Finset.sum

-- Let's see what linear independence looks like in current mathlib
open Submodule
#check @LinearIndependent

end CheckMathlib