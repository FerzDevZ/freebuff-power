---
name: tabular-ml-gradient-boosting
description: Production tabular ML with gradient boosting — a logistic baseline first, leakage-safe cross-validation, target encoding inside folds, class imbalance and calibration, early stopping, SHAP for explanation, and a serving/monitoring path that catches drift.
---

# Tabular ML with gradient boosting

Deep learning is rarely the right first move on tabular data. A tuned
XGBoost/LightGBM model plus honest validation beats a bigger network, and it is
easier to explain, serve, and debug.

## Baseline before boosting

```python
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

baseline = Pipeline([
    ("scale", StandardScaler(with_mean=False)),
    ("model", LogisticRegression(max_iter=1000, class_weight="balanced")),
])
```

If boosting cannot beat this by a meaningful margin on the same split, the problem
is data or framing, not model capacity.

## Split and CV that match production

- split by time when the data is temporal (`train < cutoff <= test`), never random;
- group by customer/device when rows from one entity leak across folds;
- keep a final holdout untouched until the model is frozen;
- for imbalanced classification use stratified folds and report precision/recall or
  PR-AUC, not accuracy.

## Leakage checklist

| Smell | Fix |
|---|---|
| target encoding computed on the full dataset | fit encoding inside each CV fold, or use out-of-fold encoding |
| feature computed after the outcome | rebuild the feature with only pre-outcome data |
| duplicate rows across train/test | deduplicate by entity before splitting |
| ID-like column with high cardinality | drop it or encode with fold-safe target encoding |
| scaler/imputer fit on all data | put it in a `Pipeline`, fit on train only |

## Training with early stopping

```python
import xgboost as xgb

model = xgb.XGBClassifier(
    n_estimators=2000,
    learning_rate=0.05,
    max_depth=6,
    subsample=0.8,
    colsample_bytree=0.8,
    eval_metric="aucpr",
    early_stopping_rounds=100,   # xgboost <2.0; in 2.x pass callbacks=[xgb.callback.EarlyStopping(...)]
)
model.fit(X_train, y_train, eval_set=[(X_valid, y_valid)], verbose=False)
```

LightGBM equivalent: `LGBMClassifier(...).fit(..., eval_set=[(X_valid, y_valid)], callbacks=[lgb.early_stopping(100)])`.
Version differences matter; check the installed version before copying a snippet.

## Imbalance and calibration

- `scale_pos_weight` (XGBoost) or `class_weight="balanced"` (LightGBM) changes the
  decision threshold, not the ranking;
- choose the threshold from the business cost matrix on validation data, then
  freeze it;
- if you need probabilities (pricing, risk), calibrate (`CalibratedClassifierCV`,
  isotonic/Platt) and verify with a reliability curve;
- report the base rate next to every metric.

## Explanation

- global: gain/permutation importance, SHAP summary;
- local: SHAP force plot for the specific decision, not a generic "top features";
- monotonic constraints where domain knowledge requires them (e.g. more debt must
  not lower risk);
- explanations are for humans; they are not a correctness proof.

## Serving and monitoring

- freeze the feature pipeline with the model (same code path offline and online);
- version model + schema + threshold together;
- log inputs, prediction, and later the outcome for evaluation;
- monitor feature drift (PSI/KS) and prediction distribution; alert before accuracy
  visibly drops;
- retrain on a schedule tied to drift, not to a calendar alone.

## Limits

- Hyperparameter search (Optuna etc.) is optional; a sane default with good
  validation usually wins first.
- No fixture: results depend on your dataset; the checks here are procedural.
- API names above follow xgboost/lightgbm/sklearn conventions but vary by version —
  pin versions and read that version's docs.
