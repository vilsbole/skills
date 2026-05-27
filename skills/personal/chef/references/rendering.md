# Rendering algorithm

The rendering script (`scripts/render.py`) turns a recipe tree into an HTML table with `rowspan` cells. This doc explains the algorithm so you can debug/extend it.

## The core idea

In a Cooking for Engineers table:

- Each leaf (ingredient) occupies exactly one row.
- Each internal node (operation) occupies one cell, spanning all the rows of its leaf descendants.
- The column an operation sits in = its depth from the rightmost column. The root is rightmost.

So rendering is: flatten the tree to a leaf list (in DFS order), then for each internal node compute its rowspan (= number of leaf descendants) and its column (= max depth on its right). Place cells accordingly.

## Layout

Two columns per ingredient (name + qty), then one column per operation depth.

```
| name        | qty        | op col 1 | op col 2 | ... | final |
|-------------|------------|----------|----------|-----|-------|
| spaghetti   | 400 g      |          |          |     |       |
| salt        | 1 tbsp     | boil 8m  |          |     |       |
| water       | 4 L        |          |          |     | plate |
| guanciale   | 150 g      | render   |          |     |       |
| egg yolks   | 4          |          |          |     |       |
| pecorino    | 60 g       | whisk    |          |     |       |
| pepper      | 1 tsp      |          |          |     |       |
```

The "boil" cell has `rowspan=3` and sits in op column 1. "Render" has `rowspan=1`. "Whisk" has `rowspan=3`. "Plate" has `rowspan=7` and sits in the final column.

## Computing op columns

The op column of a node is assigned in two passes:

1. **Row assignment**: DFS through the tree, assign each ingredient (leaf) a row index in encounter order. Each op's `row_start` and `row_end` are the first/last row of its leaf descendants.
2. **Column assignment**: The root is placed at column = `max_op_depth` (the longest op chain from root to any op-leaf). Each op is then placed at exactly `parent_col - 1`. This guarantees every op sits directly adjacent to its parent — no visual gaps even when one branch is shallower than another.

The invariant: **a parent op is always exactly one column to the right of each of its op children**, and ops with only ingredient children sit one column to the right of the ingredient columns.

## Styling

- Soft borders (1px solid #ddd) between cells.
- Ingredient name column left-aligned, qty column right-aligned, op cells centered.
- Op cells get a subtle background tint that deepens slightly with each column to the right, so the eye follows toward the final dish.
- The final (root) cell gets a slightly stronger emphasis (bold, slightly darker background).
- Use a system font stack for readability.
- Add a header with the dish title and servings count.
- Include a `notes` section below the table if present.

## Self-contained HTML

Inline all CSS in a `<style>` block in the `<head>`. No external fonts, no JS, no images. The file must work standalone when opened directly in a browser.

## Edge cases

- **Single-ingredient "recipe"**: just one row, one op cell. Renders fine.
- **Very long op labels**: wrap is OK; the column will widen. Keep labels under ~40 chars.
- **Very tall recipes (>15 ingredients)**: still works, just gets long. Consider whether the recipe should be split.
