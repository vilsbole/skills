"""Render a Cooking for Engineers-style recipe table as HTML.

Usage:
    from render import render_recipe
    html = render_recipe(recipe_dict)
    # or from CLI:
    #   python render.py recipe.json output.html
"""

import json
import sys
import html
from pathlib import Path


def _validate_node(node, path="tree"):
    """Sanity-check a node and its descendants."""
    if not isinstance(node, dict):
        raise ValueError(f"{path}: node must be a dict, got {type(node).__name__}")
    kind = node.get("kind")
    if kind == "ingredient":
        if "name" not in node:
            raise ValueError(f"{path}: ingredient missing 'name'")
        # qty is optional but recommended
    elif kind == "op":
        if "label" not in node:
            raise ValueError(f"{path}: op missing 'label'")
        children = node.get("children", [])
        if not children:
            raise ValueError(f"{path}: op '{node.get('label')}' has no children")
        for i, child in enumerate(children):
            _validate_node(child, f"{path}.children[{i}]")
    else:
        raise ValueError(f"{path}: node 'kind' must be 'ingredient' or 'op', got {kind!r}")


def _assign_rows(node, leaf_counter):
    """First pass: assign row indices to leaves; compute row_start/row_end for ops."""
    if node["kind"] == "ingredient":
        node["_row"] = leaf_counter[0]
        leaf_counter[0] += 1
        return
    row_start = leaf_counter[0]
    for child in node["children"]:
        _assign_rows(child, leaf_counter)
    node["_row_start"] = row_start
    node["_row_end"] = leaf_counter[0] - 1


def _assign_cols(node, parent_col):
    """Second pass: assign each op a column equal to (parent_col - 1).

    This guarantees every op sits exactly one column to the left of its parent,
    so the visual layout has no gaps regardless of branch depth.
    Call with parent_col = total_op_cols + 1 for the root so root ends up at total_op_cols.
    """
    if node["kind"] != "op":
        return
    node["_col"] = parent_col - 1
    for child in node["children"]:
        _assign_cols(child, node["_col"])


def _max_depth(node):
    """Longest path length from this node to any descendant op (root op = depth 1)."""
    if node["kind"] != "op":
        return 0
    return 1 + max((_max_depth(c) for c in node["children"]), default=0)


def _collect_ops(node, ops):
    """Collect all op nodes into a flat list."""
    if node["kind"] == "op":
        ops.append(node)
        for child in node["children"]:
            _collect_ops(child, ops)


def _collect_ingredients(node, ings):
    """Collect ingredients in row order (DFS, the order leaves were assigned)."""
    if node["kind"] == "ingredient":
        ings.append(node)
    else:
        for child in node["children"]:
            _collect_ingredients(child, ings)


# Color ramp for op columns: leftmost cols pale, rightmost (final) emphasized.
def _op_bg(col, total_cols):
    """Return a background color for an op cell based on its column."""
    if total_cols <= 1:
        return "#f5efe1"
    # interpolate from cream (#faf6ec) at col=1 to warmer (#e8d9b8) at col=total
    t = (col - 1) / max(1, total_cols - 1)
    # linear blend
    r1, g1, b1 = 0xfa, 0xf6, 0xec
    r2, g2, b2 = 0xe8, 0xd9, 0xb8
    r = round(r1 + (r2 - r1) * t)
    g = round(g1 + (g2 - g1) * t)
    b = round(b1 + (b2 - b1) * t)
    return f"#{r:02x}{g:02x}{b:02x}"


CSS = """
* { box-sizing: border-box; }
body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
                 "Helvetica Neue", Arial, sans-serif;
    max-width: 1100px;
    margin: 2.5rem auto;
    padding: 0 1.5rem;
    color: #2a2620;
    background: #fbfaf6;
    line-height: 1.5;
}
h1 {
    font-size: 1.85rem;
    margin: 0 0 0.25rem;
    font-weight: 600;
    letter-spacing: -0.01em;
}
.servings {
    color: #877c66;
    font-size: 0.95rem;
    margin-bottom: 1.5rem;
}
table.recipe {
    border-collapse: collapse;
    width: 100%;
    background: #fffdf7;
    box-shadow: 0 1px 2px rgba(0,0,0,0.04);
    margin-bottom: 1.5rem;
}
table.recipe td {
    border: 1px solid #d9d1bd;
    padding: 0.55rem 0.75rem;
    vertical-align: middle;
    font-size: 0.95rem;
}
td.ingredient-name {
    background: #ffffff;
    font-weight: 500;
    width: 22%;
}
td.ingredient-qty {
    background: #ffffff;
    color: #6b6450;
    font-size: 0.88rem;
    text-align: right;
    white-space: nowrap;
    width: 14%;
}
td.op {
    text-align: center;
    font-style: italic;
    color: #3a3528;
}
td.op-final {
    font-weight: 600;
    font-style: normal;
    background: #d8c39a !important;
    color: #2a2620;
}
.notes {
    background: #fffdf7;
    border-left: 3px solid #c9b483;
    padding: 0.85rem 1rem;
    font-size: 0.92rem;
    color: #4a4536;
    border-radius: 2px;
}
.notes strong { color: #2a2620; }
footer {
    margin-top: 2rem;
    color: #a89e85;
    font-size: 0.8rem;
    text-align: center;
}
"""


def render_recipe(recipe):
    """Render a recipe dict to a standalone HTML string."""
    _validate_node(recipe["tree"])

    # Pass 1: assign row indices to leaves and row_start/row_end to ops
    leaf_counter = [0]
    _assign_rows(recipe["tree"], leaf_counter)
    total_rows = leaf_counter[0]

    # Pass 2: assign column indices. Use max op-depth as total column count
    # so root sits at the rightmost column and each op is exactly one to the
    # left of its parent (no visual gaps).
    total_op_cols = _max_depth(recipe["tree"])
    _assign_cols(recipe["tree"], total_op_cols + 1)

    # Collect all ops for emission
    ops = []
    _collect_ops(recipe["tree"], ops)

    # Bucket ops by row_start for placement during row-by-row HTML emission.
    # For each row, we need to know: which op cells *begin* on this row?
    ops_by_row_start = {}
    for op in ops:
        ops_by_row_start.setdefault(op["_row_start"], []).append(op)
    # Sort each row's ops by column so we emit them left-to-right
    for row_ops in ops_by_row_start.values():
        row_ops.sort(key=lambda o: o["_col"])

    # Collect ingredients in row order
    ingredients = []
    _collect_ingredients(recipe["tree"], ingredients)
    assert len(ingredients) == total_rows

    # Build the HTML
    title = html.escape(recipe.get("title", "Recipe"))
    servings = recipe.get("servings")
    notes = recipe.get("notes", "")

    rows_html = []
    for row_idx, ing in enumerate(ingredients):
        cells = []
        cells.append(
            f'<td class="ingredient-name">{html.escape(ing["name"])}</td>'
        )
        cells.append(
            f'<td class="ingredient-qty">{html.escape(ing.get("qty", ""))}</td>'
        )
        # Emit any op cells that begin on this row
        for op in ops_by_row_start.get(row_idx, []):
            rowspan = op["_row_end"] - op["_row_start"] + 1
            is_final = op is recipe["tree"]
            classes = "op op-final" if is_final else "op"
            style = f'background:{_op_bg(op["_col"], total_op_cols)};'
            cells.append(
                f'<td class="{classes}" rowspan="{rowspan}" style="{style}">'
                f'{html.escape(op["label"])}</td>'
            )
        rows_html.append("    <tr>" + "".join(cells) + "</tr>")

    servings_line = (
        f'<div class="servings">Serves {html.escape(str(servings))}</div>'
        if servings is not None
        else ""
    )
    notes_block = (
        f'<div class="notes"><strong>Notes.</strong> {html.escape(notes)}</div>'
        if notes
        else ""
    )

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>{title}</title>
<style>{CSS}</style>
</head>
<body>
<h1>{title}</h1>
{servings_line}
<table class="recipe">
{chr(10).join(rows_html)}
</table>
{notes_block}
<footer>Cooking for Engineers-style recipe table.</footer>
</body>
</html>
"""


def main():
    if len(sys.argv) != 3:
        print("Usage: python render.py <recipe.json> <output.html>", file=sys.stderr)
        sys.exit(1)
    recipe = json.loads(Path(sys.argv[1]).read_text())
    html_out = render_recipe(recipe)
    Path(sys.argv[2]).write_text(html_out)
    print(f"Wrote {sys.argv[2]}")


if __name__ == "__main__":
    main()
