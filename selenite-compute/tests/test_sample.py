"""Wave 4A: selenite.scenarios.sample (an extension with no golden).

Determinism under seed, the inverse-CDF transforms at hand-checked
uniforms, marginals inside their bounds, the triangular / PERT means
against their closed forms, discrete frequencies, constants for points and
unbound ranges, the Sobol rounding warning and the CRN hash.
"""
import math

import numpy as np
import pytest

from selenite.scenarios import sample as sm
from selenite.scenarios.sample import Dist, Samples, sample, transform

SEED = 20260920
N = 4000


def register():
    return [
        Dist("u", "uniform", 5.0, 0.0, 10.0),
        Dist("t", "triangular", 2.0, 0.0, 10.0),
        Dist("p", "pert", 2.0, 0.0, 10.0),
        Dist("l", "logNormal", 2.0, 1.0, 4.0),
        Dist("d", "discrete", 1.0, values=(1.0, 2.0, 3.0), weights=(0.2, 0.5, 0.3)),
        Dist("pt", "pointValue", 7.0),
        Dist("ub", "triangular", 3.0),  # range unbound -> constant at nominal
    ]


@pytest.fixture(scope="module")
def draw():
    return sample(register(), N, SEED)


# --------------------------------------------------------------------------
# Module contract
# --------------------------------------------------------------------------


def test_module_is_an_extension_with_no_golden():
    assert sm.PORTED is False
    assert "no golden" in sm.SOURCE_SCRIPT
    assert "Wave 4A extension" in sm.__doc__ and "no golden" in sm.__doc__
    assert sm.KINDS == ("pointValue", "uniform", "triangular", "pert", "logNormal", "discrete")
    assert sm.PERT_LAMBDA == 4.0
    assert sm.Z90 == pytest.approx(1.2815515655446004, abs=0)


def test_dist_sampled_property():
    assert Dist("a", "uniform", 1.0, 0.0, 2.0).sampled
    assert not Dist("a", "uniform", 1.0, 0.0).sampled  # high unbound
    assert not Dist("a", "triangular", 1.0, high=2.0).sampled  # low unbound
    assert not Dist("a", "pointValue", 1.0, 0.0, 2.0).sampled  # a point even with a range
    assert Dist("a", "discrete", 1.0, values=(1.0, 2.0)).sampled
    assert not Dist("a", "discrete", 1.0).sampled
    with pytest.raises(ValueError, match="unknown distribution kind"):
        Dist("a", "gaussian", 1.0, 0.0, 2.0)
    with pytest.raises(ValueError, match="weights"):
        Dist("a", "discrete", 1.0, values=(1.0, 2.0), weights=(1.0,))


# --------------------------------------------------------------------------
# Determinism and the CRN hash
# --------------------------------------------------------------------------


@pytest.mark.parametrize("method", ["lhs", "sobol"])
def test_same_seed_gives_identical_values_and_hash(method):
    a = sample(register(), 64, SEED, method)
    b = sample(register(), 64, SEED, method)
    assert a.names == b.names == ("u", "t", "p", "l", "d")
    assert a.point_names == b.point_names == ("pt", "ub")
    assert np.array_equal(a.u, b.u)
    for name in a.values:
        assert np.array_equal(a.values[name], b.values[name]), name
    assert a.hash == b.hash and len(a.hash) == 64


@pytest.mark.parametrize("method", ["lhs", "sobol"])
def test_different_seed_gives_different_values_and_hash(method):
    a = sample(register(), 64, SEED, method)
    b = sample(register(), 64, SEED + 1, method)
    assert not np.array_equal(a.u, b.u)
    for name in a.names:
        assert not np.array_equal(a.values[name], b.values[name]), name
    assert a.hash != b.hash
    # the constants do not depend on the seed
    for name in a.point_names:
        assert np.array_equal(a.values[name], b.values[name]), name


def test_hash_is_the_sha256_of_the_uniform_matrix(draw):
    import hashlib
    assert draw.hash == hashlib.sha256(draw.u.tobytes()).hexdigest()


def test_samples_fields(draw):
    assert isinstance(draw, Samples)
    assert draw.n == N and draw.seed == SEED and draw.method == "lhs"
    assert draw.d == 5 and draw.u.shape == (N, 5)
    assert np.all(draw.u > 0.0) and np.all(draw.u < 1.0)
    assert set(draw.values) == {d.name for d in register()}
    assert all(v.shape == (N,) for v in draw.values.values())
    assert draw.warning == ""


# --------------------------------------------------------------------------
# Transforms at hand-picked uniforms
# --------------------------------------------------------------------------


def test_uniform_transform_is_linear():
    d = Dist("u", "uniform", 5.0, 0.0, 10.0)
    assert np.array_equal(transform(d, [0.0, 0.5, 1.0]), [0.0, 5.0, 10.0])


def test_triangular_transform_hits_the_mode_at_c():
    # CDF at the mode is (mode - low) / (high - low) = 0.2
    d = Dist("t", "triangular", 2.0, 0.0, 10.0)
    assert transform(d, [0.0, 0.2, 1.0]) == pytest.approx([0.0, 2.0, 10.0])
    # left of the mode the ppf is low + sqrt(u c) (high - low): u = 0.05 -> sqrt(0.01) * 10 = 1
    assert transform(d, [0.05]) == pytest.approx([1.0])


def test_pert_transform_symmetric_case_and_bounds():
    # nominal mid-range: a = b = 3, median = mean = nominal
    d = Dist("p", "pert", 5.0, 0.0, 10.0)
    assert transform(d, [0.0, 0.5, 1.0]) == pytest.approx([0.0, 5.0, 10.0])


def test_lognormal_transform_median_and_p10_p90():
    # median = nominal; with nominal the geometric mean of low / high the P10 / P90 ARE low / high
    d = Dist("l", "logNormal", 2.0, 1.0, 4.0)
    assert transform(d, [0.5]) == pytest.approx([2.0])
    assert transform(d, [0.1, 0.9]) == pytest.approx([1.0, 4.0])
    # the P90 / P10 ratio is high / low whatever the median
    e = Dist("l2", "logNormal", 3.0, 1.0, 4.0)
    p10, p90 = transform(e, [0.1, 0.9])
    assert p90 / p10 == pytest.approx(4.0)
    assert transform(e, [0.5]) == pytest.approx([3.0])


def test_discrete_transform_follows_cumulative_weights():
    d = Dist("d", "discrete", 1.0, values=(1.0, 2.0, 3.0), weights=(0.2, 0.5, 0.3))
    # cumulative weights 0.2, 0.7, 1.0
    assert np.array_equal(transform(d, [0.1, 0.25, 0.9, 0.2, 0.7, 0.0]), [1.0, 2.0, 3.0, 2.0, 3.0, 1.0])
    e = Dist("e", "discrete", 1.0, values=(10.0, 20.0))  # uniform weights
    assert np.array_equal(transform(e, [0.0, 0.49, 0.5, 0.99]), [10.0, 10.0, 20.0, 20.0])


def test_point_and_unbound_transform_are_constant():
    assert np.array_equal(transform(Dist("pt", "pointValue", 7.0), [0.0, 0.3, 1.0]), [7.0, 7.0, 7.0])
    assert np.array_equal(transform(Dist("ub", "pert", 3.0, low=0.0), [0.0, 1.0]), [3.0, 3.0])


# --------------------------------------------------------------------------
# Marginals of a real draw
# --------------------------------------------------------------------------


def test_marginals_land_inside_their_bounds(draw):
    v = draw.values
    assert v["u"].min() >= 0.0 and v["u"].max() <= 10.0
    assert v["t"].min() >= 0.0 and v["t"].max() <= 10.0
    assert v["p"].min() >= 0.0 and v["p"].max() <= 10.0
    assert v["l"].min() > 0.0
    assert set(np.unique(v["d"])) <= {1.0, 2.0, 3.0}


def test_triangular_mean_within_3_se(draw):
    low, mode, high = 0.0, 2.0, 10.0
    mean = (low + mode + high) / 3.0
    var = (low ** 2 + mode ** 2 + high ** 2 - low * mode - low * high - mode * high) / 18.0
    assert abs(draw.values["t"].mean() - mean) <= 3.0 * math.sqrt(var / N)


def test_pert_mean_within_3_se(draw):
    low, mode, high = 0.0, 2.0, 10.0
    a, b = 1.0 + 4.0 * (mode - low) / (high - low), 1.0 + 4.0 * (high - mode) / (high - low)
    mean = (low + 4.0 * mode + high) / 6.0
    assert mean == pytest.approx(low + (high - low) * a / (a + b))
    var = (high - low) ** 2 * a * b / ((a + b) ** 2 * (a + b + 1.0))
    assert abs(draw.values["p"].mean() - mean) <= 3.0 * math.sqrt(var / N)


def test_uniform_mean_within_3_se(draw):
    assert abs(draw.values["u"].mean() - 5.0) <= 3.0 * math.sqrt(100.0 / 12.0 / N)


def test_lognormal_median_and_tails(draw):
    v = draw.values["l"]
    assert np.median(v) == pytest.approx(2.0, rel=0.05)
    assert np.quantile(v, 0.1) == pytest.approx(1.0, rel=0.05)
    assert np.quantile(v, 0.9) == pytest.approx(4.0, rel=0.05)


def test_discrete_frequencies(draw):
    v = draw.values["d"]
    for value, weight in zip((1.0, 2.0, 3.0), (0.2, 0.5, 0.3)):
        assert abs(np.mean(v == value) - weight) <= 0.03


def test_point_and_unbound_stay_constant(draw):
    assert np.array_equal(draw.values["pt"], np.full(N, 7.0))
    assert np.array_equal(draw.values["ub"], np.full(N, 3.0))


# --------------------------------------------------------------------------
# Sobol rounding, empty register, validation
# --------------------------------------------------------------------------


def test_sobol_rounds_up_and_warns():
    s = sample(register(), 10, SEED, "sobol")
    assert s.u.shape == (10, 5) and s.method == "sobol"
    assert "16" in s.warning and "10" in s.warning
    t = sample(register(), 16, SEED, "sobol")
    assert t.u.shape == (16, 5) and t.warning == ""
    assert np.array_equal(s.u, t.u[:10])  # the truncation keeps the leading points


def test_no_sampled_dimension_gives_empty_matrix_and_constants():
    s = sample([Dist("pt", "pointValue", 7.0), Dist("ub", "uniform", 3.0)], 5, SEED)
    assert s.u.shape == (5, 0) and s.names == () and s.d == 0
    assert np.array_equal(s.values["pt"], np.full(5, 7.0))
    assert np.array_equal(s.values["ub"], np.full(5, 3.0))
    assert sample([], 3, SEED).u.shape == (3, 0)


def test_validation_errors():
    with pytest.raises(ValueError, match="unknown sampling method"):
        sample(register(), 8, SEED, "halton")
    with pytest.raises(ValueError, match="positive integer"):
        sample(register(), 0, SEED)
    with pytest.raises(ValueError, match="duplicate"):
        sample([Dist("a", "uniform", 1.0, 0.0, 2.0), Dist("a", "pointValue", 1.0)], 8, SEED)
    with pytest.raises(ValueError, match="low < high"):
        sample([Dist("a", "uniform", 1.0, 2.0, 0.0)], 8, SEED)
    with pytest.raises(ValueError, match="low <= nominal <= high"):
        sample([Dist("a", "triangular", 5.0, 0.0, 2.0)], 8, SEED)
    with pytest.raises(ValueError, match="low <= nominal <= high"):
        sample([Dist("a", "pert", -1.0, 0.0, 2.0)], 8, SEED)
    with pytest.raises(ValueError, match="logNormal needs low > 0"):
        sample([Dist("a", "logNormal", 1.0, 0.0, 2.0)], 8, SEED)
    with pytest.raises(ValueError, match="weights"):
        sample([Dist("a", "discrete", 1.0, values=(1.0, 2.0), weights=(0.0, 0.0))], 8, SEED)
