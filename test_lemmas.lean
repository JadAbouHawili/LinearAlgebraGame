import Game.Levels.LinearIndependenceSpanWorld.Level08

namespace Test

open VectorSpace Finset

variable (K V : Type) [Field K] [AddCommGroup V] [VectorSpace K V]

-- Test what lemmas are available
#check @mul_smul
#check @smul_neg
#check @neg_smul
#check @smul_sum
#check @inv_mul_cancel₀
#check @one_smul
#check @add_eq_zero_iff_eq_neg

end Test