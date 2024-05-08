import { encodeXml, R2Objects } from "./deps.ts";

export function computeDirectoryListingHtml(
    objects: R2Objects,
    opts: { prefix: string; cursor?: string; directoryListingLimitParam?: string },
): string {
    const { prefix, cursor, directoryListingLimitParam } = opts;
    const lines = ["<!DOCTYPE html>", "<html>", "<head>", "<style>", STYLE, "</style>", "</head>", "<body>"];

    lines.push('<div id="contents">');
    lines.push(`<div class="full">${computeBreadcrumbs(prefix)}</div>`);
    lines.push('<div class="full">&nbsp;</div>');
    if (objects.delimitedPrefixes.length > 0) {
        for (const delimitedPrefix of objects.delimitedPrefixes) {
            lines.push(
                `<a class="full" href="${encodeXml("/" + delimitedPrefix)}">${encodeXml(delimitedPrefix.substring(prefix.length))}</a>`,
            );
        }
        lines.push('<div class="full">&nbsp;</div>');
    }
    for (const obj of objects.objects) {
        lines.push(
            `<a href="${encodeXml("/" + obj.key)}">${
                encodeXml(obj.key.substring(prefix.length))
            }</a><div class="ralign">${obj.size.toLocaleString()}</div><div class="ralign">${
                computeBytesString(obj.size)
            }</div><div>${obj.uploaded.toISOString()}</div>`,
        );
    }
    if (cursor) {
        lines.push('<div class="full">&nbsp;</div>');
        lines.push(
            `<div class="full"><a href="?${
                directoryListingLimitParam ? `directoryListingLimit=${directoryListingLimitParam}&` : ""
            }cursor=${encodeXml(cursor)}">next ➜</a></div>`,
        );
    }
    lines.push("</div>");

    lines.push("</body>", "</html>");
    return lines.join("\n");
}

//

const STYLE = `
body { margin: 3rem; font-family: sans-serif; }
a { text-decoration: none; text-underline-offset: 0.2rem; }
a:hover { text-decoration: underline; }
.ralign { text-align: right; }
#contents { display: grid; grid-template-columns: 1fr 6rem auto auto; gap: 0.5rem 1.5rem; white-space: nowrap; }
#contents .full { grid-column: 1 / span 4; }

@media (prefers-color-scheme: dark) {
    body {background: #121212; color: #f5f5f5; }
    a { color: #bb86fc; }
}
`;

const MAX_TWO_DECIMALS = new Intl.NumberFormat("en-US", { minimumFractionDigits: 0, maximumFractionDigits: 2 });

function computeBytesString(bytes: number): string {
    if (bytes < 1024) return "";
    let amount = bytes / 1024;
    for (const unit of ["kb", "mb", "gb"]) {
        if (amount < 1024) return `(${MAX_TWO_DECIMALS.format(amount)} ${unit})`;
        amount = amount / 1024;
    }
    return `(${MAX_TWO_DECIMALS.format(amount)} tb)`;
}

function computeBreadcrumbs(prefix: string): string {
    const tokens = ("/" + prefix).split("/").filter((v, i) => i === 0 || v !== "");
    return tokens.map((v, i) =>
        `${i === 0 ? "" : ` ⟩ `}${
            i === tokens.length - 1
                ? (i === 0 ? "home" : encodeXml(v))
                : `<a href="${tokens.slice(0, i + 1).join("/") + "/"}">${i === 0 ? "home" : encodeXml(v)}</a>`
        }`
    ).join("");
}
