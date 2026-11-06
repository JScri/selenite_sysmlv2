"""Wave 4A: selenite.scenarios.criteria (an extension with no golden).

Three alternatives x five samples, every expected number worked by hand:

    A = [1, 2, 3, 4, 5]   mean 3, P10 1.4, P90 4.6
    B = [2, 2, 2, 2, 2]   mean 2
    C = [5, 4, 3, 2, 1]   mean 3, P10 1.4, P90 4.6

Feasibility used by the chance constraint:

    A = [T, T, T, T, T]  P = 1.0
    B = [T, T, F, F, F]  P = 0.4
    C = [T, T, T, T, F]  P = 0.8
"""
import math

import numpy as np
import pytest

from selenite.scenarios import criteria as cr
from selenite.scenarios.criteria import (
    CRITERIA, Recommendation, choose_chance_constrained, choose_cvar, choose_expected, choose_minimax_regret,
    choose_quantile, cvar, probability_by_year, quantile_year, recommend, regret_matrix, summarise, win_probability,
)

A = np.array([1.0, 2.0, 3.0, 4.0, 5.0])
B = np.array([2.0, 2.0, 2.0, 2.0, 2.0])
C = np.array([5.0, 4.0, 3.0, 2.0, 1.0])


def values():
    return {"A": A.copy(), "B": B.copy(), "C": C.copy()}


def feasible():
    return {
        "A": np.array([True, True, True, True, True]),
        "B": np.array([True, True, False, False, False]),
        "C": np.array([True, True, True, True, False]),
    }


def test_module_is_an_extension_with_no_golden():
    assert cr.PORTED is False
    assert "no golden" in cr.SOURCE_SCRIPT
    assert "Wave 4A extension" in cr.__doc__ and "no golden" in cr.__doc__
    assert CRITERIA == ("expectedValue", "p90", "cvar90", "minimaxRegret", "chanceConstrained")


# --------------------------------------------------------------------------
# summarise / cvar
# --------------------------------------------------------------------------


def test_summarise_hand_checked():
    s = summarise(A)
    assert s["mean"] == 3.0
    assert s["std"] == pytest.approx(math.sqrt(2.5))  # sample std, ddof = 1
    assert s["se"] == pytest.approx(math.sqrt(0.5))  # std / sqrt(5)
    assert s["p10"] == pytest.approx(1.4) and s["p50"] == 3.0 and s["p90"] == pytest.approx(4.6)
    assert s["min"] == 1.0 and s["max"] == 5.0
    assert set(s) == {"mean", "std", "se", "p10", "p50", "p90", "min", "max"}
    one = summarise([4.0])
    assert one["std"] == 0.0 and one["se"] == 0.0 and one["mean"] == 4.0
    with pytest.raises(ValueError):
        summarise([])


def test_cvar_hand_checked():
    x = np.arange(1.0, 11.0)  # 1..10: P90 = 9.1 -> upper tail {10}; P10 = 1.9 -> lower tail {1}
    assert cvar(x) == 10.0
    assert cvar(x, tail="lower") == 1.0
    assert cvar(x, alpha=0.5) == 8.0  # P50 = 5.5 -> mean of 6..10
    assert cvar(x, alpha=0.5, tail="lower") == 3.0  # mean of 1..5
    assert cvar(A) == 5.0 and cvar(A, tail="lower") == 1.0
    assert cvar(B) == 2.0 and cvar(B, tail="lower") == 2.0  # degenerate: the whole sample is the tail
    with pytest.raises(ValueError):
        cvar(x, tail="middle")
    with pytest.raises(ValueError):
        cvar(x, alpha=1.0)


# --------------------------------------------------------------------------
# Win probability and regret
# --------------------------------------------------------------------------


def test_win_probability_min_ties_split_equally():
    # per sample best (min): s0 A | s1 A=B | s2 B | s3 B=C | s4 C
    assert win_probability(values(), "min") == {"A": pytest.approx(0.3), "B": pytest.approx(0.4), "C": pytest.approx(0.3)}


def test_win_probability_max():
    # per sample best (max): s0 C | s1 C | s2 A=C | s3 A | s4 A
    assert win_probability(values(), "max") == {"A": pytest.approx(0.5), "B": 0.0, "C": pytest.approx(0.5)}


def test_win_probability_sums_to_one_and_full_ties():
    assert sum(win_probability(values(), "min").values()) == pytest.approx(1.0)
    assert win_probability({"x": [1.0, 1.0], "y": [1.0, 1.0]}, "min") == {"x": 0.5, "y": 0.5}


def test_regret_matrix_hand_checked():
    names, r = regret_matrix(values(), "min")
    assert names == ["A", "B", "C"]
    # best per sample (min): [1, 2, 2, 2, 1]
    assert np.array_equal(r, [[0, 0, 1, 2, 4], [1, 0, 0, 0, 1], [4, 2, 1, 0, 0]])
    names, r = regret_matrix(values(), "max")
    # best per sample (max): [5, 4, 3, 4, 5]
    assert np.array_equal(r, [[4, 2, 0, 0, 0], [3, 2, 1, 2, 3], [0, 0, 0, 2, 4]])


# --------------------------------------------------------------------------
# choose_* under "min"
# --------------------------------------------------------------------------


def test_choose_expected_min():
    alt, detail = choose_expected(values(), "min")
    assert alt == "B"
    assert detail["score"] == {"A": 3.0, "B": 2.0, "C": 3.0}
    assert detail["statistic"] == "mean" and detail["sense"] == "min"


def test_choose_quantile_min_is_p90():
    alt, detail = choose_quantile(values(), "min")
    assert alt == "B"
    assert detail["score"] == {"A": pytest.approx(4.6), "B": 2.0, "C": pytest.approx(4.6)}
    assert detail["statistic"] == "p90"


def test_choose_cvar_min_is_upper_tail():
    alt, detail = choose_cvar(values(), "min")
    assert alt == "B"
    assert detail["score"] == {"A": 5.0, "B": 2.0, "C": 5.0}
    assert detail["statistic"] == "cvar90_upper"


def test_choose_minimax_regret_min():
    alt, detail = choose_minimax_regret(values(), "min")
    assert alt == "B"
    assert detail["score"] == {"A": 4.0, "B": 1.0, "C": 4.0}
    assert detail["regret"]["max"] == {"A": 4.0, "B": 1.0, "C": 4.0}
    assert detail["regret"]["mean"] == {"A": pytest.approx(1.4), "B": pytest.approx(0.4), "C": pytest.approx(1.4)}
    # P90 of [0, 0, 1, 2, 4] = 2 + 0.6 * 2 = 3.2; of [0, 0, 0, 1, 1] = 1
    assert detail["regret"]["p90"] == {"A": pytest.approx(3.2), "B": 1.0, "C": pytest.approx(3.2)}


def test_choose_chance_constrained_min():
    alt, detail = choose_chance_constrained(values(), feasible(), "min")
    # qualifying at 0.8: A (1.0) and C (0.8); means 3 and 3 -> tie -> A by order
    assert alt == "A"
    assert detail["feasible_probability"] == {"A": 1.0, "B": pytest.approx(0.4), "C": pytest.approx(0.8)}
    assert detail["qualifying"] == ["A", "C"] and detail["threshold"] == 0.8
    assert detail["score"] == {"A": 3.0, "B": 2.0, "C": 3.0}
    alt, detail = choose_chance_constrained(values(), feasible(), "min", threshold=0.9)
    assert alt == "A" and detail["qualifying"] == ["A"]
    # the cheapest alternative B is excluded by its 0.4 feasibility even at a low threshold
    alt, _ = choose_chance_constrained(values(), feasible(), "min", threshold=0.5)
    assert alt == "A"
    alt, _ = choose_chance_constrained(values(), feasible(), "min", threshold=0.4)
    assert alt == "B"


def test_choose_chance_constrained_none_qualifies():
    f = feasible()
    f["A"] = np.array([True, False, False, False, False])  # P = 0.2
    alt, detail = choose_chance_constrained(values(), f, "min", threshold=0.85)
    assert alt is None
    assert detail["qualifying"] == []
    assert detail["max_feasible_probability"] == pytest.approx(0.8)  # C


def test_choose_chance_constrained_without_feasibility_is_expected_value():
    alt, detail = choose_chance_constrained(values(), None, "min")
    assert alt == "B" and detail["feasible_probability"] == {"A": 1.0, "B": 1.0, "C": 1.0}
    with pytest.raises(KeyError):
        choose_chance_constrained(values(), {"A": feasible()["A"]}, "min")


# --------------------------------------------------------------------------
# choose_* under "max"
# --------------------------------------------------------------------------


def test_choose_expected_max_ties_by_order():
    alt, detail = choose_expected(values(), "max")
    assert alt == "A"  # A and C both mean 3; A first
    assert detail["score"] == {"A": 3.0, "B": 2.0, "C": 3.0}
    reordered = {"C": C, "B": B, "A": A}
    assert choose_expected(reordered, "max")[0] == "C"


def test_choose_quantile_max_is_p10():
    alt, detail = choose_quantile(values(), "max")
    assert alt == "B"
    assert detail["score"] == {"A": pytest.approx(1.4), "B": 2.0, "C": pytest.approx(1.4)}
    assert detail["statistic"] == "p10"


def test_choose_cvar_max_is_lower_tail():
    alt, detail = choose_cvar(values(), "max")
    assert alt == "B"
    assert detail["score"] == {"A": 1.0, "B": 2.0, "C": 1.0}
    assert detail["statistic"] == "cvar90_lower"


def test_choose_minimax_regret_max():
    alt, detail = choose_minimax_regret(values(), "max")
    assert alt == "B"
    assert detail["score"] == {"A": 4.0, "B": 3.0, "C": 4.0}
    assert detail["regret"]["mean"] == {"A": pytest.approx(1.2), "B": pytest.approx(2.2), "C": pytest.approx(1.2)}


def test_choose_chance_constrained_max():
    alt, _ = choose_chance_constrained(values(), feasible(), "max")
    assert alt == "A"  # A and C tie at mean 3 among {A, C}; A first


# --------------------------------------------------------------------------
# recommend
# --------------------------------------------------------------------------


@pytest.mark.parametrize("criterion, expected", [
    ("expectedValue", "B"), ("p90", "B"), ("cvar90", "B"), ("minimaxRegret", "B"), ("chanceConstrained", "A"),
])
def test_recommend_min_carries_win_and_feasible_probability(criterion, expected):
    rec = recommend(values(), "min", feasible(), criterion)
    assert isinstance(rec, Recommendation)
    assert rec.alternative == expected and rec.criterion == criterion
    assert rec.win_probability == pytest.approx({"A": 0.3, "B": 0.4, "C": 0.3}[expected])
    assert rec.feasible_probability == pytest.approx({"A": 1.0, "B": 0.4, "C": 0.8}[expected])
    assert rec.detail["win_probability"] == {"A": pytest.approx(0.3), "B": pytest.approx(0.4), "C": pytest.approx(0.3)}
    assert rec.detail["feasible_probability"] == {"A": 1.0, "B": pytest.approx(0.4), "C": pytest.approx(0.8)}
    assert "score" in rec.detail


def test_recommend_max_without_feasibility():
    rec = recommend(values(), "max", None, "expectedValue")
    assert rec.alternative == "A" and rec.win_probability == pytest.approx(0.5) and rec.feasible_probability == 1.0
    rec = recommend(values(), "max", None, "chanceConstrained")
    assert rec.alternative == "A" and rec.detail["qualifying"] == ["A", "B", "C"]


def test_recommend_none_when_chance_constraint_fails():
    f = feasible()
    f["A"] = np.array([True, False, False, False, False])
    rec = recommend(values(), "min", f, "chanceConstrained", threshold=0.85)
    assert rec.alternative is None and rec.win_probability is None and rec.feasible_probability is None
    assert rec.detail["max_feasible_probability"] == pytest.approx(0.8)


def test_recommend_threshold_is_passed_through():
    assert recommend(values(), "min", feasible(), "chanceConstrained", threshold=0.4).alternative == "B"


def test_validation_errors():
    with pytest.raises(ValueError, match="unknown criterion"):
        recommend(values(), "min", None, "lexicographic")
    with pytest.raises(ValueError, match="sense"):
        choose_expected(values(), "minimise")
    with pytest.raises(ValueError, match="same number of samples"):
        choose_expected({"A": A, "B": B[:4]}, "min")
    with pytest.raises(ValueError, match="no alternatives"):
        win_probability({}, "min")
    with pytest.raises(ValueError, match="feasible"):
        choose_chance_constrained(values(), {"A": A > 0, "B": B > 0, "C": (C > 0)[:3]}, "min")
    with pytest.raises(ValueError, match="threshold"):
        choose_chance_constrained(values(), feasible(), "min", threshold=1.5)


# --------------------------------------------------------------------------
# Gate-year helpers
# --------------------------------------------------------------------------


def test_probability_by_year_treats_nan_and_none_as_never():
    years = [3.0, float("nan"), 5.0, None, 4.0]
    assert probability_by_year(years, 4) == pytest.approx(0.4)  # 3 and 4
    assert probability_by_year(years, 5) == pytest.approx(0.6)
    assert probability_by_year(years, 2.9) == 0.0
    assert probability_by_year(np.array([np.nan, np.nan]), 100) == 0.0
    assert probability_by_year(np.array([1.0, 2.0]), 2.0) == 1.0  # boundary inclusive
    assert math.isnan(probability_by_year([], 10))


def test_quantile_year_ignores_nan():
    years = [3.0, float("nan"), 5.0, None, 4.0]
    assert quantile_year(years, 0.5) == 4.0
    assert quantile_year(years, 0.1) == pytest.approx(3.2)
    assert np.allclose(quantile_year(years, [0.1, 0.5, 0.9]), [3.2, 4.0, 4.8])
    assert math.isnan(quantile_year([None, float("nan")], 0.5))
    assert np.isnan(quantile_year([np.nan], [0.1, 0.9])).all()
    assert math.isnan(quantile_year([], 0.5))
