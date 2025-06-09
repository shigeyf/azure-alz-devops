# pylint: disable=line-too-long
# flake8: noqa: E501
"""
A simple python script to extract plan summary
 from a Terraform plan JSON format file.
"""

import json
import sys
from pathlib import Path


HEADER = {
    "html": """
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Terraform Plan</title>
<style>
body { font-family: Arial, sans-serif; padding: 20px; background: #f9f9f9; }
h2 { color: #333; }
.resource-block { background: #fff; padding: 15px; margin: 10px 0; border-radius: 5px; box-shadow: 0 0 5px rgba(0,0,0,0.1); }
.diff-section { display: flex; gap: 20px; }
// pre { background: #eee; padding: 10px; overflow-x: auto; border-radius: 5px; max-width: 45vw; }
table { border-collapse: collapse; }
th, td { border: 1px solid #ddd; text-align: left; }
th { background-color: #f4f4f4; font-weight: bold; }
tr:nth-child(even) { background-color: #f9f9f9; }
</style>
</head>
<body>
<h1>Terraform Plan Summary</h1>
<h2>Terraform Plan: List of Resource Property Changes</h2>
""",
    "markdown": """## Terraform Plan: List of Resource Changes\n\n""",
}

FOOTER = {
    "html": """</body>\n</html>\n""",
    "markdown": "\n\n",
}


def gen_resource_changes(output_format, address, action, difflines):
    """
    Create a formatted resource block for the HTML output.
    Args:
        output_format (str): The format of the output (e.g., Markdown, HTML).
        address (str): The resource address.
        action (str): The action performed on the resource.
        difflines (str): The lines of difference of resource properties to be displayed.
    Returns:
        str: A formatted string for the resource block.
    """
    if output_format == "html":
        if difflines == "":
            return f"""
<div class="resource-block">
<h3>Resource: {address}</h3>
<p><strong>Actions:</strong> {action}</p>
<div class="diff-section">
<p>No property changes detected.</p>
</div>
</div>
"""
        return f"""
<div class="resource-block">
<h3>Resource: {address}</h3>
<p><strong>Actions:</strong> {action}</p>
<div class="diff-section">
<table>
<thead><tr><th>Property</th><th>Before</th><th>After</th></tr></thead>
<tbody>
{difflines}
</tbody>
</table>
</div>
</div>
"""
    if output_format == "markdown":
        if difflines == "":
            return (
                f"### Resource {action}: `{address}`\n\n"
                + "No property changes detected.\n"
            )
        return (
            f"### Resource {action}: `{address}`\n\n"
            + "| Property | Before | After |\n"
            + "| -------- | ------ | ----- |\n"
            + difflines
        )

    return ""


def gen_resource_property_changes(
    output_format, action, key, before_value, after_value
):
    """
    Create a formatted line for the diff table.
    Args:
        output_format (str): The format of the diff line (e.g., Markdown, HTML).
        action (str): The action type of change (CREATE, DELETE, UPDATE, REPLACE).
        key (str): The property name.
        before_value: The value before the change.
        after_value: The value after the change.
    Returns:
        str: A formatted string for the diff table.
    """
    diff_formats = {
        "html": {
            "[CREATE]": f'<tr class="create"><td><pre>{key}</pre></td><td>(New)</td><td>{after_value}</td></tr>',
            "[DELETE]": f'<tr class="delete"><td><pre>{key}</pre></td><td>{before_value}</td><td>(Deleted)</td></tr>',
            "[UPDATE]": f'<tr class="update"><td><pre>{key}</pre></td><td>{before_value}</td><td>{after_value}</td></tr>',
            "[REPLACE]": f'<tr class="replace"><td><pre>{key}</pre></td><td>{before_value}</td><td>{after_value}</td></tr>',
        },
        "markdown": {
            "[CREATE]": f"| `{key}` | (New) | `{after_value}` |",
            "[DELETE]": f"| `{key}` | `{before_value}` | (Deleted) |",
            "[UPDATE]": f"| `{key}` | `{before_value}` | `{after_value}` |",
            "[REPLACE]": f"| `{key}` | `{before_value}` | `{after_value}` |",
        },
    }
    return diff_formats[output_format][action]


def summarize_changes(tfplan_json_file, output_format="html"):
    """
    Summarize changes in a Terraform plan JSON file.
    Args:
        tfplan_json_file (dict): The JSON content of the Terraform plan file.
    Returns:
        str: A summary of the changes in Markdown format.
    """
    output = []

    for change in tfplan_json_file.get("resource_changes", []):
        actions = change["change"]["actions"]
        address = change["address"]
        before = change["change"].get("before", {}) or {}
        after = change["change"].get("after", {}) or {}

        diffs = []
        action = ""
        if actions == ["create"]:
            action = "[CREATE]"
            for key, value in after.items():
                value = "null" if value is None else value
                diffs.append(
                    gen_resource_property_changes(
                        output_format, action, key, "(New)", value
                    )
                )
        elif actions == ["delete"]:
            action = "[DELETE]"
            for key, value in before.items():
                value = "null" if value is None else value
                diffs.append(
                    gen_resource_property_changes(
                        output_format, action, key, value, "(Deleted)"
                    )
                )
        elif actions == ["update"]:
            action = "[UPDATE]"
            for key in after:
                before_value = before.get(key, "(New)")
                after_value = after.get(key, "(Delete)")
                before_value = "null" if before_value is None else before_value
                after_value = "null" if after_value is None else after_value
                if before_value != after_value:
                    diffs.append(
                        gen_resource_property_changes(
                            output_format, action, key, before_value, after_value
                        )
                    )
        elif actions == ["delete", "create"]:
            action = "[REPLACE]"
            all_keys = set(before.keys()).union(set(after.keys()))
            for key in sorted(all_keys):
                before_value = before.get(key, "(none)")
                after_value = after.get(key, "(none)")
                before_value = "null" if before_value is None else before_value
                after_value = "null" if after_value is None else after_value
                if before_value != after_value:
                    diffs.append(
                        gen_resource_property_changes(
                            output_format, action, key, before_value, after_value
                        )
                    )

        if diffs:
            output.append(
                gen_resource_changes(output_format, address, action, "\n".join(diffs))
            )
        else:
            output.append(
                gen_resource_changes(output_format, address, "NoChanges", "")
            )

    if not output:
        output.append("No changes detected in the Terraform plan.")

    return HEADER[output_format] + "\n\n".join(output) + FOOTER[output_format]


def main():
    """
    Main function to read the input file and write the output.
    """
    input_file = sys.argv[1]
    output_file = sys.argv[2]

    with open(input_file, "r", encoding="utf-8") as f:
        tfplan = json.load(f)

    output_format = "html" if output_file.endswith(".html") else "markdown"
    output = summarize_changes(tfplan, output_format)
    Path(output_file).write_text(output, encoding="utf-8")
    print(f"✅ Terraform plan {output_format} file written to {output_file}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python generate_plan_html.py tfplan.json output.html")
        sys.exit(1)
    main()
