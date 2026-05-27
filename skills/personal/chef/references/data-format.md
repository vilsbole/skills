# Recipe data format

A recipe is a tree. Leaves are ingredients; internal nodes are operations that combine their children into an intermediate (or, at the root, the final dish).

## Schema

```python
recipe = {
    "title": str,           # e.g. "Spaghetti alla Carbonara"
    "servings": int,        # e.g. 4
    "notes": str,           # optional; brief context, source, or technique notes
    "tree": Node,           # the operation tree (see below)
}
```

A `Node` is either an **ingredient** (leaf) or an **operation** (internal):

```python
# Leaf — an ingredient
{
    "kind": "ingredient",
    "name": str,            # e.g. "guanciale"
    "qty": str,             # e.g. "150 g" or "2 cloves" or "to taste"
}

# Internal — an operation that combines children
{
    "kind": "op",
    "label": str,           # short verb phrase, e.g. "render 5 min" or "whisk"
    "children": [Node, ...] # 2+ nodes; order = visual top-to-bottom
}
```

The order of children matters visually — they're laid out top-to-bottom in the rendered table, and merged cells span contiguous blocks. Reorder freely while designing to keep merged cells clean.

## Example: Carbonara

```python
{
    "title": "Spaghetti alla Carbonara",
    "servings": 4,
    "notes": "Roman classic. No cream — the silky texture comes from emulsifying egg yolks with rendered fat and pasta water.",
    "tree": {
        "kind": "op",
        "label": "toss off heat, plate",
        "children": [
            {
                "kind": "op",
                "label": "boil 8 min, reserve 1 cup water",
                "children": [
                    {"kind": "ingredient", "name": "spaghetti", "qty": "400 g"},
                    {"kind": "ingredient", "name": "salt", "qty": "1 tbsp"},
                    {"kind": "ingredient", "name": "water", "qty": "4 L"},
                ],
            },
            {
                "kind": "op",
                "label": "render 5 min",
                "children": [
                    {"kind": "ingredient", "name": "guanciale", "qty": "150 g, diced"},
                ],
            },
            {
                "kind": "op",
                "label": "whisk",
                "children": [
                    {"kind": "ingredient", "name": "egg yolks", "qty": "4"},
                    {"kind": "ingredient", "name": "pecorino romano", "qty": "60 g, grated"},
                    {"kind": "ingredient", "name": "black pepper", "qty": "1 tsp, cracked"},
                ],
            },
        ],
    },
}
```

This produces a table with 7 ingredient rows. The "boil" cell spans the first 3 rows, "render" spans 1 row, "whisk" spans the last 3 rows. The final "toss off heat, plate" cell spans all 7.

## Quantity formatting

Use the format people actually cook with. Metric is fine; US units are fine; mixing is fine if culturally appropriate (e.g., "1 cup flour, 200 g sugar" is normal in baking).

Include preparation in the qty field when it's part of the measurement: "150 g, diced", "2 cloves, minced", "1 lemon, zested". This keeps the operation labels focused on the combining/cooking step.

For salt/pepper "to taste" — write `"to taste"` as the qty.

## Sub-recipes

If the same intermediate is used in two places (e.g., a sauce poured over multiple components), the strict tree breaks. Options:

1. **Inline twice with split qty**: list the ingredients twice with half quantities each. Ugly but works.
2. **Flatten**: design the dish so the intermediate is only used once. Usually possible.
3. **Note in `notes`**: build the tree for the main flow and describe the reuse in the notes field.

Default to flattening. If you can't, use option 3.

## Linear recipes

If the recipe is genuinely linear (each step adds one ingredient to the running pot), that's fine — just nest ops. Each op has one ingredient child and one prior-op child. The table will look like a staircase, which is correct.
