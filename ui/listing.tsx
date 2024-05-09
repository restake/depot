/** @jsx h */
/** @jsxFrag Fragment */
import { encodeXml, Fragment, h, R2Object, R2Objects, renderToString } from "./deps.ts";

export function computeDirectoryListingHtml(
    objects: R2Objects,
    opts: { prefix: string; cursor?: string; directoryListingLimitParam?: string },
): string {
    const { prefix, cursor, directoryListingLimitParam } = opts;

    const page = (
        <div id="contents">
            <Breadcrumbs prefix={prefix} />
            <Directories objects={objects} prefix={prefix} />
            <Objects objects={objects} prefix={prefix} />
            <Cursor
                cursor={cursor}
                directoryListingLimitParam={directoryListingLimitParam}
            />
        </div>
    );

    return `
        <!DOCTYPE html>
        <html>
            <head>
                <meta charset="utf-8">
                <title>${breadcrumbsString(prefix)}</title>
                <style>${STYLE}</style>
            </head>
            <body>${renderToString(page)}</body>
        </html>
    `;
}

//

const STYLE = `
body { margin: 3rem; font-family: sans-serif; max-width: 30%; }
a { text-decoration: none; text-underline-offset: 0.2rem; }
a:hover { text-decoration: underline; }
.ralign { text-align: right; }
#contents { display: grid; grid-template-columns: 1fr auto auto auto; gap: 0.5rem 1.5rem; white-space: nowrap; }
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

function breadcrumbsString(prefix: string): string {
    const crumbs = ("/" + prefix).split("/").filter((v, i) => i === 0 || v !== "");
    return crumbs.map((v, i) => i === 0 ? "home" : v).join(` ⟩ `);
}

function Breadcrumbs(props: { prefix: string }) {
    const { prefix } = props;

    const crumbs = ("/" + prefix).split("/").filter((v, i) => i === 0 || v !== "");

    function Breadcrumb(props: {
        idx: number;
        crumb: string;
    }) {
        const { idx, crumb } = props;

        const first = idx === 0;
        const last = idx === crumbs.length - 1;
        const content = first ? "home" : encodeXml(crumb);

        return (
            <>
                {first ? null : <span className="delimiter">{` ⟩ `}</span>}
                <span className="breadcrumb">
                    {last ? content : (
                        <a href={crumbs.slice(0, idx + 1).join("/") + "/"}>
                            {content}
                        </a>
                    )}
                </span>
            </>
        );
    }

    return (
        <>
            <div className="full breadcrumbs">
                {crumbs.map((crumb, idx) => <Breadcrumb idx={idx} crumb={crumb} />)}
            </div>
            <div className="full spacer">&nbsp;</div>
        </>
    );
}

function Directories(props: { objects: R2Objects; prefix: string }) {
    const { objects: { delimitedPrefixes }, prefix } = props;

    if (delimitedPrefixes.length <= 0) {
        return null;
    }

    function Directory(props: { delimitedPrefix: string; prefix: string }) {
        const { delimitedPrefix, prefix } = props;

        return (
            <a className="full directory" href={encodeXml("/" + delimitedPrefix)}>
                {encodeXml(delimitedPrefix.substring(prefix.length))}
            </a>
        );
    }

    return (
        <>
            {delimitedPrefixes.map((delimitedPrefix) => <Directory delimitedPrefix={delimitedPrefix} prefix={prefix} />)}
            <div className="full spacer">&nbsp;</div>
        </>
    );
}

function Objects(props: { objects: R2Objects; prefix: string }) {
    const { objects, prefix } = props;

    function Object(props: { object: R2Object; prefix: string }) {
        const { object: { uploaded, key, size }, prefix } = props;

        const formattedDate = uploaded.toLocaleString("en-GB", {
            day: "2-digit",
            month: "2-digit",
            year: "numeric",
            hour: "2-digit",
            minute: "2-digit",
        });

        return (
            <>
                <div className="uri">
                    <a href={encodeXml("/" + key)} className="object-url">
                        {encodeXml(key.substring(prefix.length))}
                    </a>
                </div>
                <div className="size">{size.toLocaleString()}</div>
                <div className="size-human">{computeBytesString(size)}</div>
                <div className="date">{formattedDate}</div>
            </>
        );
    }

    return (
        <>
            {objects.objects.map((obj) => <Object object={obj} prefix={prefix} />)}
        </>
    );
}

function Cursor(props: { cursor: string | undefined; directoryListingLimitParam: string | undefined }) {
    const { cursor, directoryListingLimitParam } = props;
    if (!cursor) {
        return null;
    }

    const params = new URLSearchParams({
        "directoryListingLimit": directoryListingLimitParam ?? "",
        "cursor": encodeXml(cursor),
    }).toString();

    return (
        <>
            <div className="full cursor">
                <a href={`?${params}`}>
                    next ➜
                </a>
            </div>
            <div className="full spacer">&nbsp;</div>
        </>
    );
}
